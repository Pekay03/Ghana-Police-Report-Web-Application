using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using PoliceBackgroundCheckSystem.Helpers;

namespace PoliceBackgroundCheckSystem
{
    public partial class IdentityReview : UserControl
    {
        private string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString; }
        }
        private string SelectedReference
        {
            get { return Convert.ToString(ViewState["ReviewReference"]); }
            set { ViewState["ReviewReference"] = value; }
        }
        private string CsrfSessionKey
        {
            get { return "LocalDocumentReviewCsrf:" + Convert.ToString(Session["UserID"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page is AdminDashboard && (Request.QueryString["tab"] != "operations" ||
                Request.QueryString["module"] != "identity"))
            { Visible = false; return; }
            int userId;
            string reviewer;
            if (!StaffAccess.TryUser(Context, false, out userId, out reviewer))
            {
                Visible = false;
                return;
            }
            if (!Page.IsPostBack)
            {
                if (Session[CsrfSessionKey] == null)
                    Session[CsrfSessionKey] = Guid.NewGuid().ToString("N");
                hidReviewCsrf.Value = Convert.ToString(Session[CsrfSessionKey]);
                LoadReviewQueue();
                if (!String.IsNullOrEmpty(Request.QueryString["reference"]))
                {
                    txtReviewReference.Text = Request.QueryString["reference"];
                    btnLoadReview_Click(this, EventArgs.Empty);
                }
            }
        }

        protected void btnLoadReview_Click(object sender, EventArgs e)
        {
            SelectedReference = "";
            pnlReview.Visible = false;
            string reference = txtReviewReference.Text.Trim();
            if (!System.Text.RegularExpressions.Regex.IsMatch(reference, @"\A[A-Za-z0-9_-]{1,50}\z"))
            {
                Message("Enter a valid application reference.");
                return;
            }
            LoadReview(reference);
        }

        private void LoadReview(string reference)
        {
            int actor;
            string name;
            if (!StaffAccess.TryUser(Context, false, out actor, out name))
            {
                Message("Access denied. An active administrator or officer account is required.");
                pnlReview.Visible = false;
                return;
            }
            try
            {
                using (MySqlConnection connection = new MySqlConnection(ConnectionString))
                {
                    connection.Open();
                    DataTable applicant = Query(connection, @"SELECT application_id AS Reference,
                        FullName AS Name, DateOfBirth, Gender, NationalIDType AS IdentityType,
                        GhanaCard AS IdentityNumber, Email, Phone, Purpose, Status AS ApplicationStatus
                        FROM applications WHERE application_id=@Reference;");
                    if (applicant.Rows.Count != 1)
                    {
                        Message("The application was not found.");
                        pnlReview.Visible = false;
                        SelectedReference = "";
                        return;
                    }
                    gvApplicant.DataSource = applicant;
                    gvApplicant.DataBind();
                    // Existing registry results are historical LOCAL comparisons, not official NIA results.
                    DataTable comparison = Query(connection, @"SELECT ApplicantName, RegistryName,
                        ApplicantDateOfBirth, RegistryDateOfBirth, ApplicantGender, RegistryGender,
                        GhanaCardMatch, NameMatch, DateOfBirthMatch, GenderMatch, OverallStatus,
                        VerifiedBy, VerifiedAt FROM identity_verifications
                        WHERE ApplicationReference=@Reference ORDER BY VerificationID DESC LIMIT 1;");
                    gvComparison.DataSource = ComparisonFields(comparison);
                    gvComparison.DataBind();
                    lblComparisonSource.Text = comparison.Rows.Count == 0 ? "No stored local comparison exists." :
                        Server.HtmlEncode("Latest stored local comparison snapshot · " +
                        ComparisonText(comparison.Rows[0]["VerifiedAt"], true) + " · Reviewer: " +
                        ComparisonText(comparison.Rows[0]["VerifiedBy"], false) +
                        ". Historical match flags are not a new check or a document extraction.");
                    gvReviewHistory.DataSource = Query(connection, @"SELECT l.VerificationDate,
                        l.OfficerName AS Reviewer,
                        CASE
                          WHEN l.Notes LIKE '[LOCAL DOCUMENT REVIEW: Verified]%' THEN 'Verified (local only)'
                          WHEN l.Notes LIKE '[LOCAL DOCUMENT REVIEW: Flagged]%' THEN 'Flagged'
                          WHEN l.Notes LIKE '[LOCAL DOCUMENT REVIEW: Rejected]%' THEN 'Rejected'
                          ELSE 'Legacy review (see notes)' END AS Decision,
                        l.IsVerified, l.Notes AS ReasonAndReviewerID
                        FROM verification_log l JOIN applications a ON a.ApplicationID=l.ApplicationID
                        WHERE a.application_id=@Reference ORDER BY l.VerificationDate DESC, l.LogID DESC;");
                    gvReviewHistory.DataBind();
                    DataTable documents = new DataTable();
                    documents.Columns.Add("Label");
                    documents.Columns.Add("Url");
                    documents.Columns.Add("Availability");
                    string[] required = ApplicationDocumentCatalog.RequiredTypes(
                        Convert.ToString(applicant.Rows[0]["IdentityType"]));
                    foreach (string type in required)
                    {
                        bool available = ApplicationDocumentCatalog.FindFile(reference, type) != null;
                        documents.Rows.Add(ApplicationDocumentCatalog.Label(type),
                            available ? ResolveUrl("~/ApplicationDocument.ashx") +
                                "?id=" + Server.UrlEncode(reference) + "&type=" + Server.UrlEncode(type) : "",
                            available ? "Stored document — open preview" : "Missing document");
                    }
                    rptReviewDocuments.DataSource = documents;
                    rptReviewDocuments.DataBind();
                    SelectedReference = reference;
                    lblReviewReference.Text = Server.HtmlEncode(reference);
                    pnlReview.Visible = true;
                    Message("Local document review only. Compare the applicant fields with each submitted document.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Identity workspace failed ({0}).", ex.GetType().Name);
                SelectedReference = "";
                pnlReview.Visible = false;
                Message("The identity workspace is unavailable. Check database and document storage configuration.");
            }
        }

        private DataTable Query(MySqlConnection connection, string sql)
        {
            using (MySqlCommand command = new MySqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Reference", txtReviewReference.Text.Trim());
                using (MySqlDataAdapter adapter = new MySqlDataAdapter(command))
                {
                    DataTable table = new DataTable();
                    adapter.Fill(table);
                    return table;
                }
            }
        }

        private static string ComparisonText(object value, bool date)
        {
            return value == DBNull.Value ? "Not recorded" : date ?
                Convert.ToDateTime(value).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) :
                Convert.ToString(value, CultureInfo.InvariantCulture);
        }

        private static DataTable ComparisonFields(DataTable comparison)
        {
            var fields = new DataTable();
            foreach (string column in new[] { "Field", "ApplicationValue", "ComparedValue", "Result" })
                fields.Columns.Add(column);
            if (comparison.Rows.Count == 0) return fields;
            DataRow row = comparison.Rows[0];
            AddComparison(fields, "Name", row["ApplicantName"], row["RegistryName"], row["NameMatch"], false);
            AddComparison(fields, "Date of birth", row["ApplicantDateOfBirth"], row["RegistryDateOfBirth"], row["DateOfBirthMatch"], true);
            AddComparison(fields, "Gender", row["ApplicantGender"], row["RegistryGender"], row["GenderMatch"], false);
            AddComparison(fields, "Identity number", "Not stored in comparison snapshot",
                "Not stored in comparison snapshot", row["GhanaCardMatch"], false);
            return fields;
        }

        private static void AddComparison(DataTable fields, string field, object submitted, object compared, object flag, bool date)
        {
            fields.Rows.Add(field, ComparisonText(submitted, date), ComparisonText(compared, date),
                flag == DBNull.Value ? "No recorded result" : Convert.ToBoolean(flag) ? "Recorded match" : "Recorded mismatch");
        }

        private void LoadReviewQueue()
        {
            int actor; string name;
            if (!StaffAccess.TryUser(Context, false, out actor, out name)) return;
            try
            {
                using (var c = new MySqlConnection(ConnectionString))
                {
                    c.Open();
                    var rows = AdminWorkflowService.Table(c, null, @"SELECT a.application_id,a.FullName,a.Status,a.DateSubmitted
                        FROM applications a WHERE LOWER(TRIM(a.Status)) IN ('pending','pending approval')
                        AND NOT EXISTS (SELECT 1 FROM verification_log v WHERE v.ApplicationID=a.ApplicationID
                            AND (v.Notes LIKE '[LOCAL DOCUMENT REVIEW:%' OR v.Notes LIKE '[LOCAL INDIVIDUAL DOCUMENT REVIEW:%'))
                        ORDER BY a.DateSubmitted,a.ApplicationID LIMIT 1000;");
                    if (gvIdentityQueue.PageIndex * gvIdentityQueue.PageSize >= rows.Rows.Count) gvIdentityQueue.PageIndex = 0;
                    gvIdentityQueue.DataSource = rows;
                    gvIdentityQueue.DataBind();
                }
            }
            catch (Exception ex)
            {
                gvIdentityQueue.DataSource = null; gvIdentityQueue.DataBind();
                System.Diagnostics.Trace.TraceError("Identity queue unavailable ({0}).", ex.GetType().Name);
                Message("The identity queue is unavailable. Use a known reference only after database access is restored.");
            }
        }

        protected void gvIdentityQueue_PageIndexChanging(object sender, GridViewPageEventArgs e)
        { gvIdentityQueue.PageIndex = e.NewPageIndex; LoadReviewQueue(); }

        protected void gvIdentityQueue_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int actor, index; string name;
            if (!StaffAccess.TryUser(Context, false, out actor, out name) || e.CommandName != "Review" ||
                !Int32.TryParse(Convert.ToString(e.CommandArgument), out index) ||
                index < 0 || index >= gvIdentityQueue.DataKeys.Count) return;
            txtReviewReference.Text = Convert.ToString(gvIdentityQueue.DataKeys[index].Value);
            btnLoadReview_Click(sender, EventArgs.Empty);
        }

        protected void btnSaveReview_Click(object sender, EventArgs e)
        {
            int actor;
            string reviewer;
            if (!StaffAccess.TryUser(Context, false, out actor, out reviewer) ||
                Request.HttpMethod != "POST" ||
                !TokensEqual(hidReviewCsrf.Value, Convert.ToString(Session[CsrfSessionKey])))
            {
                Message("Access denied or expired form. Reload the workspace.");
                return;
            }
            string reference = SelectedReference;
            string decision = ddlReviewDecision.SelectedValue;
            string reason = txtReviewReason.Text.Trim();
            if (String.IsNullOrEmpty(reference) ||
                !String.Equals(reference, txtReviewReference.Text.Trim(), StringComparison.Ordinal))
            {
                Message("Load the application before recording a decision.");
                return;
            }
            if (decision != "Verified" && decision != "Flagged" && decision != "Rejected")
            {
                Message("Select a valid document decision.");
                return;
            }
            if (reason.Length > 1000 || (decision != "Verified" && String.IsNullOrWhiteSpace(reason)))
            {
                Message("Flag/Reject require a reason. Reasons must be at most 1,000 characters.");
                return;
            }
            try
            {
                using (MySqlConnection connection = new MySqlConnection(ConnectionString))
                {
                    connection.Open();
                    using (MySqlTransaction transaction = connection.BeginTransaction())
                    {
                        if (!StaffAccess.CheckUser(connection, transaction, actor, false, out reviewer))
                            throw new UnauthorizedAccessException();
                        int applicationId;
                        string idType;
                        string applicationStatus;
                        using (MySqlCommand command = new MySqlCommand(
                            "SELECT ApplicationID, NationalIDType, Status FROM applications WHERE application_id=@Reference FOR UPDATE;",
                            connection, transaction))
                        {
                            command.Parameters.AddWithValue("@Reference", reference);
                            using (MySqlDataReader reader = command.ExecuteReader())
                            {
                                if (!reader.Read()) throw new InvalidOperationException("Application unavailable.");
                                applicationId = Convert.ToInt32(reader["ApplicationID"]);
                                idType = Convert.ToString(reader["NationalIDType"]);
                                applicationStatus = Convert.ToString(reader["Status"]);
                            }
                        }
                        if (decision == "Verified")
                        {
                            string[] required = ApplicationDocumentCatalog.RequiredTypes(idType);
                            if (required.Length == 0)
                            {
                                Message("The identity type is unsupported; Verified cannot be recorded.");
                                return;
                            }
                            foreach (string type in required)
                                if (ApplicationDocumentCatalog.FindFile(reference, type) == null)
                                {
                                    Message("Verified requires every mandatory document. Missing: " +
                                        ApplicationDocumentCatalog.Label(type) + ".");
                                    return;
                                }
                        }
                        string note = "[LOCAL DOCUMENT REVIEW: " + decision + "] Reviewer user #" +
                            actor.ToString(CultureInfo.InvariantCulture) + ". " +
                            (reason.Length == 0 ? "Document consistency reviewed." : reason);
                        using (MySqlCommand command = new MySqlCommand(
                            @"INSERT INTO verification_log (ApplicationID, OfficerName, VerificationDate, IsVerified, Notes)
                              VALUES (@ApplicationID,@Reviewer,NOW(),@Verified,@Notes);", connection, transaction))
                        {
                            command.Parameters.AddWithValue("@ApplicationID", applicationId);
                            command.Parameters.AddWithValue("@Reviewer", reviewer.Length > 100 ? reviewer.Substring(0, 100) : reviewer);
                            command.Parameters.AddWithValue("@Verified", decision == "Verified" ? 1 : 0);
                            command.Parameters.AddWithValue("@Notes", note);
                            command.ExecuteNonQuery();
                        }
                        using (MySqlCommand command = new MySqlCommand(
                            @"INSERT INTO account_audit_logs (ActorUserID,ActionType,Details,IPAddress,UserAgent,CreatedAt)
                              VALUES (@Actor,@Action,@Details,@IP,@Agent,NOW());", connection, transaction))
                        {
                            command.Parameters.AddWithValue("@Actor", actor);
                            command.Parameters.AddWithValue("@Action", "LocalDocument" + decision);
                            command.Parameters.AddWithValue("@Details", "Application " + reference + ": " + note);
                            command.Parameters.AddWithValue("@IP", Limit(Request.UserHostAddress, 45));
                            command.Parameters.AddWithValue("@Agent", Limit(Request.UserAgent, 255));
                            command.ExecuteNonQuery();
                        }
                        // This must never change applications.Status or overwrite registry comparisons.
                        AdminWorkflowService.AppendWorkflow(connection, transaction, applicationId, actor,
                            "DocumentSet" + decision, applicationStatus, applicationStatus, note);
                        transaction.Commit();
                    }
                }
                txtReviewReason.Text = "";
                LoadReview(reference);
                LoadReviewQueue();
                Message("Local document decision saved with reviewer, reason and timestamp. Application status is unchanged.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Local document decision failed ({0}).", ex.GetType().Name);
                Message("The decision could not be saved. No partial decision was committed.");
            }
        }

        private static string Limit(string value, int maximum)
        {
            return value == null ? "" : value.Substring(0, Math.Min(value.Length, maximum));
        }
        internal static bool TokensEqual(string left, string right)
        {
            if (String.IsNullOrEmpty(left) || String.IsNullOrEmpty(right) || left.Length != right.Length) return false;
            int difference = 0;
            for (int i = 0; i < left.Length; i++) difference |= left[i] ^ right[i];
            return difference == 0;
        }
        private void Message(string text)
        {
            lblReviewMessage.Text = Server.HtmlEncode(text);
        }
    }
}
