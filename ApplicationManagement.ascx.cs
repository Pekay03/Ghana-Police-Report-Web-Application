using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public partial class ApplicationManagement : UserControl
    {
        public event EventHandler Saved;
        public string Reference
        {
            get { return Convert.ToString(ViewState["ManagedReference"]); }
            private set { ViewState["ManagedReference"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            int actor; string name;
            if (!StaffAccess.TryUser(Context, true, out actor, out name)) { Visible = false; return; }
        }

        public void LoadApplication(string reference)
        {
            Reference = "";
            btnAssign.Enabled = btnUnassign.Enabled = btnPriority.Enabled = false;
            lblManagementMessage.Text = "";
            lblAssignedOfficer.Text = lblCurrentPriority.Text = "Unavailable";
            try
            {
                int actor; string name;
                if (!StaffAccess.TryUser(Context, true, out actor, out name))
                    throw new InvalidOperationException("Administrator access is required.");
                AdminWorkflowService.RequireReference(reference);
                using (var c = new MySqlConnection(AdminWorkflowService.ConnectionString))
                {
                    c.Open();
                    var app = AdminWorkflowService.Table(c, null, @"SELECT ApplicationID,Status,Priority
                        FROM applications WHERE application_id=@Reference;", "@Reference", reference);
                    if (app.Rows.Count != 1) throw new InvalidOperationException("Application unavailable.");
                    int id = Convert.ToInt32(app.Rows[0]["ApplicationID"]);
                    var officers = AdminWorkflowService.Table(c, null, @"SELECT UserID,
                        CONCAT(FirstName,' ',LastName,' (#',UserID,')') AS Name FROM users
                        WHERE IsActive=1 AND LOWER(REPLACE(REPLACE(REPLACE(Role,' ',''),'-',''),'_',''))
                        IN ('officer','policeofficer','vettingofficer') ORDER BY LastName,FirstName,UserID;");
                    ddlAssignOfficer.DataSource = officers;
                    ddlAssignOfficer.DataValueField = "UserID";
                    ddlAssignOfficer.DataTextField = "Name";
                    ddlAssignOfficer.DataBind();
                    ddlAssignOfficer.Items.Insert(0, new ListItem("Select an active officer", ""));
                    var current = AdminWorkflowService.Table(c, null, @"SELECT x.OfficerUserID,
                        CONCAT(u.FirstName,' ',u.LastName) AS Officer,u.IsActive
                        FROM application_assignments x JOIN users u ON u.UserID=x.OfficerUserID
                        WHERE x.ApplicationID=@App AND x.UnassignedAt IS NULL;", "@App", id);
                    lblAssignedOfficer.Text = current.Rows.Count == 0 ? "Not assigned" :
                        Server.HtmlEncode(Convert.ToString(current.Rows[0]["Officer"]) +
                        (Convert.ToBoolean(current.Rows[0]["IsActive"]) ? "" : " (inactive — reassign)"));
                    btnAssign.Text = current.Rows.Count == 0 ? "Assign officer" : "Reassign officer";
                    if (current.Rows.Count == 1)
                    {
                        ListItem item = ddlAssignOfficer.Items.FindByValue(Convert.ToString(current.Rows[0]["OfficerUserID"]));
                        if (item != null) ddlAssignOfficer.SelectedValue = item.Value;
                    }
                    else
                    {
                        // Navigation can suggest an officer, never assign one without an audited POST.
                        int suggested;
                        if (Int32.TryParse(Request.QueryString["assignTo"], out suggested) && suggested > 0)
                        {
                            var item = ddlAssignOfficer.Items.FindByValue(suggested.ToString(System.Globalization.CultureInfo.InvariantCulture));
                            if (item != null) ddlAssignOfficer.SelectedValue = item.Value;
                        }
                    }
                    string priority = Convert.ToString(app.Rows[0]["Priority"]);
                    if (!AdminWorkflowService.ValidPriority(priority))
                        throw new InvalidOperationException("The stored priority is unsupported. Ask the database administrator to review it.");
                    lblCurrentPriority.Text = Server.HtmlEncode(priority);
                    ddlPriority.SelectedValue = priority;
                    gvAssignmentHistory.DataSource = AdminWorkflowService.Table(c, null, @"SELECT x.AssignmentID,
                        CONCAT(o.FirstName,' ',o.LastName) AS Officer,x.OfficerUserID,
                        CONCAT(a.FirstName,' ',a.LastName) AS AssignedBy,x.AssignedAt,x.UnassignedAt,x.Status
                        FROM application_assignments x JOIN users o ON o.UserID=x.OfficerUserID
                        JOIN users a ON a.UserID=x.AssignedByUserID WHERE x.ApplicationID=@App
                        ORDER BY x.AssignedAt DESC,x.AssignmentID DESC;", "@App", id);
                    gvAssignmentHistory.DataBind();
                    gvWorkflowHistory.DataSource = AdminWorkflowService.Table(c, null, @"SELECT w.ActionAt,w.ActionType,
                        w.FromStatus,w.ToStatus,CONCAT(u.FirstName,' ',u.LastName) AS Actor,w.ActionByUserID,w.Notes
                        FROM application_workflow_history w JOIN users u ON u.UserID=w.ActionByUserID
                        WHERE w.ApplicationID=@App ORDER BY w.ActionAt DESC,w.WorkflowID DESC;", "@App", id);
                    gvWorkflowHistory.DataBind();
                    Reference = reference;
                    hidManagementCsrf.Value = AdminWorkflowService.FormToken(Context);
                    bool pending = AdminWorkflowService.IsPending(Convert.ToString(app.Rows[0]["Status"]));
                    btnAssign.Enabled = pending && officers.Rows.Count > 0;
                    btnUnassign.Enabled = pending && current.Rows.Count > 0;
                    btnPriority.Enabled = pending;
                    if (!pending) lblManagementMessage.Text = "Completed applications are not reassigned or reprioritized.";
                }
            }
            catch (Exception ex) { lblManagementMessage.Text = Server.HtmlEncode(AdminWorkflowService.SafeError(ex)); }
        }

        protected void btnAssign_Click(object sender, EventArgs e)
        {
            int officer;
            if (!Int32.TryParse(ddlAssignOfficer.SelectedValue, out officer))
            { lblManagementMessage.Text = "Select an active officer."; return; }
            Save(() => AdminWorkflowService.SetAssignment(Context, hidManagementCsrf.Value,
                Reference, officer, txtAssignmentReason.Text));
        }

        protected void btnUnassign_Click(object sender, EventArgs e)
        {
            Save(() => AdminWorkflowService.SetAssignment(Context, hidManagementCsrf.Value,
                Reference, null, txtAssignmentReason.Text));
        }

        protected void btnPriority_Click(object sender, EventArgs e)
        {
            Save(() => AdminWorkflowService.SetPriority(Context, hidManagementCsrf.Value, Reference, ddlPriority.SelectedValue));
        }

        private void Save(Action action)
        {
            try
            {
                action();
                string reference = Reference;
                txtAssignmentReason.Text = "";
                if (Saved != null) Saved(this, EventArgs.Empty);
                else LoadApplication(reference);
                lblManagementMessage.Text = "Saved with workflow history and an audit record.";
            }
            catch (Exception ex) { lblManagementMessage.Text = Server.HtmlEncode(AdminWorkflowService.SafeError(ex)); }
        }
    }
}
