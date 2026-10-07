using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public partial class AdminDashboard : Page
    {
        private readonly string connStr =
            System.Configuration.ConfigurationManager
            .ConnectionStrings["PoliceReportDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAdmin())
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadIdentity();
                LoadDashboard();
                LoadRecentApplications();
                LoadRegions();
                LoadUserTab();
                LoadAuditLog();
                LoadDocumentReviewMetrics();
                LoadActivityLog();
                int staff;
                if (Request.QueryString["tab"] == "users" &&
                    Int32.TryParse(Request.QueryString["staff"], out staff) && staff > 0)
                    userManagement.InspectAccount(staff);
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (!IsAdmin()) return;
            var indicators = new DataTable();
            indicators.Columns.Add("Label");
            indicators.Columns.Add("Value");
            indicators.Columns.Add("Url");
            try
            {
                using (var c = new MySqlConnection(connStr))
                {
                    c.Open();
                    var queue = AdminWorkspaceData.Queue(c);
                    string[] names = { "Urgent pending", "Unassigned pending", "No local review", "Exceeding target" };
                    string[] links = { "applications&priority=Urgent", "applications&assignment=Unassigned", "identity", "applications&processing=OverTarget" };
                    for (int i = 0; i < names.Length; i++)
                        indicators.Rows.Add(names[i], Convert.ToString(queue.Rows[i]["Applications"]),
                            "AdminDashboard.aspx?tab=operations&module=" + links[i]);
                    indicators.Rows.Add("Failed SMS", OperationalCount(c, "SELECT COUNT(*) FROM sms_delivery_logs WHERE Status='Failed';"),
                        "AdminDashboard.aspx?tab=operations&module=notifications");
                    indicators.Rows.Add("Currently locked", OperationalCount(c, "SELECT COUNT(*) FROM users WHERE LockedUntil>NOW();"),
                        "AdminDashboard.aspx?tab=operations&module=security");
                }
            }
            catch (Exception ex)
            {
                indicators.Clear();
                indicators.Rows.Add("Operational indicators", "Unavailable", "AdminDashboard.aspx?tab=operations&module=applications");
                System.Diagnostics.Trace.TraceError("Operational overview unavailable ({0}).", ex.GetType().Name);
            }
            rptOperationalIndicators.DataSource = indicators;
            rptOperationalIndicators.DataBind();
        }

        private static string OperationalCount(MySqlConnection c, string sql)
        {
            using (var command = new MySqlCommand(sql, c))
                return Convert.ToString(command.ExecuteScalar(), System.Globalization.CultureInfo.InvariantCulture);
        }

        private bool IsAdmin()
        {
            int actor;
            string name;
            return StaffAccess.TryUser(Context, true, out actor, out name);
        }

        internal void InspectManagedApplication(string reference)
        {
            OpenInspection(reference);
        }

        protected void inspectManagement_Saved(object sender, EventArgs e)
        {
            string reference = inspectManagement.Reference;
            OpenInspection(reference);
            adminOperations.RefreshSelected();
            LoadAuditLog();
            LoadActivityLog();
        }

        private void LoadIdentity()
        {
            string name = Convert.ToString(Session["FullName"]);

            if (string.IsNullOrWhiteSpace(name))
                name = Convert.ToString(Session["Username"]);

            if (string.IsNullOrWhiteSpace(name))
                name = "System Administrator";

            lblAdminName.Text = Server.HtmlEncode(name);
            lblDashboardDate.Text = DateTime.Now.ToString("dd MMM yyyy");
        }

        private void LoadDashboard()
        {
            SetZeroDashboard();

            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();

                    int totalApps = ExecuteCount(conn, "SELECT COUNT(*) FROM applications;");
                    int pending = ExecuteCount(conn,
                        "SELECT COUNT(*) FROM applications WHERE LOWER(TRIM(COALESCE(Status,''))) IN ('pending','pending approval');");
                    int approved = ExecuteCount(conn,
                        "SELECT COUNT(*) FROM applications WHERE LOWER(TRIM(COALESCE(Status,'')))='approved';");
                    int rejected = ExecuteCount(conn,
                        "SELECT COUNT(*) FROM applications WHERE LOWER(TRIM(COALESCE(Status,'')))='rejected';");

                    int citizens = SafeUserCount(conn,
                        "SELECT COUNT(*) FROM users WHERE LOWER(TRIM(COALESCE(Role,'')))='citizen';");
                    int officers = SafeUserCount(conn,
                        "SELECT COUNT(*) FROM users WHERE IsActive=1 AND LOWER(REPLACE(REPLACE(REPLACE(TRIM(COALESCE(Role,'')), ' ', ''), '-', ''), '_', '')) IN ('policeofficer','officer','vettingofficer','policeofficer/admin');");
                    int admins = SafeUserCount(conn,
                        "SELECT COUNT(*) FROM users WHERE LOWER(REPLACE(REPLACE(REPLACE(TRIM(COALESCE(Role,'')), ' ', ''), '-', ''), '_', '')) IN ('admin','administrator','systemadmin');");

                    int totalUsers = SafeUserCount(conn, "SELECT COUNT(*) FROM users;");

                    lblTotalUsers.Text = totalUsers.ToString();
                    lblRegisteredCitizens.Text = citizens.ToString();
                    lblActiveOfficers.Text = officers.ToString();
                    lblAdmins.Text = admins.ToString();

                    lblApplicationsSubmitted.Text = totalApps.ToString();
                    lblIncoming.Text = pending.ToString();
                    lblApprovedReview.Text = approved.ToString();
                    lblRejectedReview.Text = rejected.ToString();

                    lblUsersTabTotal.Text = totalUsers.ToString();
                    lblUsersTabCitizens.Text = citizens.ToString();
                    lblUsersTabOfficers.Text = officers.ToString();
                    lblUsersTabAdmins.Text = admins.ToString();

                    int employment = ExecuteCount(conn,
                        "SELECT COUNT(*) FROM applications WHERE LOWER(TRIM(COALESCE(Purpose,'')))='employment';");
                    int travel = ExecuteCount(conn,
                        "SELECT COUNT(*) FROM applications WHERE LOWER(TRIM(COALESCE(Purpose,''))) IN ('travel/visa','travel','visa');");
                    int education = ExecuteCount(conn,
                        "SELECT COUNT(*) FROM applications WHERE LOWER(TRIM(COALESCE(Purpose,''))) IN ('education background','education');");
                    int other = ExecuteCount(conn,
                        "SELECT COUNT(*) FROM applications WHERE LOWER(TRIM(COALESCE(Purpose,'')))='other';");

                    lblEmployment.Text = employment.ToString();
                    lblTravel.Text = travel.ToString();
                    lblEducation.Text = education.ToString();
                    lblOther.Text = other.ToString();

                    SetWidth(barEmployment, employment, totalApps);
                    SetWidth(barTravel, travel, totalApps);
                    SetWidth(barEducation, education, totalApps);
                    SetWidth(barOther, other, totalApps);

                    SetPercent(lblApprovedPercent, progressApproved, approved, totalApps);
                    SetPercent(lblRejectedPercent, progressRejected, rejected, totalApps);
                    SetPercent(lblPendingPercent, progressPending, pending, totalApps);

                    int verifiedPayments = SafeUserCount(conn,
                        "SELECT COUNT(*) FROM payments WHERE PaymentVerified=1 AND TransactionID LIKE 'HBT-%';");
                    int totalPayments = SafeUserCount(conn,
                        "SELECT COUNT(*) FROM payments;");

                    SetPercent(lblPaymentPercent, progressPayment, verifiedPayments, totalPayments);

                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Dashboard statistics unavailable ({0}).", ex.GetType().Name);
                SetZeroDashboard();
                ShowDashboardMessage("Dashboard statistics are unavailable. Check the database configuration; unavailable values are not reported as zero.");
            }
        }

        private void LoadRecentApplications()
        {
            try
            {
                DataTable table = new DataTable();

                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();

                    const string sql = @"
                        SELECT application_id, FullName, Purpose, Status, DateSubmitted
                        FROM applications
                        ORDER BY DateSubmitted DESC, ApplicationID DESC
                        LIMIT 5;";

                    using (MySqlDataAdapter adapter =
                           new MySqlDataAdapter(sql, conn))
                    {
                        adapter.Fill(table);
                    }
                }

                table.Columns.Add("ApplicationDisplay");
                table.Columns.Add("StatusDisplay");
                table.Columns.Add("DateSubmittedDisplay");

                foreach (DataRow row in table.Rows)
                {
                    row["ApplicationDisplay"] = Convert.ToString(row["application_id"]);
                    row["StatusDisplay"] = NormalizeStatus(Convert.ToString(row["Status"]));
                    row["DateSubmittedDisplay"] = FormatDateTime(row["DateSubmitted"]);
                }

                rptRecentApplications.DataSource = table;
                rptRecentApplications.DataBind();
            }
            catch (Exception ex)
            {
                rptRecentApplications.DataSource = null;
                rptRecentApplications.DataBind();
                ShowDashboardMessage("Recent applications could not be loaded. " + ex.Message);
            }
        }

        private void LoadRegions()
        {
            DataTable regions = new DataTable();
            regions.Columns.Add("Region");
            regions.Columns.Add("Count", typeof(int));
            regions.Columns.Add("Share");
            regions.Columns.Add("HeatWidth");

            string[] names =
            {
                "Greater Accra","Ashanti","Eastern","Western",
                "Central","Volta","Northern","Upper East",
                "Upper West","Bono","Bono East","Ahafo",
                "Western North","Oti","Savannah","North East"
            };

            int[] counts = new int[names.Length];

            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();

                    const string sql = @"
                        SELECT GPSAddress
                        FROM applications
                        WHERE GPSAddress IS NOT NULL
                          AND TRIM(GPSAddress) <> '';";

                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string gps = Convert.ToString(reader["GPSAddress"]);
                            string region = RegionFromGps(gps);

                            for (int i = 0; i < names.Length; i++)
                            {
                                if (string.Equals(names[i], region, StringComparison.OrdinalIgnoreCase))
                                {
                                    counts[i]++;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Regional data unavailable ({0}).", ex.GetType().Name);
                rptRegions.DataSource = null;
                rptRegions.DataBind();
                ShowDashboardMessage("Regional statistics are unavailable; no substitute counts are shown.");
                return;
            }

            int totalMapped = 0;
            int max = 0;

            foreach (int count in counts)
            {
                totalMapped += count;
                if (count > max) max = count;
            }

            for (int i = 0; i < names.Length; i++)
            {
                DataRow row = regions.NewRow();
                row["Region"] = names[i];
                row["Count"] = counts[i];
                row["Share"] = totalMapped == 0
                    ? "0%"
                    : Math.Round(counts[i] * 100.0 / totalMapped, 1).ToString("0.0") + "%";
                row["HeatWidth"] = max == 0
                    ? "0%"
                    : Math.Max(5, Math.Round(counts[i] * 100.0 / max, 0)) + "%";
                regions.Rows.Add(row);
            }

            rptRegions.DataSource = regions;
            rptRegions.DataBind();
        }

        private string RegionFromGps(string gps)
        {
            if (string.IsNullOrWhiteSpace(gps))
                return "";

            string value = gps.Trim().ToUpperInvariant();

            if (value.StartsWith("GA") || value.StartsWith("GT")) return "Greater Accra";
            if (value.StartsWith("AK") || value.StartsWith("AS")) return "Ashanti";
            if (value.StartsWith("ER")) return "Eastern";
            if (value.StartsWith("WR")) return "Western";
            if (value.StartsWith("CR")) return "Central";
            if (value.StartsWith("VR")) return "Volta";
            if (value.StartsWith("NR")) return "Northern";
            if (value.StartsWith("UE")) return "Upper East";
            if (value.StartsWith("UW")) return "Upper West";
            if (value.StartsWith("BE")) return "Bono East";
            if (value.StartsWith("BA")) return "Bono";
            if (value.StartsWith("AH")) return "Ahafo";
            if (value.StartsWith("WN")) return "Western North";
            if (value.StartsWith("OT")) return "Oti";
            if (value.StartsWith("SV")) return "Savannah";
            if (value.StartsWith("NE")) return "North East";

            return "";
        }

        private void LoadUserTab()
        {
            // Values are loaded together with the main dashboard.
        }

        private void LoadDocumentReviewMetrics()
        {
            lblManualDocumentReviews.Text = "—";
            lblManualDocumentReviewsToday.Text = "—";

            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    lblManualDocumentReviews.Text =
                        ExecuteCount(
                            conn,
                            "SELECT COUNT(*) FROM verification_log WHERE Notes LIKE '[LOCAL DOCUMENT REVIEW:%';")
                        .ToString();
                    lblManualDocumentReviewsToday.Text =
                        ExecuteCount(
                            conn,
                            "SELECT COUNT(*) FROM verification_log WHERE Notes LIKE '[LOCAL DOCUMENT REVIEW:%' AND VerificationDate >= CURDATE();")
                        .ToString();
                }
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Document review metrics could not be loaded (MySQL error {0}).",
                    ex.Number);
            }
        }

        private void LoadActivityLog()
        {
            DataTable table = new DataTable();
            try
            {
                string search = txtActivitySearch.Text.Trim();
                string action = string.IsNullOrWhiteSpace(
                    ddlActivityAction.SelectedValue)
                    ? "All"
                    : ddlActivityAction.SelectedValue;
                string period = string.IsNullOrWhiteSpace(
                    ddlActivityPeriod.SelectedValue)
                    ? "All"
                    : ddlActivityPeriod.SelectedValue;

                const string sql = @"
                    SELECT
                        l.AuditID,
                        l.ActionType,
                        CASE
                            WHEN l.ActorUserID IS NULL THEN 'System'
                            WHEN NULLIF(TRIM(CONCAT(
                                COALESCE(u.FirstName, ''), ' ',
                                COALESCE(u.LastName, ''))), '') IS NULL
                                THEN CONCAT('User #', l.ActorUserID)
                            ELSE TRIM(CONCAT(
                                COALESCE(u.FirstName, ''), ' ',
                                COALESCE(u.LastName, '')))
                        END AS ActorName,
                        COALESCE(l.Details, '') AS Details,
                        l.CreatedAt
                    FROM account_audit_logs l
                    LEFT JOIN users u ON u.UserID = l.ActorUserID
                    WHERE (@Action='All' OR l.ActionType=@Action)
                      AND (@Search='' OR
                           l.ActionType LIKE CONCAT('%',@Search,'%') OR
                           COALESCE(l.Details,'') LIKE CONCAT('%',@Search,'%') OR
                           COALESCE(u.FirstName,'') LIKE CONCAT('%',@Search,'%') OR
                           COALESCE(u.LastName,'') LIKE CONCAT('%',@Search,'%') OR
                           CAST(l.ActorUserID AS CHAR) LIKE CONCAT('%',@Search,'%'))
                      AND (@Period='All' OR
                           (@Period='Today' AND l.CreatedAt >= CURDATE()) OR
                           (@Period='7' AND l.CreatedAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)) OR
                           (@Period='30' AND l.CreatedAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)) OR
                           (@Period='90' AND l.CreatedAt >= DATE_SUB(NOW(), INTERVAL 90 DAY)))
                    ORDER BY l.CreatedAt DESC, l.AuditID DESC
                    LIMIT 1000;";

                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Action", action);
                        cmd.Parameters.AddWithValue("@Search", search);
                        cmd.Parameters.AddWithValue("@Period", period);
                        using (MySqlDataAdapter adapter =
                               new MySqlDataAdapter(cmd))
                        {
                            adapter.Fill(table);
                        }
                    }
                }

                table.Columns.Add("CreatedAtDisplay", typeof(string));
                foreach (DataRow row in table.Rows)
                {
                    row["CreatedAtDisplay"] =
                        FormatDateTime(row["CreatedAt"]);
                }

                gvActivityLog.DataSource = table;
                gvActivityLog.DataBind();
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Activity log could not be loaded (MySQL error {0}).",
                    ex.Number);
                gvActivityLog.DataSource = null;
                gvActivityLog.DataBind();
                ShowDashboardMessage(
                    "The activity log is unavailable. Confirm that DatabaseMigration.sql has been applied.");
            }
        }

        protected void btnActivitySearch_Click(object sender, EventArgs e)
        {
            gvActivityLog.PageIndex = 0;
            LoadActivityLog();
        }

        protected void btnActivityClear_Click(object sender, EventArgs e)
        {
            txtActivitySearch.Text = string.Empty;
            ddlActivityAction.SelectedIndex = 0;
            ddlActivityPeriod.SelectedIndex = 0;
            gvActivityLog.PageIndex = 0;
            LoadActivityLog();
        }

        protected void gvActivityLog_PageIndexChanging(
            object sender,
            GridViewPageEventArgs e)
        {
            gvActivityLog.PageIndex = e.NewPageIndex;
            LoadActivityLog();
        }

        private void LoadAuditLog()
        {
            try
            {
                DataTable table = new DataTable();

                string search = txtAuditSearch.Text.Trim();
                string status = string.IsNullOrWhiteSpace(ddlAuditStatus.SelectedValue)
                    ? "All"
                    : ddlAuditStatus.SelectedValue;
                string purpose = string.IsNullOrWhiteSpace(ddlAuditPurpose.SelectedValue)
                    ? "All"
                    : ddlAuditPurpose.SelectedValue;
                string period = string.IsNullOrWhiteSpace(ddlAuditPeriod.SelectedValue)
                    ? "All"
                    : ddlAuditPeriod.SelectedValue;

                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();

                    string sql = @"
                        SELECT
                            application_id,
                            FullName,
                            Purpose,
                            Status,
                            DateSubmitted,
                            ReviewedBy
                        FROM applications
                        WHERE
                            (@Search='' OR
                             application_id LIKE CONCAT('%',@Search,'%') OR
                             FullName LIKE CONCAT('%',@Search,'%') OR
                             GhanaCard LIKE CONCAT('%',@Search,'%'))
                        AND
                            (
                                @Status='All'
                                OR (@Status='Pending' AND LOWER(TRIM(COALESCE(Status,''))) IN ('pending','pending approval'))
                                OR (@Status='Approved' AND LOWER(TRIM(COALESCE(Status,'')))='approved')
                                OR (@Status='Rejected' AND LOWER(TRIM(COALESCE(Status,'')))='rejected')
                            )
                        AND
                            (
                                @Purpose='All'
                                OR (@Purpose='Employment' AND LOWER(TRIM(COALESCE(Purpose,'')))='employment')
                                OR (@Purpose='Travel/Visa' AND LOWER(TRIM(COALESCE(Purpose,''))) IN ('travel/visa','travel','visa'))
                                OR (@Purpose='Education Background' AND LOWER(TRIM(COALESCE(Purpose,''))) IN ('education background','education'))
                                OR (@Purpose='Other' AND LOWER(TRIM(COALESCE(Purpose,'')))='other')
                            )
                        AND
                            (
                                @Period='All'
                                OR (@Period='Today' AND DateSubmitted >= CURDATE())
                                OR (@Period='7' AND DateSubmitted >= DATE_SUB(NOW(), INTERVAL 7 DAY))
                                OR (@Period='30' AND DateSubmitted >= DATE_SUB(NOW(), INTERVAL 30 DAY))
                                OR (@Period='90' AND DateSubmitted >= DATE_SUB(NOW(), INTERVAL 90 DAY))
                            )
                        ORDER BY DateSubmitted DESC, application_id DESC;";

                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Search", search);
                        cmd.Parameters.AddWithValue("@Status", status);
                        cmd.Parameters.AddWithValue("@Purpose", purpose);
                        cmd.Parameters.AddWithValue("@Period", period);

                        using (MySqlDataAdapter adapter =
                               new MySqlDataAdapter(cmd))
                        {
                            adapter.Fill(table);
                        }
                    }
                }

                table.Columns.Add("ApplicationDisplay");
                table.Columns.Add("PurposeDisplay");
                table.Columns.Add("StatusDisplay");
                table.Columns.Add("DateSubmittedDisplay");

                foreach (DataRow row in table.Rows)
                {
                    row["ApplicationDisplay"] = Convert.ToString(row["application_id"]);
                    row["PurposeDisplay"] = NormalizePurpose(Convert.ToString(row["Purpose"]));
                    row["StatusDisplay"] = NormalizeStatus(Convert.ToString(row["Status"]));
                    row["DateSubmittedDisplay"] = FormatDateTime(row["DateSubmitted"]);
                }

                gvAudit.DataSource = table;
                gvAudit.DataBind();
            }
            catch (Exception ex)
            {
                gvAudit.DataSource = null;
                gvAudit.DataBind();
                System.Diagnostics.Trace.TraceError(
                    "Application monitoring could not be loaded ({0}).",
                    ex.GetType().Name);
                ShowDashboardMessage("Application monitoring is unavailable. Check the database configuration.");
            }
        }

        protected void btnAuditSearch_Click(object sender, EventArgs e)
        {
            gvAudit.PageIndex = 0;
            LoadAuditLog();
        }

        protected void btnAuditClear_Click(object sender, EventArgs e)
        {
            txtAuditSearch.Text = "";
            ddlAuditStatus.SelectedIndex = 0;
            ddlAuditPurpose.SelectedIndex = 0;
            ddlAuditPeriod.SelectedIndex = 0;
            gvAudit.PageIndex = 0;
            LoadAuditLog();
        }

        protected void gvAudit_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAudit.PageIndex = e.NewPageIndex;
            LoadAuditLog();
        }

        protected void gvAudit_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("Inspect", StringComparison.OrdinalIgnoreCase))
                OpenInspection(Convert.ToString(e.CommandArgument));
        }

        private void OpenInspection(string applicationId)
        {
            if (!IsAdmin()) return;
            if (string.IsNullOrWhiteSpace(applicationId))
                return;

            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();

                    const string sql = @"
                        SELECT *
                        FROM applications
                        WHERE application_id=@ApplicationId
                        LIMIT 1;";

                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ApplicationId", applicationId);

                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                ShowDashboardMessage("The selected application could not be found.");
                                return;
                            }

                            lblInspectApplicationId.Text = Encode(reader["application_id"]);
                            lblInspectName.Text = Encode(reader["FullName"]);
                            lblInspectStatus.Text = NormalizeStatus(Convert.ToString(reader["Status"]));
                            lblInspectGender.Text = Encode(reader["Gender"]);
                            lblInspectDob.Text = FormatDate(reader["DateOfBirth"]);
                            lblInspectIdType.Text = Encode(reader["NationalIDType"]);
                            lblInspectId.Text = MaskId(Convert.ToString(reader["GhanaCard"]));
                            lblInspectPurpose.Text = NormalizePurpose(Convert.ToString(reader["Purpose"]));
                            lblInspectSubmitted.Text = FormatDateTime(reader["DateSubmitted"]);
                            lblInspectEmail.Text = Encode(reader["Email"]);
                            lblInspectPhone.Text = Encode(reader["Phone"]);
                            lblInspectGps.Text = Encode(reader["GPSAddress"]);
                            lblInspectReviewedBy.Text = Encode(reader["ReviewedBy"]);
                            lblInspectReviewedAt.Text = FormatDateTime(reader["ReviewedAt"]);
                            lblInspectReviewNotes.Text = Encode(reader["ReviewNotes"]);
                            lblInspectRejectionReason.Text = Encode(reader["RejectionReason"]);
                            lblInspectMaritalStatus.Text = Encode(reader["MaritalStatus"]);
                            lblInspectPlaceOfBirth.Text = Encode(reader["PlaceOfBirth"]);
                            lblInspectProfession.Text = Encode(reader["Profession"]);
                            lblInspectNextOfKinName.Text = Encode(reader["NextOfKinName"]);
                            lblInspectNextOfKinPhone.Text = Encode(reader["NextOfKinPhone"]);
                            lblInspectIdIssueDate.Text = FormatDate(reader["IDIssueDate"]);
                            lblInspectIdIssueLocation.Text = Encode(reader["IDIssueLocation"]);
                            lblInspectEmployerName.Text = Encode(reader["EmployerName"]);
                            lblInspectEmploymentPosition.Text = Encode(reader["EmploymentPosition"]);
                            lblInspectEmployerAddress.Text = Encode(reader["EmployerAddress"]);
                            lblInspectInstitutionName.Text = Encode(reader["InstitutionName"]);
                            lblInspectProgrammeName.Text = Encode(reader["ProgrammeName"]);
                            lblInspectStudentId.Text = Encode(reader["StudentID"]);
                            lblInspectDestinationCountry.Text = Encode(reader["DestinationCountry"]);
                            lblInspectVisaType.Text = Encode(reader["VisaType"]);
                            lblInspectTravelDate.Text = FormatDate(reader["TravelDate"]);
                            lblInspectOtherPurpose.Text = Encode(reader["OtherPurpose"]);
                        }
                    }

                    LoadRelatedInspectionData(conn, applicationId);
                    LoadInspectionTimeline(conn, applicationId);
                    LoadInspectionDocuments(conn, applicationId, Server.HtmlDecode(lblInspectIdType.Text));
                    inspectManagement.LoadApplication(applicationId);
                    hlInspectIdentityReview.NavigateUrl = "AdminDashboard.aspx?tab=operations&module=identity&reference=" +
                        Server.UrlEncode(applicationId);
                }

                pnlInspectModal.Visible = true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Admin inspection failed ({0}).", ex.GetType().Name);
                ShowDashboardMessage("Application inspection could not be opened. Check database and document-store availability.");
            }
        }

        private void LoadInspectionDocuments(MySqlConnection connection, string applicationId, string idType)
        {
            DataTable documents = new DataTable();
            documents.Columns.Add("DocumentName", typeof(string));
            documents.Columns.Add("DocumentUrl", typeof(string));
            string[] required = Helpers.ApplicationDocumentCatalog.RequiredTypes(idType);
            List<string> missing = new List<string>();
            foreach (string type in required)
            {
                string label = Helpers.ApplicationDocumentCatalog.Label(type);
                if (Helpers.ApplicationDocumentCatalog.FindFile(applicationId, type) == null)
                {
                    missing.Add(label);
                    continue;
                }
                documents.Rows.Add(label, ResolveUrl("~/ApplicationDocument.ashx") +
                    "?id=" + HttpUtility.UrlEncode(applicationId) +
                    "&type=" + HttpUtility.UrlEncode(type));
            }
            rptInspectDocuments.DataSource = documents;
            rptInspectDocuments.DataBind();
            lblInspectDocumentsStatus.Text = required.Length == 0
                ? "This record does not contain a supported ID type."
                : documents.Rows.Count + " of " + required.Length + " required files available." +
                    (missing.Count == 0 ? "" : " Missing: " + Server.HtmlEncode(String.Join(", ", missing)) + ".");
            DataTable reviews = new DataTable();
            reviews.Columns.Add("DocumentType", typeof(string));
            reviews.Columns.Add("ReviewDecision", typeof(string));
            reviews.Columns.Add("ReviewReason", typeof(string));
            reviews.Columns.Add("ReviewerName", typeof(string));
            reviews.Columns.Add("ReviewedAt", typeof(DateTime));
            try
            {
                foreach (var review in IndividualDocumentReviewStore.Load(connection, null, applicationId))
                {
                    if (review.WholeSet) continue;
                    reviews.Rows.Add(Helpers.ApplicationDocumentCatalog.Label(review.DocumentType),
                        review.Decision, review.ReviewReason, review.ReviewerName, review.ReviewedAt);
                }
                gvInspectDocumentReviews.EmptyDataText = "No officer document reviews have been recorded.";
            }
            catch (Exception ex)
            {
                reviews.Rows.Clear();
                System.Diagnostics.Trace.TraceError("Inspection document-review query failed ({0}).", ex.GetType().Name);
                gvInspectDocumentReviews.EmptyDataText = "Document review history is unavailable; check existing review storage.";
            }
            gvInspectDocumentReviews.DataSource = reviews;
            gvInspectDocumentReviews.DataBind();
        }

        private void LoadRelatedInspectionData(MySqlConnection conn, string applicationId)
        {
            lblInspectVerification.Text = "No local record comparison";
            lblInspectPayment.Text = "No payment record";
            lblInspectCertificate.Text = "Not issued";

            try
            {
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT OverallStatus, VerifiedBy, VerifiedAt,
                           GhanaCardMatch, NameMatch, DateOfBirthMatch, GenderMatch
                    FROM identity_verifications
                    WHERE ApplicationReference=@Id
                    ORDER BY VerificationID DESC
                    LIMIT 1;", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", applicationId);

                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblInspectVerification.Text =
                                "Local comparison: " +
                                (Convert.ToString(reader["OverallStatus"]).Equals(
                                    "Verified", StringComparison.OrdinalIgnoreCase)
                                    ? "Legacy local match"
                                    : Encode(reader["OverallStatus"])) + " · " +
                                Encode(reader["VerifiedBy"]) + " · " +
                                FormatDateTime(reader["VerifiedAt"]) +
                                " · ID: " + Encode(reader["GhanaCardMatch"]) +
                                "; name: " + Encode(reader["NameMatch"]) +
                                "; date of birth: " + Encode(reader["DateOfBirthMatch"]) +
                                "; gender: " + Encode(reader["GenderMatch"]);
                        }
                    }
                }
            }
            catch { }

            try
            {
                int internalId = GetInternalApplicationId(conn, applicationId);

                if (internalId > 0)
                {
                    using (MySqlCommand cmd = new MySqlCommand(@"
                        SELECT PaymentMethod, TransactionID, AmountPaid,
                               PaymentDate, PaymentVerified
                        FROM payments
                        WHERE ApplicationID=@Id
                        ORDER BY PaymentID DESC
                        LIMIT 1;", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", internalId);

                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblInspectPayment.Text =
                                    Encode(reader["PaymentMethod"]) +
                                    " · GHS " +
                                    Convert.ToDecimal(reader["AmountPaid"]).ToString("0.00") +
                                    " · " +
                                    Encode(reader["TransactionID"]) +
                                    (!Convert.ToString(reader["TransactionID"]).StartsWith("HBT-", StringComparison.Ordinal)
                                        ? " · Legacy record — no Hubtel confirmation"
                                        : Convert.ToInt32(reader["PaymentVerified"]) == 1
                                            ? " · Hubtel-confirmed paid"
                                            : Convert.ToInt32(reader["PaymentVerified"]) == 2
                                                ? " · Failed/cancelled"
                                                : " · Awaiting Hubtel confirmation");
                            }
                        }
                    }
                }
            }
            catch { }

            try
            {
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT CertificateReference, CertificateStatus, IssueDate
                    FROM certificates
                    WHERE ApplicationReference=@Id
                    ORDER BY CertificateID DESC
                    LIMIT 1;", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", applicationId);

                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblInspectCertificate.Text =
                                Encode(reader["CertificateReference"]) +
                                " · " +
                                Encode(reader["CertificateStatus"]) +
                                " · " +
                                FormatDateTime(reader["IssueDate"]);
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadInspectionTimeline(MySqlConnection conn, string applicationId)
        {
            DataTable table = new DataTable();

            table.Columns.Add("EventType");
            table.Columns.Add("EventText");
            table.Columns.Add("EventTime", typeof(DateTime));
            table.Columns.Add("EventTimeDisplay");

            const string sql = @"
                SELECT 'Application submitted' AS EventType,
                       CONCAT('Citizen submitted ', FullName, ' for ', Purpose) AS EventText,
                       DateSubmitted AS EventTime
                FROM applications
                WHERE application_id=@Id

                UNION ALL

                SELECT 'Police review' AS EventType,
                       CONCAT('Decision: ', Status, ' by ', COALESCE(ReviewedBy,'Officer')) AS EventText,
                       ReviewedAt AS EventTime
                FROM applications
                WHERE application_id=@Id
                  AND ReviewedAt IS NOT NULL

                UNION ALL

                SELECT 'Local record comparison' AS EventType,
                       CONCAT('Non-authoritative local result: ',
                              CASE WHEN OverallStatus='Verified' THEN 'Legacy local match' ELSE OverallStatus END,
                              ' by ', COALESCE(VerifiedBy,'Officer')) AS EventText,
                       VerifiedAt AS EventTime
                FROM identity_verifications
                WHERE ApplicationReference=@Id

                UNION ALL

                SELECT 'Payment' AS EventType,
                       CONCAT('Payment ', TransactionID, ' · GHS ', AmountPaid) AS EventText,
                       PaymentDate AS EventTime
                FROM payments p
                INNER JOIN applications a
                    ON a.ApplicationID=p.ApplicationID
                WHERE a.application_id=@Id

                UNION ALL

                SELECT 'Certificate' AS EventType,
                       CONCAT('Certificate ', CertificateReference, ' issued') AS EventText,
                       IssueDate AS EventTime
                FROM certificates
                WHERE ApplicationReference=@Id

                ORDER BY EventTime;";

            try
            {
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", applicationId);

                    using (MySqlDataAdapter adapter =
                           new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(table);
                    }
                }

                foreach (var review in IndividualDocumentReviewStore.Load(conn, null, applicationId))
                {
                    table.Rows.Add(review.WholeSet ? "Local document-set review" : "Manual document review",
                        (review.WholeSet ? "" : Helpers.ApplicationDocumentCatalog.Label(review.DocumentType) + ": ") +
                        review.Decision + " by " + review.ReviewerName +
                        (review.ReviewerUserID > 0 ? " (account #" + review.ReviewerUserID + ")" : "") +
                        ". " + review.ReviewReason, review.ReviewedAt);
                }

                DataTable workflow = AdminWorkflowService.Table(conn, null, @"SELECT w.ActionType,
                    CONCAT(COALESCE(w.FromStatus,''),' → ',COALESCE(w.ToStatus,''),' · ',
                        u.FirstName,' ',u.LastName,' (#',w.ActionByUserID,'). ',COALESCE(w.Notes,'')) AS Detail,
                    w.ActionAt FROM application_workflow_history w JOIN users u ON u.UserID=w.ActionByUserID
                    JOIN applications a ON a.ApplicationID=w.ApplicationID WHERE a.application_id=@Reference
                    ORDER BY w.ActionAt,w.WorkflowID;", "@Reference", applicationId);
                foreach (DataRow row in workflow.Rows)
                    table.Rows.Add(Convert.ToString(row["ActionType"]), Convert.ToString(row["Detail"]), row["ActionAt"]);

                // Retain the legacy facts without rewriting/backfilling them; merge in new recorded events.
                table.DefaultView.Sort = "EventTime ASC";
                table = table.DefaultView.ToTable();

                foreach (DataRow row in table.Rows)
                    row["EventTimeDisplay"] = FormatDateTime(row["EventTime"]);
            }
            catch (Exception ex)
            {
                table.Rows.Clear();
                System.Diagnostics.Trace.TraceError("Inspection timeline unavailable ({0}).", ex.GetType().Name);
                table.Rows.Add("History unavailable",
                    "The recorded timeline could not be read. Contact the database administrator.",
                    DBNull.Value, "");
            }

            rptInspectTimeline.DataSource = table;
            rptInspectTimeline.DataBind();
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlInspectModal.Visible = false;
        }

        private int GetInternalApplicationId(MySqlConnection conn, string applicationId)
        {
            using (MySqlCommand cmd = new MySqlCommand(@"
                SELECT ApplicationID
                FROM applications
                WHERE application_id=@Id
                LIMIT 1;", conn))
            {
                cmd.Parameters.AddWithValue("@Id", applicationId);

                object value = cmd.ExecuteScalar();

                if (value == null || value == DBNull.Value)
                    return 0;

                return Convert.ToInt32(value);
            }
        }

        private int ExecuteCount(MySqlConnection conn, string sql)
        {
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                object value = cmd.ExecuteScalar();

                if (value == null || value == DBNull.Value)
                    return 0;

                return Convert.ToInt32(value);
            }
        }

        private int SafeUserCount(MySqlConnection conn, string sql)
        {
            return ExecuteCount(conn, sql);
        }

        private void SetWidth(HtmlGenericControl control, int value, int total)
        {
            int percent = total <= 0
                ? 0
                : (int)Math.Round(value * 100.0 / total);

            percent = Math.Max(0, Math.Min(100, percent));
            control.Style["width"] = percent + "%";
        }

        private void SetPercent(Label label, HtmlGenericControl control, int value, int total)
        {
            int percent = total <= 0
                ? 0
                : (int)Math.Round(value * 100.0 / total);

            percent = Math.Max(0, Math.Min(100, percent));

            label.Text = percent + "%";
            control.Style["width"] = percent + "%";
        }

        protected string GetStatusCss(object value)
        {
            string status = Convert.ToString(value).ToLowerInvariant();

            if (status.Contains("approved"))
                return "status-approved";

            if (status.Contains("rejected"))
                return "status-rejected";

            if (status.Contains("pending"))
                return "status-pending";

            return "status-neutral";
        }

        private string NormalizePurpose(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return "—";

            if (value.Equals("Education Background", StringComparison.OrdinalIgnoreCase))
                return "Education";

            if (value.Equals("Travel/Visa", StringComparison.OrdinalIgnoreCase))
                return "Travel / Visa";

            return value;
        }

        private string NormalizeStatus(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return "Unknown";

            if (value.Equals("Pending", StringComparison.OrdinalIgnoreCase) ||
                value.Equals("Pending Approval", StringComparison.OrdinalIgnoreCase))
                return "Pending Review";

            if (value.Equals("Approved", StringComparison.OrdinalIgnoreCase))
                return "Approved Review";

            if (value.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                return "Rejected Review";

            return value;
        }

        private string Encode(object value)
        {
            if (value == null || value == DBNull.Value)
                return "—";

            string text = Convert.ToString(value);

            return string.IsNullOrWhiteSpace(text)
                ? "—"
                : Server.HtmlEncode(text);
        }

        private string FormatDate(object value)
        {
            if (value == null || value == DBNull.Value)
                return "—";

            DateTime date;

            return DateTime.TryParse(Convert.ToString(value), out date)
                ? date.ToString("dd MMM yyyy")
                : "—";
        }

        private string FormatDateTime(object value)
        {
            if (value == null || value == DBNull.Value)
                return "—";

            DateTime date;

            return DateTime.TryParse(Convert.ToString(value), out date)
                ? date.ToString("dd MMM yyyy HH:mm")
                : "—";
        }

        private string MaskId(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return "—";

            value = value.Trim();

            if (value.Length <= 4)
                return "••••";

            return "••••••" + value.Substring(value.Length - 4);
        }

        private void SetZeroDashboard()
        {
            // Historical method name retained; missing data is never a zero count.
            foreach (Label label in new[] { lblTotalUsers, lblRegisteredCitizens,
                lblActiveOfficers, lblAdmins, lblApplicationsSubmitted, lblIncoming,
                lblApprovedReview, lblRejectedReview, lblEmployment, lblTravel,
                lblEducation, lblOther, lblApprovedPercent, lblRejectedPercent,
                lblPendingPercent, lblPaymentPercent, lblUsersTabTotal,
                lblUsersTabCitizens, lblUsersTabOfficers, lblUsersTabAdmins })
                label.Text = "—";
            foreach (HtmlGenericControl bar in new[] { barEmployment, barTravel,
                barEducation, barOther, progressApproved, progressRejected,
                progressPending, progressPayment })
                bar.Style["width"] = "0%";
        }

        private void ShowDashboardMessage(string message)
        {
            pnlDashboardMessage.Visible = true;
            litDashboardMessage.Text =
                HttpUtility.HtmlEncode(message);
        }
    }
}
