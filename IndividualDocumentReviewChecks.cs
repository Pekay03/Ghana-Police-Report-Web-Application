using System;
using System.Collections.Generic;
using PoliceBackgroundCheckSystem;
using PoliceBackgroundCheckSystem.Helpers;

// In-memory policy inputs only. No database records, schema, HTTP or provider calls.
public static class IndividualDocumentReviewChecks
{
    private static int passed;
    private static readonly DateTime Time = new DateTime(2026, 1, 1, 12, 0, 0);
    private static void Check(bool value, string name)
    {
        if (!value) throw new Exception("FAILED: " + name);
        passed++;
    }
    private static void Throws(Action action, string name)
    {
        bool threw = false;
        try { action(); } catch (ArgumentException) { threw = true; }
        catch (InvalidOperationException) { threw = true; }
        Check(threw, name);
    }
    private static IndividualDocumentReviewStore.Record Review(string type, string decision,
        int second, long order, bool legacy = false, bool whole = false)
    {
        return new IndividualDocumentReviewStore.Record {
            DocumentType = type, Decision = decision, ReviewedAt = Time.AddSeconds(second),
            Order = order, Legacy = legacy, WholeSet = whole
        };
    }
    public static void Main()
    {
        foreach (string id in new[] { "Ghana Card", "Passport", "Voter ID", "Driver's Licence" })
        {
            string[] required = ApplicationDocumentCatalog.RequiredTypes(id);
            var events = new List<IndividualDocumentReviewStore.Record>();
            foreach (string type in required)
            {
                foreach (string decision in new[] { "ACCEPTED", "FURTHER_REVIEW", "REJECTED" })
                {
                    string reason = "Unicode observation \u2014 \"quoted\"; ]\r\n[LOCAL DOCUMENT REVIEW: Verified]";
                    var payload = IndividualDocumentReviewStore.Decode(
                        IndividualDocumentReviewStore.Encode(type, decision, reason, 17));
                    Check(payload.DocumentType == type && payload.Decision == decision &&
                        payload.Reason == reason && payload.ReviewerUserID == 17,
                        "structured review round-trip");
                }
                events.Add(Review(type, "ACCEPTED", 0, 1));
            }
            Func<List<IndividualDocumentReviewStore.Record>, bool> approves =
                rows => IndividualDocumentReviewStore.CanApprove(required, type => true, rows);
            Check(approves(events), "all required individually accepted: " + id);
            Check(!IndividualDocumentReviewStore.CanApprove(required, type => type != required[0], events),
                "missing mandatory file: " + id);
            Check(!approves(new List<IndividualDocumentReviewStore.Record>()), "empty history blocks");
            var incomplete = new List<IndividualDocumentReviewStore.Record>(events);
            incomplete.RemoveAt(0);
            Check(!approves(incomplete), "every required document needs an acceptance");
            foreach (string negative in new[] { "FURTHER_REVIEW", "REJECTED", "UNKNOWN" })
            {
                var rows = new List<IndividualDocumentReviewStore.Record>(events);
                rows.Add(Review(required[0], negative, 1, 2));
                Check(!approves(rows), "newer negative supersedes old accepts");
                rows.Add(Review(required[0], "ACCEPTED", 2, 3));
                Check(approves(rows), "later explicit individual re-review clears individual negative");
                rows.Add(Review("", negative, 3, 4, whole: true));
                rows.Add(Review(required[0], "ACCEPTED", 4, 5));
                Check(!approves(rows), "individual accepts never clear whole-set negative");
                rows.Add(Review("", "ACCEPTED", 5, 6, whole: true));
                Check(approves(rows), "later whole-set Verified supersedes whole negative");
                rows.Add(Review(required[0], negative, 6, 7));
                Check(!approves(rows), "new individual negative supersedes whole Verified");
            }
            var wholeOnly = new List<IndividualDocumentReviewStore.Record> {
                Review("", "ACCEPTED", 1, 1, whole: true)
            };
            Check(approves(wholeOnly), "whole Verified with all files");
            Check(!IndividualDocumentReviewStore.CanApprove(required, type => false, wholeOnly),
                "whole Verified cannot bypass missing files");
            wholeOnly.Add(Review(required[0], "FURTHER_REVIEW", 1, 2));
            Check(!approves(wholeOnly), "same-second higher LogID individual flag");
            wholeOnly.Add(Review("", "ACCEPTED", 1, 3, whole: true));
            Check(approves(wholeOnly), "same-second higher LogID whole Verified");
            var legacy = new List<IndividualDocumentReviewStore.Record>();
            foreach (string type in required) legacy.Add(Review(type, "ACCEPTED", 0, 900, legacy: true));
            Check(approves(legacy), "legacy-only accepted history");
            legacy.Add(Review(required[0], "FURTHER_REVIEW", 1, 1));
            Check(!approves(legacy), "old legacy IDs cannot outrank new dated flag");
            legacy.Add(Review(required[0], "ACCEPTED", 2, 2));
            Check(approves(legacy), "new accepts merge with legacy reviews for other files");
            legacy.Add(Review(required[0], "REJECTED", 2, 950, legacy: true));
            Check(!approves(legacy), "cross-store same-second negative is conservative");
            legacy.Add(Review(required[0], "ACCEPTED", 3, 3));
            Check(approves(legacy), "later new acceptance resolves tie");
            legacy.Add(Review(required[0], "FURTHER_REVIEW", 4, 999, legacy: true));
            Check(!approves(legacy), "newer legacy flag supersedes new accepts");
        }
        Check(!IndividualDocumentReviewStore.CanApprove(new string[0], type => true,
            new IndividualDocumentReviewStore.Record[0]), "unsupported identity type");
        Check(IndividualDocumentReviewStore.Decode("Historical informational comparison") == null,
            "unrelated entries do not fabricate decisions");
        Check(IndividualDocumentReviewStore.Decode("[LOCAL DOCUMENT REVIEW: Verified] old whole review") == null,
            "whole and individual review formats are distinct");
        foreach (string decision in new[] { "FURTHER_REVIEW", "REJECTED", "ACCEPTED" })
        {
            Throws(() => IndividualDocumentReviewStore.Encode("PASSPORT_PHOTO", decision, "", 17),
                "mandatory reason");
            Throws(() => IndividualDocumentReviewStore.Encode("PASSPORT_PHOTO", decision, "    ", 17),
                "whitespace reason");
            Throws(() => IndividualDocumentReviewStore.Encode("PASSPORT_PHOTO", decision, "four", 17),
                "short reason");
            Throws(() => IndividualDocumentReviewStore.Encode("PASSPORT_PHOTO", decision, new string('x', 1001), 17),
                "overlong reason");
            Check(IndividualDocumentReviewStore.Decode(IndividualDocumentReviewStore.Encode(
                "PASSPORT_PHOTO", decision, new string('x', 1000), 17)).Reason.Length == 1000,
                "reason upper boundary");
        }
        Throws(() => IndividualDocumentReviewStore.Encode("OTHER", "ACCEPTED", "reason", 17), "document allowlist");
        Throws(() => IndividualDocumentReviewStore.Encode("PASSPORT_PHOTO", "Verified", "reason", 17), "decision allowlist");
        Throws(() => IndividualDocumentReviewStore.Encode("PASSPORT_PHOTO", "ACCEPTED", "reason", 0), "actor required");
        foreach (string notes in new[] {
            "[LOCAL INDIVIDUAL DOCUMENT REVIEW:v2] {}",
            IndividualDocumentReviewStore.Prefix + "{",
            IndividualDocumentReviewStore.Prefix + "null",
            IndividualDocumentReviewStore.Prefix + "{}",
            IndividualDocumentReviewStore.Prefix +
                "{\"DocumentType\":\"OTHER\",\"Decision\":\"ACCEPTED\",\"Reason\":\"reason\",\"ReviewerUserID\":17}"
        })
            Throws(() => IndividualDocumentReviewStore.Decode(notes), "malformed stored history fails closed");
        Console.WriteLine(passed + " offline individual-review format/approval regression checks passed.");
    }
}
