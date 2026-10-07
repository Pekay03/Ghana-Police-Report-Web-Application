using System;

namespace PoliceBackgroundCheckSystem
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsAuthenticated"] != null &&
                Convert.ToBoolean(Session["IsAuthenticated"]))
            {
                object sessionId = Session["UserID"];
                int userId;

                if (!Int32.TryParse(Convert.ToString(sessionId), out userId) ||
                    !DatabaseHelper.IsAccountActive(userId))
                {
                    Session.Clear();
                    Session.Abandon();
                    Response.Redirect("~/Login.aspx?disabled=1");
                }
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            ConfigureNavigation();
        }

        // =========================================================
        // CONFIGURE NAVIGATION
        // =========================================================

        private void ConfigureNavigation()
        {
            bool loggedIn =
                Session["IsAuthenticated"] != null &&
                Convert.ToBoolean(Session["IsAuthenticated"]);

            if (loggedIn)
            {
                NavLinks.Visible = false;
                NavLinksLoggedIn.Visible = true;

                string userName =
                    Convert.ToString(Session["UserFullName"]);

                string role =
                    Convert.ToString(Session["Role"]);

                ltrUser.InnerText =
                    string.IsNullOrWhiteSpace(userName)
                        ? "System User"
                        : userName;

                ltrRole.InnerText =
                    FormatRole(role);

                ConfigureDashboardLink(role);
            }
            else
            {
                NavLinks.Visible = true;
                NavLinksLoggedIn.Visible = false;

                ltrUser.InnerText = string.Empty;
                ltrRole.InnerText = string.Empty;

                DashboardLink.HRef = "Login.aspx";
                DashboardLink.InnerText = "Login";
            }
        }

        // =========================================================
        // CONFIGURE DASHBOARD LINK
        // =========================================================

        private void ConfigureDashboardLink(string role)
        {
            if (string.IsNullOrWhiteSpace(role))
            {
                DashboardLink.HRef =
                    "SubmitApplication.aspx";

                DashboardLink.InnerText =
                    "My Applications";

                return;
            }

            string normalizedRole =
                role.Trim()
                    .Replace(" ", "")
                    .Replace("-", "")
                    .Replace("_", "")
                    .ToUpperInvariant();

            // -----------------------------------------------------
            // ADMINISTRATOR
            // -----------------------------------------------------

            if (normalizedRole == "ADMIN" ||
                normalizedRole == "ADMINISTRATOR" ||
                normalizedRole == "SYSTEMADMIN")
            {
                DashboardLink.HRef =
                    "AdminDashboard.aspx";

                DashboardLink.InnerText =
                    "Admin Dashboard";

                return;
            }

            // -----------------------------------------------------
            // POLICE OFFICER
            // -----------------------------------------------------

            if (normalizedRole == "POLICEOFFICER" ||
                normalizedRole == "POLICE OFFICER" ||
                normalizedRole == "OFFICER" ||
                normalizedRole == "POLICE" ||
                normalizedRole == "VETTINGOFFICER" ||
                normalizedRole == "VETTING OFFICER")
            {
                // Officers already have their dashboard workspace; keep only Logout here.
                DashboardLink.Visible = false;
                return;
            }

            // -----------------------------------------------------
            // CITIZEN
            // -----------------------------------------------------

            DashboardLink.HRef =
                "SubmitApplication.aspx";

            DashboardLink.InnerText =
                "My Applications";
        }

        // =========================================================
        // FORMAT ROLE FOR DISPLAY
        // =========================================================

        private string FormatRole(string role)
        {
            if (string.IsNullOrWhiteSpace(role))
            {
                return "USER";
            }

            string normalized =
                role.Trim()
                    .Replace(" ", "")
                    .Replace("-", "")
                    .Replace("_", "")
                    .ToUpperInvariant();

            if (normalized == "ADMIN" ||
                normalized == "ADMINISTRATOR" ||
                normalized == "SYSTEMADMIN")
            {
                return "SYSTEM ADMINISTRATOR";
            }

            if (normalized == "POLICEOFFICER" ||
                normalized == "OFFICER" ||
                normalized == "POLICE" ||
                normalized == "VETTINGOFFICER")
            {
                return "POLICE OFFICER";
            }

            return "CITIZEN";
        }
    }
}