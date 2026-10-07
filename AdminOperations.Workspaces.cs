using System;
using System.Data;
using System.Globalization;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public partial class AdminOperations
    {
        private void LoadFilterOptions()
        {
            ddlModulePurpose.Items.Clear();
            ddlModuleOfficer.Items.Clear();
            ddlSecurityEvent.Items.Clear();
            ddlModulePurpose.Items.Add(new ListItem("All purposes", "All"));
            ddlModuleOfficer.Items.Add(new ListItem("All officers", "All"));
            ddlSecurityEvent.Items.Add(new ListItem("All recorded events", "All"));
            if (SelectedModule != "applications" && SelectedModule != "security") return;
            try
            {
                using (var c = new MySqlConnection(AdminWorkflowService.ConnectionString))
                {
                    c.Open();
                    if (SelectedModule == "applications")
                    {
                        var purposes = AdminWorkflowService.Table(c, null,
                            "SELECT DISTINCT Purpose FROM applications WHERE NULLIF(TRIM(Purpose),'') IS NOT NULL ORDER BY Purpose;");
                        foreach (DataRow row in purposes.Rows)
                            ddlModulePurpose.Items.Add(new ListItem(Convert.ToString(row[0]), Convert.ToString(row[0])));
                        var officers = AdminWorkflowService.Table(c, null, @"SELECT UserID,
                            CONCAT(FirstName,' ',LastName,CASE WHEN IsActive=1 THEN '' ELSE ' (inactive)' END) AS Name
                            FROM users WHERE LOWER(REPLACE(REPLACE(REPLACE(TRIM(Role),' ',''),'-',''),'_',''))
                                IN ('officer','policeofficer','vettingofficer') ORDER BY LastName,FirstName,UserID;");
                        foreach (DataRow row in officers.Rows)
                            ddlModuleOfficer.Items.Add(new ListItem(Convert.ToString(row["Name"]),
                                Convert.ToString(row["UserID"], CultureInfo.InvariantCulture)));
                        SetKnownSelection(ddlModuleOfficer, Request.QueryString["officer"]);
                        SetKnownSelection(ddlModuleAssignment, Request.QueryString["assignment"]);
                        SetKnownSelection(ddlModulePriority, Request.QueryString["priority"]);
                        SetKnownSelection(ddlModuleProcessing, Request.QueryString["processing"]);
                    }
                    else
                    {
                        var events = AdminWorkflowService.Table(c, null,
                            "SELECT DISTINCT ActionType FROM account_audit_logs ORDER BY ActionType;");
                        foreach (DataRow row in events.Rows)
                            ddlSecurityEvent.Items.Add(new ListItem(Convert.ToString(row[0]), Convert.ToString(row[0])));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Workspace filters unavailable ({0}).", ex.GetType().Name);
                Message("Some filter options could not be loaded. Reload after checking the database.");
            }
        }

        private static void SetKnownSelection(DropDownList list, string value)
        {
            if (String.IsNullOrEmpty(value)) return;
            var option = list.Items.FindByValue(value);
            if (option != null) list.SelectedValue = option.Value;
        }

        private void LoadQueue(MySqlConnection connection)
        {
            lblProcessingTarget.Text = Server.HtmlEncode(AdminWorkspaceData.TargetDescription);
            try
            {
                var queue = AdminWorkspaceData.Queue(connection);
                lblUrgentApplications.Text = Convert.ToString(queue.Rows[0]["Applications"]);
                lblUnassignedApplications.Text = Convert.ToString(queue.Rows[1]["Applications"]);
                lblAwaitingReview.Text = Convert.ToString(queue.Rows[2]["Applications"]);
                lblOverdueApplications.Text = Convert.ToString(queue.Rows[3]["Applications"]);
                if (SelectedModule == "analytics")
                {
                    gvAnalyticsQueue.DataSource = queue;
                    gvAnalyticsQueue.DataBind();
                }
            }
            catch (Exception ex)
            {
                Message("Queue indicators are unavailable; no estimated values are substituted.");
                System.Diagnostics.Trace.TraceError("Queue unavailable ({0}).", ex.GetType().Name);
            }
        }

        protected void gvReportApplications_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!Authorized() || e.CommandName != "Inspect") return;
            int index;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out index) ||
                index < 0 || index >= gvReportApplications.DataKeys.Count) return;
            var dashboard = Page as AdminDashboard;
            if (dashboard != null)
                dashboard.InspectManagedApplication(Convert.ToString(gvReportApplications.DataKeys[index].Value));
        }

        private void LoadReports(MySqlConnection connection)
        {
            string reference = txtWorkflowSearch.Text.Trim();
            if (reference.Length > 50) { Message("Use a reference of at most 50 characters."); return; }
            using (var command = AdminWorkflowService.Command(connection, null, @"SELECT a.application_id,
                a.FullName,a.Purpose,a.Status,a.ReviewedAt,
                COALESCE(NULLIF(TRIM(a.ReviewNotes),''),'No outcome notes recorded') AS ReviewOutcome,
                COALESCE((SELECT CONCAT(u.FirstName,' ',u.LastName) FROM application_assignments x
                    JOIN users u ON u.UserID=x.OfficerUserID WHERE x.ApplicationID=a.ApplicationID
                    AND x.UnassignedAt IS NULL),'Unassigned') AS AssignedOfficer
                FROM applications a WHERE @Search='' OR a.application_id LIKE CONCAT('%',@Search,'%')
                ORDER BY a.DateSubmitted DESC,a.ApplicationID DESC LIMIT 1000;", "@Search", reference))
                Fill(command, gvReportApplications);
        }

        protected void btnSecuritySearch_Click(object sender, EventArgs e)
        { gvSecurity.PageIndex = 0; LoadModules(); }

        protected void btnSecurityClear_Click(object sender, EventArgs e)
        { txtSecuritySearch.Text = ""; ddlSecurityEvent.SelectedIndex = 0; gvSecurity.PageIndex = 0; LoadModules(); }

        private void LoadSecurity(MySqlConnection connection)
        {
            if (txtSecuritySearch.Text.Trim().Length > 150)
            { Message("Use at most 150 characters for security search."); return; }
            using (var command = AdminWorkflowService.Command(connection, null, @"SELECT l.CreatedAt,l.ActionType,
                COALESCE(CONCAT(u.FirstName,' ',u.LastName),CONCAT('User #',l.ActorUserID),'System') AS Actor,
                COALESCE(CONCAT(t.FirstName,' ',t.LastName),CONCAT('User #',l.TargetUserID),'Not recorded') AS Target,
                l.Details,l.IPAddress,l.UserAgent FROM account_audit_logs l LEFT JOIN users u ON u.UserID=l.ActorUserID
                LEFT JOIN users t ON t.UserID=l.TargetUserID
                WHERE (@Event='All' OR l.ActionType=@Event) AND (@Search='' OR
                    l.ActionType LIKE CONCAT('%',@Search,'%') OR l.Details LIKE CONCAT('%',@Search,'%') OR
                    CONCAT(u.FirstName,' ',u.LastName) LIKE CONCAT('%',@Search,'%') OR
                    CONCAT(t.FirstName,' ',t.LastName) LIKE CONCAT('%',@Search,'%'))
                ORDER BY l.CreatedAt DESC,l.AuditID DESC LIMIT 1000;",
                "@Event", ddlSecurityEvent.SelectedValue, "@Search", txtSecuritySearch.Text.Trim()))
                Fill(command, gvSecurity);
            var counters = AdminWorkflowService.Table(connection, null, @"SELECT
                COALESCE(SUM(FailedLoginAttempts),0) AS Attempts,
                COUNT(CASE WHEN LockedUntil>NOW() THEN 1 END) AS Locks,
                (SELECT COUNT(*) FROM account_audit_logs) AS Events,
                (SELECT COUNT(*) FROM password_reset_requests) AS Resets FROM users;");
            DataRow row = counters.Rows[0];
            lblSecuritySummary.Text = Server.HtmlEncode(String.Format(CultureInfo.InvariantCulture,
                "{0} current failed-attempt counter total · {1} currently locked accounts · {2} recorded audit events · {3} recorded reset requests. Counters reset after successful sign-in; they are not lifetime failed-login events.",
                row["Attempts"], row["Locks"], row["Events"], row["Resets"]));
        }

        protected void btnPaymentSearch_Click(object sender, EventArgs e)
        { gvPayments.PageIndex = 0; LoadModules(); }

        protected void gvOfficers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            var row = e.Row.DataItem as DataRowView;
            if (row == null || Convert.ToBoolean(row["IsActive"])) return;
            foreach (TableCell cell in e.Row.Cells)
                foreach (System.Web.UI.Control control in cell.Controls)
                {
                    var button = control as LinkButton;
                    if (button != null && button.CommandName == "Assign")
                    { button.Enabled = false; button.ToolTip = "Activate this officer through Accounts before assigning."; }
                }
        }

        protected void btnPaymentClear_Click(object sender, EventArgs e)
        { txtPaymentSearch.Text = ""; ddlPaymentState.SelectedIndex = 0; gvPayments.PageIndex = 0; LoadModules(); }

        private void LoadPaymentRecords(MySqlConnection connection)
        {
            string search = txtPaymentSearch.Text.Trim();
            string state = ddlPaymentState.SelectedValue;
            if (search.Length > 150 || Array.IndexOf(new[] { "All", "Successful", "Pending", "Failed", "Legacy", "Unknown" }, state) < 0)
            { Message("Choose a supported payment state and at most 150 search characters."); return; }
            using (var command = AdminWorkflowService.Command(connection, null, @"SELECT p.PaymentID,p.TransactionID,
                a.application_id AS Application,p.PaymentMethod,p.AmountPaid AS RecordedAmountGHS,p.PaymentDate,
                CASE WHEN COALESCE(p.TransactionID,'') NOT LIKE 'HBT-%' THEN 'Legacy / no Hubtel confirmation'
                    WHEN p.PaymentVerified=1 THEN 'Successful / Hubtel-confirmed'
                    WHEN p.PaymentVerified=2 THEN 'Failed / cancelled'
                    WHEN p.PaymentVerified=0 THEN 'Pending / unresolved'
                    ELSE 'Unknown verification state' END AS Verification
                FROM payments p LEFT JOIN applications a ON a.ApplicationID=p.ApplicationID
                WHERE (@Search='' OR p.TransactionID LIKE CONCAT('%',@Search,'%') OR
                    a.application_id LIKE CONCAT('%',@Search,'%'))
                AND (@State='All' OR (@State='Legacy' AND COALESCE(p.TransactionID,'') NOT LIKE 'HBT-%')
                    OR (p.TransactionID LIKE 'HBT-%' AND (
                        (@State='Successful' AND p.PaymentVerified=1) OR
                        (@State='Pending' AND p.PaymentVerified=0) OR
                        (@State='Failed' AND p.PaymentVerified=2) OR
                        (@State='Unknown' AND (p.PaymentVerified IS NULL OR p.PaymentVerified NOT IN (0,1,2))))))
                ORDER BY p.PaymentDate DESC,p.PaymentID DESC LIMIT 1000;", "@Search", search, "@State", state))
                Fill(command, gvPayments);
        }

        private static void ClearGrids(System.Web.UI.Control parent)
        {
            foreach (System.Web.UI.Control control in parent.Controls)
            {
                if (control is System.Web.UI.UserControl) continue; // Child editors manage their own state.
                var grid = control as GridView;
                if (grid != null) { grid.DataSource = null; grid.DataBind(); }
                else ClearGrids(control);
            }
        }
    }
}
