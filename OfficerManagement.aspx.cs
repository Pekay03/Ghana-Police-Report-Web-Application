using System;
using System.Web.UI;

namespace PoliceBackgroundCheckSystem
{
    // Preserve old bookmarks, but keep account management in one place.
    public partial class OfficerManagement : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            int userId;
            string role = Convert.ToString(Session["Role"]).Trim()
                .Replace(" ", "").Replace("-", "").Replace("_", "");
            bool isAdmin = role.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                || role.Equals("Administrator", StringComparison.OrdinalIgnoreCase)
                || role.Equals("SystemAdmin", StringComparison.OrdinalIgnoreCase);

            if (Session["IsAuthenticated"] == null ||
                !Convert.ToBoolean(Session["IsAuthenticated"]) ||
                !Int32.TryParse(Convert.ToString(Session["UserID"]), out userId) ||
                userId <= 0 || !isAdmin || !DatabaseHelper.IsAccountActive(userId))
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            Response.Redirect("~/AdminDashboard.aspx?tab=users", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
