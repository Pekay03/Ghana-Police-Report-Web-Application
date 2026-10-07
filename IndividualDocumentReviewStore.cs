using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;
using PoliceBackgroundCheckSystem.Helpers;

namespace PoliceBackgroundCheckSystem
{
    // New individual reviews use existing storage. Legacy rows are read only.
    internal static class IndividualDocumentReviewStore
    {
        internal const string Prefix = "[LOCAL INDIVIDUAL DOCUMENT REVIEW:v1] ";
        private const string FamilyPrefix = "[LOCAL INDIVIDUAL DOCUMENT REVIEW:";
        private const string WholePrefix = "[LOCAL DOCUMENT REVIEW:";

        internal sealed class Payload
        {
            public string DocumentType { get; set; }
            public string Decision { get; set; }
            public string Reason { get; set; }
            public int ReviewerUserID { get; set; }
        }

        internal sealed class Record
        {
            public string DocumentType { get; set; }
            public string Decision { get; set; }
            public string ReviewReason { get; set; }
            public int ReviewerUserID { get; set; }
            public string ReviewerName { get; set; }
            public DateTime ReviewedAt { get; set; }
            public long Order { get; set; }
            public bool Legacy { get; set; }
            public bool WholeSet { get; set; }
        }

        internal static bool ValidDocument(string type)
        {
            return new[] { "Ghana Card", "Passport", "Voter ID", "Driver's Licence" }
                .Any(id => Array.IndexOf(ApplicationDocumentCatalog.RequiredTypes(id), type) >= 0);
        }

        internal static bool ValidDecision(string decision)
        {
            return decision == "ACCEPTED" || decision == "FURTHER_REVIEW" || decision == "REJECTED";
        }

        internal static string Encode(string type, string decision, string reason, int actor)
        {
            reason = (reason ?? "").Trim();
            if (!ValidDocument(type) || !ValidDecision(decision) || actor <= 0 ||
                reason.Length < 5 || reason.Length > 1000)
                throw new ArgumentException("Invalid individual document review.");
            return Prefix + new JavaScriptSerializer().Serialize(new Payload {
                DocumentType = type, Decision = decision, Reason = reason, ReviewerUserID = actor
            });
        }

        internal static Payload Decode(string notes)
        {
            if (notes == null || !notes.StartsWith(FamilyPrefix, StringComparison.Ordinal))
                return null; // Unrelated historical verification entries are not individual decisions.
            if (!notes.StartsWith(Prefix, StringComparison.Ordinal))
                throw new InvalidOperationException("Unsupported individual review format.");
            Payload payload;
            try { payload = new JavaScriptSerializer().Deserialize<Payload>(notes.Substring(Prefix.Length)); }
            catch (Exception ex) { throw new InvalidOperationException("Unreadable individual review.", ex); }
            if (payload == null || !ValidDocument(payload.DocumentType) ||
                !ValidDecision(payload.Decision) || payload.ReviewerUserID <= 0 ||
                String.IsNullOrWhiteSpace(payload.Reason) ||
                payload.Reason.Trim().Length < 5 || payload.Reason.Length > 1000)
                throw new InvalidOperationException("Invalid stored individual review.");
            return payload;
        }

