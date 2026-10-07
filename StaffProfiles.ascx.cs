using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public partial class StaffProfiles : UserControl
    {
        public event EventHandler Saved;
        protected void Page_Load(object sender, EventArgs e)
        {
            int actor; string name;
            if (!StaffAccess.TryUser(Context, true, out actor, out name)) { Visible = false; return; }
            // Contacts are shared sign-in/recovery identifiers. Their existing guarded account editor remains authoritative.
            txtStaffEmail.ReadOnly = txtStaffPhone.ReadOnly = true;
            if (!Page.IsPostBack && Request.QueryString["tab"] == "operations" &&
                Request.QueryString["module"] == "officers") LoadStaff();
        }

        private void LoadStaff()
        {
            try
            {
                using (var c = new MySqlConnection(AdminWorkflowService.ConnectionString))
                {
                    c.Open();
                    ddlStaffUser.DataSource = AdminWorkflowService.Table(c, null, @"SELECT UserID,
                        CONCAT(FirstName,' ',LastName,' (#',UserID,')') AS Name FROM users
                        WHERE LOWER(REPLACE(REPLACE(REPLACE(Role,' ',''),'-',''),'_',''))
                        IN ('admin','administrator','systemadmin','officer','policeofficer','vettingofficer')
                        ORDER BY LastName,FirstName,UserID;");
                    ddlStaffUser.DataValueField = "UserID"; ddlStaffUser.DataTextField = "Name";
                    ddlStaffUser.DataBind();
                    ddlStaffUser.Items.Insert(0, new ListItem("Select a staff account", ""));
                }
            }
            catch (Exception ex) { lblProfileMessage.Text = Server.HtmlEncode(AdminWorkflowService.SafeError(ex)); }
        }

        protected void ddlStaffUser_SelectedIndexChanged(object sender, EventArgs e) { LoadProfile(); }

        public void SelectStaff(int userId)
        {
            LoadStaff();
            var item = ddlStaffUser.Items.FindByValue(userId.ToString(System.Globalization.CultureInfo.InvariantCulture));
            if (item == null) { lblProfileMessage.Text = "The staff account is unavailable."; return; }
            ddlStaffUser.SelectedValue = item.Value;
            LoadProfile();
        }

        private void LoadProfile()
        {
            pnlProfileFields.Visible = false;
            lblProfileMessage.Text = "";
            try
            {
                int actor, target; string name;
                if (!StaffAccess.TryUser(Context, true, out actor, out name))
                    throw new InvalidOperationException("Administrator access is required.");
                if (!Int32.TryParse(ddlStaffUser.SelectedValue, out target)) return;
                using (var c = new MySqlConnection(AdminWorkflowService.ConnectionString))
                {
                    c.Open();
                    var table = AdminWorkflowService.Table(c, null, @"SELECT UserID,FirstName,LastName,
                        Email,Phone,Role,IsActive,StaffNumber,Department,Station,`Rank`,CreatedAt,LastLoginAt
                        FROM users WHERE UserID=@Staff;", "@Staff", target);
                    if (table.Rows.Count != 1 || !StaffAccess.IsReviewerRole(Convert.ToString(table.Rows[0]["Role"])))
                        throw new InvalidOperationException("Select a staff account.");
                    DataRow row = table.Rows[0];
                    txtStaffFirstName.Text = Convert.ToString(row["FirstName"]);
                    txtStaffLastName.Text = Convert.ToString(row["LastName"]);
                    txtStaffEmail.Text = Convert.ToString(row["Email"]);
                    txtStaffPhone.Text = Convert.ToString(row["Phone"]);
                    txtStaffNumber.Text = Convert.ToString(row["StaffNumber"]);
                    txtStaffDepartment.Text = Convert.ToString(row["Department"]);
                    txtStaffStation.Text = Convert.ToString(row["Station"]);
                    txtStaffRank.Text = Convert.ToString(row["Rank"]);
                    lblStaffName.Text = Server.HtmlEncode(txtStaffFirstName.Text + " " + txtStaffLastName.Text);
                    lblStaffRole.Text = Server.HtmlEncode(Convert.ToString(row["Role"]));
                    lblStaffState.Text = Convert.ToBoolean(row["IsActive"]) ? "Active" : "Inactive";
                    lblStaffCreated.Text = DateText(row["CreatedAt"], "Not recorded for this legacy account");
                    lblStaffLogin.Text = DateText(row["LastLoginAt"], "No recorded sign-in");
                    var assignments = AdminWorkflowService.Table(c, null, @"SELECT a.application_id AS Application,
                        a.FullName AS Applicant,a.Priority,a.Status,x.AssignedAt,
                        CASE WHEN x.UnassignedAt IS NULL THEN 'Active' ELSE 'Ended' END AS AssignmentState,x.UnassignedAt
                        FROM application_assignments x JOIN applications a ON a.ApplicationID=x.ApplicationID
                        WHERE x.OfficerUserID=@Staff ORDER BY x.AssignedAt DESC,x.AssignmentID DESC;", "@Staff", target);
                    gvStaffAssignments.DataSource = assignments;
                    gvStaffAssignments.DataKeyNames = new[] { "Application" };
                    gvStaffAssignments.DataBind();
                    int active = 0, pending = 0, reviewing = 0, completed = 0;
                    foreach (DataRow assignment in assignments.Rows)
                        if (Convert.ToString(assignment["AssignmentState"]) == "Active")
                        {
                            active++;
                            if (AdminWorkflowService.IsPending(Convert.ToString(assignment["Status"]))) pending++;
                            string state = Convert.ToString(assignment["Status"]).Trim().ToLowerInvariant();
                            if (state == "under review") reviewing++;
                            if (state == "approved" || state == "rejected") completed++;
                        }
                    lblStaffAssigned.Text = active + " current assignments · " + pending + " pending · " +
                        reviewing + " under review · " + completed + " completed";
                    string id = target.ToString(System.Globalization.CultureInfo.InvariantCulture);
                    hlStaffWorklist.NavigateUrl = "AdminDashboard.aspx?tab=operations&module=applications&officer=" + id;
                    hlStaffAssign.NavigateUrl = "AdminDashboard.aspx?tab=operations&module=applications&assignment=Unassigned&assignTo=" + id;
                    hlStaffAssign.Visible = !StaffAccess.IsAdminRole(Convert.ToString(row["Role"])) && Convert.ToBoolean(row["IsActive"]);
                    hlStaffWorklist.Visible = !StaffAccess.IsAdminRole(Convert.ToString(row["Role"]));
                    hlStaffAccounts.NavigateUrl = "AdminDashboard.aspx?tab=users&staff=" + id;
                    gvStaffActivity.DataSource = AdminWorkflowService.Table(c, null, @"SELECT l.CreatedAt,l.ActionType,
                        COALESCE(CONCAT(u.FirstName,' ',u.LastName),'System') AS Actor,l.Details
                        FROM account_audit_logs l LEFT JOIN users u ON u.UserID=l.ActorUserID
                        WHERE l.ActorUserID=@Staff OR l.TargetUserID=@Staff
                        ORDER BY l.CreatedAt DESC,l.AuditID DESC LIMIT 1000;", "@Staff", target);
                    gvStaffActivity.DataBind();
                    hidProfileCsrf.Value = AdminWorkflowService.FormToken(Context);
                    pnlProfileFields.Visible = true;
                }
            }
            catch (Exception ex) { lblProfileMessage.Text = Server.HtmlEncode(AdminWorkflowService.SafeError(ex)); }
        }

        private string DateText(object value, string missing)
        {
            return value == DBNull.Value ? missing : Server.HtmlEncode(Convert.ToDateTime(value).ToString("yyyy-MM-dd HH:mm"));
        }

        protected void gvStaffAssignments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int actor, index; string name;
            if (!StaffAccess.TryUser(Context, true, out actor, out name) || e.CommandName != "Inspect" ||
                !Int32.TryParse(Convert.ToString(e.CommandArgument), out index) ||
                index < 0 || index >= gvStaffAssignments.DataKeys.Count) return;
            var dashboard = Page as AdminDashboard;
            if (dashboard != null)
                dashboard.InspectManagedApplication(Convert.ToString(gvStaffAssignments.DataKeys[index].Value));
        }

        protected void btnSaveStaff_Click(object sender, EventArgs e)
        {
            try
            {
                int target;
                if (!Int32.TryParse(ddlStaffUser.SelectedValue, out target))
                    throw new InvalidOperationException("Select a staff account.");
                AdminWorkflowService.SaveStaffProfile(Context, hidProfileCsrf.Value, target,
                    txtStaffFirstName.Text, txtStaffLastName.Text, txtStaffNumber.Text,
                    txtStaffDepartment.Text, txtStaffStation.Text, txtStaffRank.Text);
                LoadProfile();
                if (ddlStaffUser.SelectedItem != null)
                    ddlStaffUser.SelectedItem.Text = txtStaffFirstName.Text + " " + txtStaffLastName.Text + " (#" + target + ")";
                lblProfileMessage.Text = "Staff profile saved and audited. Roles, account state and sign-in contacts were not changed.";
                if (Saved != null) Saved(this, EventArgs.Empty);
            }
            catch (Exception ex) { lblProfileMessage.Text = Server.HtmlEncode(AdminWorkflowService.SafeError(ex)); }
        }
    }
}
