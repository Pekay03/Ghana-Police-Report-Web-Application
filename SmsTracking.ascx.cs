using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public partial class SmsTracking : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            int actor; string name;
            if (!StaffAccess.TryUser(Context, true, out actor, out name)) { Visible = false; return; }
            if (!Page.IsPostBack && Request.QueryString["tab"] == "operations" &&
                Request.QueryString["module"] == "notifications") LoadLogs();
        }

        protected void btnSmsSearch_Click(object sender, EventArgs e) { gvSmsDelivery.PageIndex = 0; LoadLogs(); }
        protected void btnSmsClear_Click(object sender, EventArgs e)
        { txtSmsSearch.Text = ""; ddlSmsState.SelectedIndex = 0; gvSmsDelivery.PageIndex = 0; LoadLogs(); }
        protected void grid_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            ((GridView)sender).PageIndex = e.NewPageIndex;
            LoadLogs();
        }

        private void LoadLogs()
        {
            lblSmsMessage.Text = "";
            try
            {
                int actor; string name;
                if (!StaffAccess.TryUser(Context, true, out actor, out name))
                    throw new InvalidOperationException("Administrator access is required.");
                if (txtSmsSearch.Text.Trim().Length > 150) throw new InvalidOperationException("Use at most 150 search characters.");
                string state = ddlSmsState.SelectedValue;
                if (state != "All" && state != "Pending" && state != "Submitted" && state != "Delivered" &&
                    state != "Failed" && state != "Unknown") throw new InvalidOperationException("Choose a supported SMS status.");
                using (var c = new MySqlConnection(AdminWorkflowService.ConnectionString))
                {
                    c.Open();
                    gvSmsSummary.DataSource = AdminWorkflowService.Table(c, null,
                        @"SELECT CASE WHEN Status='Submitted' THEN 'Provider accepted'
                            ELSE Status END AS StatusDisplay,COUNT(*) AS Messages
                            FROM sms_delivery_logs GROUP BY Status ORDER BY Status;");
                    gvSmsSummary.DataBind();
                    gvSmsDelivery.DataSource = AdminWorkflowService.Table(c, null, @"SELECT s.SmsLogID,s.CreatedAt,
                        CONCAT('***',RIGHT(s.PhoneNumber,4)) AS Recipient,s.MessageType,s.Provider,s.Status,
                        CASE WHEN s.Status='Submitted' THEN 'Provider accepted' ELSE s.Status END AS StatusDisplay,
                        s.UserID,a.application_id AS Application,s.MessageReference,s.ProviderMessageID,
                        s.SentAt AS AcceptedAt,s.DeliveredAt,s.ErrorMessage
                        FROM sms_delivery_logs s LEFT JOIN applications a ON a.ApplicationID=s.ApplicationID
                        WHERE (@State='All' OR s.Status=@State) AND (@Search='' OR s.MessageReference LIKE CONCAT('%',@Search,'%')
                        OR s.ProviderMessageID LIKE CONCAT('%',@Search,'%') OR a.application_id LIKE CONCAT('%',@Search,'%'))
                        ORDER BY s.CreatedAt DESC,s.SmsLogID DESC LIMIT 1000;",
                        "@State", state, "@Search", txtSmsSearch.Text.Trim());
                    if (gvSmsDelivery.PageIndex > 0 &&
                        gvSmsDelivery.PageIndex * gvSmsDelivery.PageSize >= ((System.Data.DataTable)gvSmsDelivery.DataSource).Rows.Count)
                        gvSmsDelivery.PageIndex = 0;
                    gvSmsDelivery.DataBind();
                }
            }
            catch (Exception ex)
            {
                gvSmsSummary.DataSource = gvSmsDelivery.DataSource = null;
                gvSmsSummary.DataBind(); gvSmsDelivery.DataBind();
                lblSmsMessage.Text = Server.HtmlEncode(AdminWorkflowService.SafeError(ex));
            }
        }
    }
}