        internal static List<Record> Load(MySqlConnection connection, MySqlTransaction transaction,
            string reference)
        {
            var records = new List<Record>();
            using (var command = new MySqlCommand(@"
                SELECT l.LogID, l.OfficerName, l.VerificationDate, l.Notes
                FROM verification_log l JOIN applications a ON a.ApplicationID=l.ApplicationID
                WHERE a.application_id=@Reference;", connection, transaction))
            {
                command.Parameters.AddWithValue("@Reference", reference);
                using (var reader = command.ExecuteReader())
                    while (reader.Read())
                    {
                        string notes = Convert.ToString(reader["Notes"]);
                        Payload payload = Decode(notes);
                        bool whole = notes.StartsWith(WholePrefix, StringComparison.Ordinal);
                        if (payload == null && !whole) continue;
                        if (reader["VerificationDate"] == DBNull.Value)
                            throw new InvalidOperationException("Review timestamp is missing.");
                        string decision = payload == null ? "UNKNOWN" : payload.Decision;
                        if (whole)
                        {
                            if (notes.StartsWith("[LOCAL DOCUMENT REVIEW: Verified]", StringComparison.Ordinal))
                                decision = "ACCEPTED";
                            else if (notes.StartsWith("[LOCAL DOCUMENT REVIEW: Flagged]", StringComparison.Ordinal))
                                decision = "FURTHER_REVIEW";
                            else if (notes.StartsWith("[LOCAL DOCUMENT REVIEW: Rejected]", StringComparison.Ordinal))
                                decision = "REJECTED";
                        }
                        records.Add(new Record {
                            DocumentType = payload == null ? "" : payload.DocumentType,
                            Decision = decision, ReviewReason = payload == null ? notes : payload.Reason,
                            ReviewerUserID = payload == null ? 0 : payload.ReviewerUserID,
                            ReviewerName = Convert.ToString(reader["OfficerName"]),
                            ReviewedAt = Convert.ToDateTime(reader["VerificationDate"]),
                            Order = Convert.ToInt64(reader["LogID"]), WholeSet = whole
                        });
                    }
            }
            // Only missing-table (1146) is optional. Permission, schema and connection
            // failures must be visible and block approval, not masquerade as empty history.
            try
            {
                using (var command = new MySqlCommand(@"
                    SELECT ReviewID, DocumentType, Decision, ReviewReason,
                           ReviewerUserID, ReviewerName, ReviewedAt
                    FROM identity_document_reviews WHERE ApplicationReference=@Reference;",
                    connection, transaction))
                {
                    command.Parameters.AddWithValue("@Reference", reference);
                    using (var reader = command.ExecuteReader())
                        while (reader.Read())
                        {
                            if (reader["ReviewedAt"] == DBNull.Value)
                                throw new InvalidOperationException("Legacy review timestamp is missing.");
                            records.Add(new Record {
                                DocumentType = Convert.ToString(reader["DocumentType"]),
                                Decision = Convert.ToString(reader["Decision"]).Trim().ToUpperInvariant(),
                                ReviewReason = Convert.ToString(reader["ReviewReason"]),
                                ReviewerUserID = reader["ReviewerUserID"] == DBNull.Value
                                    ? 0 : Convert.ToInt32(reader["ReviewerUserID"]),
                                ReviewerName = Convert.ToString(reader["ReviewerName"]),
                                ReviewedAt = Convert.ToDateTime(reader["ReviewedAt"]),
                                Order = Convert.ToInt64(reader["ReviewID"]), Legacy = true
                            });
                        }
                }
            }
            catch (MySqlException ex) { if (ex.Number != 1146) throw; }
            return Sorted(records).ToList();
        }

        internal static IEnumerable<Record> Sorted(IEnumerable<Record> records)
        {
            // Log IDs share an ordering between new whole-set and individual events.
            // Legacy IDs do not: at equal timestamps prefer the existing-storage event.
            return records.OrderByDescending(r => r.ReviewedAt)
                .ThenBy(r => r.Legacy).ThenByDescending(r => r.Order);
        }

        internal static bool CanApprove(string[] required, Func<string, bool> exists,
            IEnumerable<Record> records)
        {
            if (required.Length == 0 || required.Any(type => !exists(type))) return false;
            var ordered = Sorted(records).ToList();
            Record whole = ordered.FirstOrDefault(r => r.WholeSet);
            // A whole-set Flag/Reject cannot be cleared by individual accepts.
            if (whole != null && whole.Decision != "ACCEPTED") return false;
            foreach (string type in required)
            {
                Record latest = ordered.FirstOrDefault(r => !r.WholeSet && r.DocumentType == type);
                if (latest != null && ordered.Any(r => !r.WholeSet && r.DocumentType == type &&
                    r.ReviewedAt == latest.ReviewedAt && r.Legacy != latest.Legacy &&
                    r.Decision != "ACCEPTED") &&
                    (whole == null || latest.ReviewedAt >= whole.ReviewedAt))
                    return false; // Cross-store same-second order is unknown: fail closed on conflicts.
                if (whole == null)
                {
                    if (latest == null || latest.Decision != "ACCEPTED") return false;
                }
                else if (latest != null &&
                    (latest.ReviewedAt > whole.ReviewedAt ||
                     (latest.ReviewedAt == whole.ReviewedAt && (latest.Legacy || latest.Order > whole.Order))) &&
                    latest.Decision != "ACCEPTED")
                    return false; // A newer individual flag also supersedes a whole-set Verified.
            }
            return true;
        }
    }
}
