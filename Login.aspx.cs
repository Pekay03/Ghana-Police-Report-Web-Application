using System;
using System.Web.Security;

namespace PoliceBackgroundCheckSystem
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // =========================================================
            // HANDLE LOGOUT
            // =========================================================

            string logout = Request.QueryString["logout"];

            if (!string.IsNullOrEmpty(logout) &&
                logout.Equals("true", StringComparison.OrdinalIgnoreCase))
            {
                LogoutUser();
                return;
            }

            if (!IsPostBack && Request.QueryString["disabled"] == "1")
            {
                ShowMessage("This account is no longer active. Contact an administrator for assistance.");
            }


            // =========================================================
            // CHECK IF USER IS ALREADY LOGGED IN
            // =========================================================

            if (!IsPostBack)
            {
                bool authenticated =
                    Session["IsAuthenticated"] != null &&
                    Convert.ToBoolean(Session["IsAuthenticated"]);

                if (authenticated)
                {
                    RedirectUserByRole();
                }
            }
        }


        // =========================================================
        // LOGIN BUTTON
        // =========================================================

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;

            // =========================================================
            // VALIDATE USERNAME
            // =========================================================

            if (string.IsNullOrWhiteSpace(username))
            {
                ShowMessage("Please enter your username.");
                return;
            }


            // =========================================================
            // VALIDATE PASSWORD
            // =========================================================

            if (string.IsNullOrWhiteSpace(password))
            {
                ShowMessage("Please enter your password.");
                return;
            }


            // =========================================================
            // AUTHENTICATE USER
            // =========================================================

            string errorMessage;

            UserAccount user =
                DatabaseHelper.AuthenticateUser(
                    username,
                    password,
                    out errorMessage
                );


            // =========================================================
            // LOGIN FAILED
            // =========================================================

            if (user == null)
            {
                ShowMessage(
                    string.IsNullOrWhiteSpace(errorMessage)
                        ? "Invalid username or password."
                        : errorMessage
                );

                return;
            }

            if (user.PasswordResetRequired)
            {
                Response.Redirect("ForgotPassword.aspx?required=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }


            // =========================================================
            // GET USER ROLE
            // =========================================================

            string role = Convert.ToString(user.Role).Trim();

            if (string.IsNullOrWhiteSpace(role))
            {
                ShowMessage(
                    "Your account does not have a valid role. " +
                    "Please contact the system administrator."
                );

                return;
            }


            // =========================================================
            // CREATE SESSION
            // =========================================================

            Session["IsAuthenticated"] = true;

            Session["UserID"] = user.UserID;

            Session["Email"] = user.Email;

            Session["FirstName"] = user.FirstName;

            Session["LastName"] = user.LastName;


            Session["Role"] = role;


            // =========================================================
            // COMPATIBILITY SESSION VARIABLES
            // =========================================================

            Session["Username"] = user.Email;

            Session["UserFullName"] =
                (user.FirstName + " " + user.LastName).Trim();
            Session["FullName"] = Session["UserFullName"];
            Session["BadgeNumber"] = string.Empty;
            Session["Station"] = string.Empty;


            // =========================================================
            // CREATE FORMS AUTHENTICATION COOKIE
            // =========================================================

            FormsAuthentication.SetAuthCookie(
                user.Email,
                false
            );


            // =========================================================
            // REDIRECT ACCORDING TO ROLE
            // =========================================================

            RedirectUserByRole();
        }


        // =========================================================
        // REDIRECT USER ACCORDING TO ROLE
        // =========================================================

        private void RedirectUserByRole()
        {
            string role =
                Convert.ToString(Session["Role"]).Trim();


            // =========================================================
            // NO ROLE
            // =========================================================

            if (string.IsNullOrWhiteSpace(role))
            {
                ClearLoginSession();

                Response.Redirect(
                    "Login.aspx",
                    false
                );

                Context.ApplicationInstance
                    .CompleteRequest();

                return;
            }


            // =========================================================
            // NORMALIZE ROLE
            // =========================================================

            string normalizedRole =
                role
                    .Trim()
                    .Replace(" ", "")
                    .Replace("-", "")
                    .Replace("_", "")
                    .ToUpperInvariant();


            // =========================================================
            // ADMINISTRATOR
            // =========================================================

            if (
                normalizedRole == "ADMIN" ||
                normalizedRole == "ADMINISTRATOR" ||
                normalizedRole == "SYSTEMADMIN"
            )
            {
                Response.Redirect(
                    "AdminDashboard.aspx",
                    false
                );

                Context.ApplicationInstance
                    .CompleteRequest();

                return;
            }


            // =========================================================
            // POLICE OFFICER
            // =========================================================

            if (
                normalizedRole == "POLICEOFFICER" ||
                normalizedRole == "OFFICER" ||
                normalizedRole == "POLICE" ||
                normalizedRole == "VETTINGOFFICER"
            )
            {
                Response.Redirect(
                    "VettingDashboard.aspx",
                    false
                );

                Context.ApplicationInstance
                    .CompleteRequest();

                return;
            }


            // =========================================================
            // CITIZEN
            // =========================================================

            if (normalizedRole == "CITIZEN")
            {
                Response.Redirect(
                    "SubmitApplication.aspx",
                    false
                );

                Context.ApplicationInstance
                    .CompleteRequest();

                return;
            }


            // =========================================================
            // UNKNOWN ROLE
            // =========================================================

            ClearLoginSession();

            ShowMessage(
                "Your account has an invalid role. " +
                "Please contact the system administrator."
            );
        }


        // =========================================================
        // LOGOUT
        // =========================================================

        private void LogoutUser()
        {
            FormsAuthentication.SignOut();

            Session.Clear();

            Session.Abandon();


            Response.Redirect(
                "Default.aspx",
                false
            );

            Context.ApplicationInstance
                .CompleteRequest();
        }


        // =========================================================
        // CLEAR LOGIN SESSION
        // =========================================================

        private void ClearLoginSession()
        {
            Session.Clear();

            FormsAuthentication.SignOut();
        }


        // =========================================================
        // DISPLAY MESSAGE
        // =========================================================

        private void ShowMessage(string message)
        {
            lblMessage.Text = message;

            lblMessage.Visible = true;
        }
    }
}