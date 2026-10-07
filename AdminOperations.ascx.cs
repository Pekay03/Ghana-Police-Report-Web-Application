using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public partial class AdminOperations : UserControl
    {
        // GPS-derived region reporting is approximate, not an authoritative residence check.
        private const string RegionExpression = @"CASE
            WHEN UPPER(LEFT(TRIM(GPSAddress),2)) IN ('GA','GT') THEN 'Greater Accra'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2)) IN ('AK','AS') THEN 'Ashanti'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='ER' THEN 'Eastern'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='WR' THEN 'Western'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='CR' THEN 'Central'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='VR' THEN 'Volta'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='NR' THEN 'Northern'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='UE' THEN 'Upper East'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='UW' THEN 'Upper West'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2)) IN ('BR','BA') THEN 'Bono'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='BE' THEN 'Bono East'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2)) IN ('AF','AH') THEN 'Ahafo'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='WN' THEN 'Western North'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='OT' THEN 'Oti'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2)) IN ('SV','SA') THEN 'Savannah'
            WHEN UPPER(LEFT(TRIM(GPSAddress),2))='NE' THEN 'North East'
            ELSE 'Unmapped / missing GPS' END";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Authorized()) { Visible = false; return; }
            string[] names = { "Applications", "Identity", "Officers", "Cases", "Security",
                "Analytics", "Notifications", "Payments" };
            foreach (string name in names)
                ((System.Web.UI.WebControls.Panel)FindControl("pnlModule" + name)).Visible =
                    String.Equals(SelectedModule, name, StringComparison.OrdinalIgnoreCase);
            if (!Page.IsPostBack && Request.QueryString["tab"] == "operations")
            {
                LoadFilterOptions();
                LoadModules();
            }
        }

        private string SelectedModule
        {
            get
            {
                string value = (Request.QueryString["module"] ?? "applications").ToLowerInvariant();
                return Array.IndexOf(new[] { "applications", "identity", "officers", "cases", "security",
                    "analytics", "notifications", "payments" }, value) >= 0 ? value : "applications";
            }
        }

        internal void RefreshSelected() { LoadModules(); }

        protected void staffProfiles_Saved(object sender, EventArgs e) { LoadModules(); }

        protected void btnWorkflowSearch_Click(object sender, EventArgs e)
        {
            gvWorkflowEvents.PageIndex = 0;
            LoadModules();
        }

        private bool Authorized()
        {
            int actor;
            string name;
            return StaffAccess.TryUser(Context, true, out actor, out name);
        }

        protected void btnModuleSearch_Click(object sender, EventArgs e)
        {
            gvManagedApplications.PageIndex = 0;
            LoadModules();
        }

        protected void btnModuleClear_Click(object sender, EventArgs e)
        {
            txtModuleSearch.Text = "";
            txtModuleFrom.Text = "";
            txtModuleTo.Text = "";
            ddlModuleStatus.SelectedIndex = 0;
            ddlModuleRegion.SelectedIndex = 0;
            ddlModulePriority.SelectedIndex = 0;
            ddlModulePurpose.SelectedIndex = 0;
            ddlModuleOfficer.SelectedIndex = 0;
            ddlModuleAssignment.SelectedIndex = 0;
            ddlModuleProcessing.SelectedIndex = 0;
            gvManagedApplications.PageIndex = 0;
            LoadModules();
        }

        protected void grid_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            if (!Authorized()) return;
            GridView grid = sender as GridView;
            if (grid == null) return;
            grid.PageIndex = e.NewPageIndex;
            LoadModules();
        }

        protected void gvManagedApplications_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!Authorized() || e.CommandName != "Inspect") return;
            int index;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out index) ||
                index < 0 || index >= gvManagedApplications.DataKeys.Count) return;
            AdminDashboard dashboard = Page as AdminDashboard;
            if (dashboard != null)
                dashboard.InspectManagedApplication(Convert.ToString(gvManagedApplications.DataKeys[index].Value));
        }

        protected void gvOfficers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!Authorized()) return;
            int index;
            if (Int32.TryParse(Convert.ToString(e.CommandArgument), out index) &&
                index >= 0 && index < gvOfficers.DataKeys.Count)
            {
                int officer = Convert.ToInt32(gvOfficers.DataKeys[index].Value);
                if (e.CommandName == "Profile" || e.CommandName == "Activity")
                {
                    staffProfiles.SelectStaff(officer);
                    if (e.CommandName == "Activity")
                        Page.ClientScript.RegisterStartupScript(GetType(), "staff-activity",
                            "setTimeout(function(){var p=document.getElementById('po-staff-activity');if(p){p.scrollIntoView();p.focus();}},0);", true);
                }
                else if (e.CommandName == "Worklist" || e.CommandName == "Assign")
                    Response.Redirect("AdminDashboard.aspx?tab=operations&module=applications&" +
                        (e.CommandName == "Assign" ? "assignment=Unassigned&assignTo=" : "officer=") +
                        officer.ToString(CultureInfo.InvariantCulture), false);
            }
        }

        private void LoadModules()
        {
            if (!Authorized()) { Message("Access denied."); return; }
            if (Page.IsPostBack) lblModuleMessage.Text = "";
            ClearGrids(FindControl("pnlModule" + CultureInfo.InvariantCulture.TextInfo.ToTitleCase(SelectedModule)));
            lblUrgentApplications.Text = lblUnassignedApplications.Text =
                lblAwaitingReview.Text = lblOverdueApplications.Text = "Unavailable";
            lblSecuritySummary.Text = "Unavailable";
            lblProcessingTarget.Text = Server.HtmlEncode(AdminWorkspaceData.TargetDescription);
            try
            {
                using (MySqlConnection connection = new MySqlConnection(
                    ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString))
                {
                    connection.Open();
                    if (SelectedModule == "applications")
                    {
                        lblUrgentApplications.Text = "Unavailable";
                        LoadApplications(connection);
                        LoadQueue(connection);
                    }
                    Bind(connection, gvOfficers, @"SELECT UserID, CONCAT(FirstName,' ',LastName) AS Officer,
                        StaffNumber, Department, Station, `Rank`, Email, Role, IsActive, LastLoginAt,
                        CASE WHEN IsActive=1 THEN 'Active' ELSE 'Inactive' END AS AccountState,
                        (SELECT COUNT(*) FROM application_assignments x WHERE x.OfficerUserID=users.UserID
                            AND x.UnassignedAt IS NULL) AS ActiveAssignments,
                        (SELECT COUNT(*) FROM application_assignments x JOIN applications a ON a.ApplicationID=x.ApplicationID
                            WHERE x.OfficerUserID=users.UserID AND x.UnassignedAt IS NULL
                            AND LOWER(TRIM(a.Status)) IN ('pending','pending approval')) AS PendingAssignments,
                        (SELECT COUNT(*) FROM application_assignments x JOIN applications a ON a.ApplicationID=x.ApplicationID
                            WHERE x.OfficerUserID=users.UserID AND x.UnassignedAt IS NULL
                            AND LOWER(TRIM(a.Status))='under review') AS UnderReviewAssignments,
                        (SELECT COUNT(*) FROM application_assignments x JOIN applications a ON a.ApplicationID=x.ApplicationID
                            WHERE x.OfficerUserID=users.UserID AND x.UnassignedAt IS NULL
                            AND LOWER(TRIM(a.Status)) IN ('approved','rejected')) AS CompletedAssignments,
                        (SELECT COUNT(DISTINCT w.ApplicationID) FROM application_workflow_history w
                            WHERE w.ActionByUserID=users.UserID AND w.ActionType IN
                            ('ApplicationApproved','ApplicationRejected')) AS RecordedDecisions
                        FROM users
                        WHERE LOWER(REPLACE(REPLACE(REPLACE(Role,' ',''),'-',''),'_',''))
                        IN ('officer','policeofficer','vettingofficer')
                        ORDER BY IsActive DESC, LastName, FirstName LIMIT 1000;");
                    if (SelectedModule == "cases") LoadReports(connection);
                    if (SelectedModule == "security") LoadSecurity(connection);
                    Bind(connection, gvLockedAccounts, @"SELECT UserID, CONCAT(FirstName,' ',LastName) AS Account,
                        Role, FailedLoginAttempts, LockedUntil,
                        CASE WHEN LockedUntil>NOW() THEN 'Currently locked' ELSE 'Not currently locked' END AS LockState,
                        IsActive FROM users
                        WHERE FailedLoginAttempts>0 OR LockedUntil>NOW()
                        ORDER BY LockedUntil DESC, FailedLoginAttempts DESC LIMIT 1000;");
                    // Never select password-reset tokens or token hashes.
                    Bind(connection, gvPasswordResets, @"SELECT r.ResetRequestID, r.UserID,
                        CONCAT(u.FirstName,' ',u.LastName) AS Account, r.RequestedAt, r.Status,
                        r.RequestSource, r.ProcessedBy, r.ProcessedAt
                        FROM password_reset_requests r LEFT JOIN users u ON u.UserID=r.UserID
                        ORDER BY r.RequestedAt DESC, r.ResetRequestID DESC LIMIT 1000;");
                    Bind(connection, gvAnalyticsMonth, @"SELECT DATE_FORMAT(DateSubmitted,'%Y-%m') AS Month,
                        COUNT(*) AS Applications FROM applications GROUP BY Month ORDER BY Month DESC;");
                    Bind(connection, gvAnalyticsPurpose, @"SELECT COALESCE(NULLIF(TRIM(Purpose),''),'Unspecified') AS Purpose,
                        COUNT(*) AS Applications FROM applications GROUP BY Purpose ORDER BY Applications DESC;");
                    Bind(connection, gvAnalyticsRegion, "SELECT " + RegionExpression + @" AS InferredRegion,
                        COUNT(*) AS Applications FROM applications GROUP BY InferredRegion ORDER BY Applications DESC;");
                    Bind(connection, gvAnalyticsRates, @"SELECT COALESCE(NULLIF(LOWER(TRIM(Status)),''),'unspecified') AS Status,
                        COUNT(*) AS Applications, ROUND(COUNT(*)*100.0 /
                        NULLIF((SELECT COUNT(*) FROM applications),0),2) AS Percent
                        FROM applications GROUP BY LOWER(TRIM(Status)) ORDER BY Applications DESC;");
                    Bind(connection, gvAnalyticsVerification, @"SELECT
                        CASE
                          WHEN Notes LIKE '[LOCAL DOCUMENT REVIEW: Verified]%' THEN 'Manual local: Verified'
                          WHEN Notes LIKE '[LOCAL DOCUMENT REVIEW: Flagged]%' THEN 'Manual local: Flagged'
                          WHEN Notes LIKE '[LOCAL DOCUMENT REVIEW: Rejected]%' THEN 'Manual local: Rejected'
                          ELSE 'Legacy local review (see notes)' END AS ReviewOutcome,
                        COUNT(*) AS ReviewEvents FROM verification_log GROUP BY ReviewOutcome;");
                    Bind(connection, gvAnalyticsProcessing, AdminWorkspaceData.ProcessingSql);
                    Bind(connection, gvAnalyticsWorkload, AdminWorkspaceData.WorkloadSql);
                    if (SelectedModule == "analytics") LoadQueue(connection);
                    Bind(connection, gvAnalyticsOfficerActivity, @"SELECT
                        COALESCE(NULLIF(TRIM(ReviewedBy),''),'Unrecorded reviewer') AS RecordedReviewerText,
                        SUM(CASE WHEN LOWER(TRIM(Status))='approved' THEN 1 ELSE 0 END) AS ApprovedApplications,
                        SUM(CASE WHEN LOWER(TRIM(Status))='rejected' THEN 1 ELSE 0 END) AS RejectedApplications
                        FROM applications WHERE LOWER(TRIM(Status)) IN ('approved','rejected')
                        GROUP BY RecordedReviewerText ORDER BY ApprovedApplications+RejectedApplications DESC;");
                    Bind(connection, gvPaymentStatistics, @"SELECT
                        CASE WHEN COALESCE(TransactionID,'') NOT LIKE 'HBT-%' THEN 'Legacy / no Hubtel confirmation'
                             WHEN PaymentVerified=1 THEN 'Successful / Hubtel-confirmed'
                             WHEN PaymentVerified=2 THEN 'Failed / cancelled'
                             WHEN PaymentVerified=0 THEN 'Pending / unresolved'
                             ELSE 'Unknown verification state' END AS Verification,
                        COUNT(*) AS PaymentRecords, SUM(AmountPaid) AS RecordedAmountGHS
                        FROM payments GROUP BY Verification;");
                    if (SelectedModule == "payments") LoadPaymentRecords(connection);
                    if (SelectedModule == "cases") LoadWorkflow(connection);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Operations modules failed ({0}).", ex.GetType().Name);
                Message("Operations data is unavailable. Check the database configuration. No example data is displayed.");
            }
        }

        private void LoadApplications(MySqlConnection connection)
        {
            lblApplicationScope.Text = "Unavailable";
            DateTime from, to;
            bool hasFrom = !String.IsNullOrWhiteSpace(txtModuleFrom.Text);
            bool hasTo = !String.IsNullOrWhiteSpace(txtModuleTo.Text);
            from = DateTime.MinValue;
            to = DateTime.MinValue;
            if ((hasFrom && !DateTime.TryParseExact(txtModuleFrom.Text, "yyyy-MM-dd",
                    CultureInfo.InvariantCulture, DateTimeStyles.None, out from)) ||
                (hasTo && !DateTime.TryParseExact(txtModuleTo.Text, "yyyy-MM-dd",
                    CultureInfo.InvariantCulture, DateTimeStyles.None, out to)) ||
                (hasFrom && hasTo && from > to) || txtModuleSearch.Text.Trim().Length > 150 ||
                (hasTo && to == DateTime.MaxValue.Date))
            {
                gvManagedApplications.DataSource = null;
                gvManagedApplications.DataBind();
                Message("Enter a valid date range and search text of at most 150 characters.");
                return;
            }
            if (ddlModulePriority.SelectedValue != "All" &&
                !AdminWorkflowService.ValidPriority(ddlModulePriority.SelectedValue))
            { Message("Choose a supported priority filter."); return; }
            if (ddlModuleProcessing.SelectedValue == "OverTarget" && !AdminWorkspaceData.TargetHours.HasValue)
            {
                gvManagedApplications.DataSource = null;
                gvManagedApplications.DataBind();
                Message("A processing target has not been configured. No overdue threshold is assumed.");
                return;
            }
            string sql = @"SELECT application_id, FullName, Purpose, Priority, Status, DateSubmitted,
                ReviewedBy, ReviewedAt,
                COALESCE((SELECT CONCAT(u.FirstName,' ',u.LastName) FROM application_assignments x
                    JOIN users u ON u.UserID=x.OfficerUserID WHERE x.ApplicationID=applications.ApplicationID
                    AND x.UnassignedAt IS NULL),'Not assigned') AS AssignedOfficer,
                CASE WHEN ReviewedAt>=DateSubmitted AND LOWER(TRIM(Status)) IN ('approved','rejected')
                     THEN ROUND(TIMESTAMPDIFF(MINUTE,DateSubmitted,ReviewedAt)/60.0,2)
                     ELSE NULL END AS CompletedProcessingHours,
                CASE WHEN LOWER(TRIM(Status)) NOT IN ('approved','rejected') AND DateSubmitted<=NOW()
                     THEN ROUND(TIMESTAMPDIFF(MINUTE,DateSubmitted,NOW())/60.0,2)
                     ELSE NULL END AS OpenAgeHours
                FROM applications WHERE
                (@Search='' OR application_id LIKE CONCAT('%',@Search,'%') OR
                    FullName LIKE CONCAT('%',@Search,'%') OR Email LIKE CONCAT('%',@Search,'%') OR
                    Phone LIKE CONCAT('%',@Search,'%') OR GhanaCard LIKE CONCAT('%',@Search,'%'))
                AND (@Status='All' OR (@Status='Pending' AND LOWER(TRIM(Status)) IN ('pending','pending approval'))
                    OR LOWER(TRIM(Status))=LOWER(@Status))
                AND (@From IS NULL OR DateSubmitted>=@From)
                AND (@To IS NULL OR DateSubmitted<@To)
                AND (@Priority='All' OR Priority=@Priority)
                AND (@Purpose='All' OR Purpose=@Purpose)
                AND (@Officer='All' OR EXISTS (SELECT 1 FROM application_assignments x
                     WHERE x.ApplicationID=applications.ApplicationID AND x.UnassignedAt IS NULL
                     AND x.OfficerUserID=@Officer))
                AND (@Assignment='All' OR
                    (@Assignment='Assigned' AND EXISTS (SELECT 1 FROM application_assignments x
                        WHERE x.ApplicationID=applications.ApplicationID AND x.UnassignedAt IS NULL)) OR
                    (@Assignment='Unassigned' AND NOT EXISTS (SELECT 1 FROM application_assignments x
                        WHERE x.ApplicationID=applications.ApplicationID AND x.UnassignedAt IS NULL)))
                AND (@Processing='All' OR
                    (@Processing='Completed' AND LOWER(TRIM(Status)) IN ('approved','rejected')) OR
                    (@Processing='Open' AND LOWER(TRIM(Status)) NOT IN ('approved','rejected')) OR
                    (@Processing='OverTarget' AND LOWER(TRIM(Status)) IN ('pending','pending approval')
                        AND DateSubmitted<=NOW() AND TIMESTAMPDIFF(SECOND,DateSubmitted,NOW())>@Target*3600))
                AND (@Region='All' OR (" + RegionExpression + @")=@Region)
                ORDER BY DateSubmitted DESC, ApplicationID DESC LIMIT 1000;";
            try
            {
                using (MySqlCommand command = new MySqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@Search", txtModuleSearch.Text.Trim());
                    command.Parameters.AddWithValue("@Status", ddlModuleStatus.SelectedValue);
                    command.Parameters.AddWithValue("@Priority", ddlModulePriority.SelectedValue);
                    command.Parameters.AddWithValue("@Purpose", ddlModulePurpose.SelectedValue);
                    command.Parameters.AddWithValue("@Officer", ddlModuleOfficer.SelectedValue);
                    command.Parameters.AddWithValue("@Assignment", ddlModuleAssignment.SelectedValue);
                    command.Parameters.AddWithValue("@Processing", ddlModuleProcessing.SelectedValue);
                    command.Parameters.AddWithValue("@Target", (object)AdminWorkspaceData.TargetHours ?? DBNull.Value);
                    command.Parameters.AddWithValue("@From", hasFrom ? (object)from : DBNull.Value);
                    command.Parameters.AddWithValue("@To", hasTo ? (object)to.AddDays(1) : DBNull.Value);
                    command.Parameters.AddWithValue("@Region", ddlModuleRegion.SelectedValue == "All"
                        ? "All" : ddlModuleRegion.SelectedItem.Text);
                    Fill(command, gvManagedApplications);
                    var displayed = (DataTable)gvManagedApplications.DataSource;
                    lblApplicationScope.Text = displayed.Rows.Count == 1000
                        ? "First 1,000 matching applications — narrow filters to see older records."
                        : displayed.Rows.Count.ToString(CultureInfo.InvariantCulture) + " matching applications.";
                }
            }
            catch (Exception ex)
            {
                lblApplicationScope.Text = "Unavailable";
                System.Diagnostics.Trace.TraceError("Application module failed ({0}).", ex.GetType().Name);
                Message("The application list is unavailable.");
                gvManagedApplications.DataSource = null;
                gvManagedApplications.DataBind();
            }
        }

        private void Bind(MySqlConnection connection, GridView grid, string sql)
        {
            string module = grid == gvOfficers ? "officers" :
                grid == gvSecurity || grid == gvLockedAccounts || grid == gvPasswordResets ? "security" :
                grid == gvPayments || grid == gvPaymentStatistics ? "payments" : "analytics";
            if (SelectedModule != module) return;
            try
            {
                using (MySqlCommand command = new MySqlCommand(sql, connection)) Fill(command, grid);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Module {0} unavailable ({1}).", grid.ID, ex.GetType().Name);
                grid.DataSource = null;
                grid.DataBind();
                Message(grid.ID.Substring(2) + " is unavailable; no substitute statistics are shown.");
            }
        }

        private void LoadWorkflow(MySqlConnection connection)
        {
            string search = txtWorkflowSearch.Text.Trim();
            if (search.Length > 50) { Message("Use an application reference of at most 50 characters."); return; }
            try
            {
                using (var command = AdminWorkflowService.Command(connection, null, @"SELECT
                    a.application_id AS Application,w.ActionAt,w.ActionType,w.FromStatus,w.ToStatus,
                    CONCAT(u.FirstName,' ',u.LastName) AS Actor,w.ActionByUserID,w.Notes
                    FROM application_workflow_history w JOIN applications a ON a.ApplicationID=w.ApplicationID
                    JOIN users u ON u.UserID=w.ActionByUserID
                    WHERE @Search='' OR a.application_id LIKE CONCAT('%',@Search,'%')
                    ORDER BY w.ActionAt DESC,w.WorkflowID DESC LIMIT 1000;", "@Search", search))
                    Fill(command, gvWorkflowEvents);
            }
            catch (Exception ex) { Message(AdminWorkflowService.SafeError(ex)); }
        }
        private static void Fill(MySqlCommand command, GridView grid)
        {
            using (MySqlDataAdapter adapter = new MySqlDataAdapter(command))
            {
                DataTable table = new DataTable();
                adapter.Fill(table);
                if (grid.PageIndex > 0 && grid.PageIndex * grid.PageSize >= table.Rows.Count)
                    grid.PageIndex = 0;
                grid.DataSource = table;
                grid.DataBind();
            }
        }
        private void Message(string text)
        {
            lblModuleMessage.Text += Server.HtmlEncode(text) + " ";
        }
    }
}
