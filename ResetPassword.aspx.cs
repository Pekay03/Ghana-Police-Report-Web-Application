using System;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace PoliceBackgroundCheckSystem
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!IsResetSessionValid())
                {
                    Response.Redirect(
                        "ForgotPassword.aspx",
                        false);

                    Context.ApplicationInstance
                           .CompleteRequest();

                    return;
                }

                byte[] token = new byte[32];
                using (var random = RandomNumberGenerator.Create())
                    random.GetBytes(token);
                hfResetCsrf.Value = Convert.ToBase64String(token);
                Session["PasswordResetCsrf"] = hfResetCsrf.Value;
            }
        }


        // ============================================================
        // RESET PASSWORD
        // ============================================================

        protected void btnResetPassword_Click(
            object sender,
            EventArgs e)
        {
            if (!IsValidResetCsrf())
            {
                ShowMessage("This password reset form is no longer valid. Please start again.");
                return;
            }

            if (!IsResetSessionValid())
            {
                Response.Redirect(
                    "ForgotPassword.aspx",
                    false);

                Context.ApplicationInstance
                       .CompleteRequest();

                return;
            }


            string newPassword =
                txtNewPassword.Text;

            string confirmPassword =
                txtConfirmPassword.Text;


            // --------------------------------------------------------
            // VALIDATE PASSWORD
            // --------------------------------------------------------

            if (string.IsNullOrEmpty(newPassword))
            {
                ShowMessage(
                    "Please enter your new password.");

                return;
            }


            if (!IsStrongPassword(newPassword))
            {
                ShowMessage(
                    "Password must contain at least 8 characters, "
                    + "including uppercase, lowercase, number and special character.");

                return;
            }


            if (newPassword != confirmPassword)
            {
                ShowMessage(
                    "The passwords do not match.");

                return;
            }


            // --------------------------------------------------------
            // GET VERIFIED ACCOUNT
            // --------------------------------------------------------

            string email =
                Convert.ToString(
                    Session["PasswordResetEmail"]);


            if (string.IsNullOrWhiteSpace(email) ||
                email == "__NO_ACCOUNT__")
            {
                ClearResetSession();

                ShowMessage(
                    "The password reset session is no longer valid.");

                return;
            }


            // --------------------------------------------------------
            // UPDATE PASSWORD
            // --------------------------------------------------------

            string errorMessage;

            bool updated =
                DatabaseHelper.UpdatePassword(
                    email,
                    newPassword,
                    out errorMessage);


            if (!updated)
            {
                ShowMessage(
                    string.IsNullOrWhiteSpace(errorMessage)
                        ? "The password could not be updated."
                        : errorMessage);

                return;
            }

            long requestId;
            if (Int64.TryParse(
                Convert.ToString(Session["PasswordResetRequestId"]),
                out requestId))
            {
                DatabaseHelper.CompletePasswordResetRequest(requestId);
            }


            // --------------------------------------------------------
            // CLEAR RESET SESSION
            // --------------------------------------------------------

            ClearResetSession();


            // --------------------------------------------------------
            // SUCCESS
            // --------------------------------------------------------

            Response.Redirect(
                "Login.aspx?reset=success",
                false);

            Context.ApplicationInstance
                   .CompleteRequest();
        }


        // ============================================================
        // PASSWORD VALIDATION
        // ============================================================

        private bool IsStrongPassword(
            string password)
        {
            if (password.Length < 8)
            {
                return false;
            }

            if (!Regex.IsMatch(
                password,
                "[A-Z]"))
            {
                return false;
            }

            if (!Regex.IsMatch(
                password,
                "[a-z]"))
            {
                return false;
            }

            if (!Regex.IsMatch(
                password,
                "[0-9]"))
            {
                return false;
            }

            if (!Regex.IsMatch(
                password,
                @"[!@#$%^&*]"))
            {
                return false;
            }

            return true;
        }


        // ============================================================
        // CHECK RESET SESSION
        // ============================================================

        private bool IsResetSessionValid()
        {
            bool verified =
                Session["PasswordResetVerified"] != null
                &&
                Convert.ToBoolean(
                    Session["PasswordResetVerified"]);

            string email =
                Convert.ToString(
                    Session["PasswordResetEmail"]);

            object verifiedAt =
                Session["PasswordResetOtpVerifiedAt"];

            long requestId;
            if (verifiedAt == null ||
                !(verifiedAt is DateTime) ||
                !Int64.TryParse(
                    Convert.ToString(Session["PasswordResetRequestId"]),
                    out requestId) ||
                requestId <= 0)
            {
                return false;
            }

            if (!verified)
            {
                return false;
            }

            if (string.IsNullOrWhiteSpace(email))
            {
                return false;
            }

            if (email == "__NO_ACCOUNT__")
            {
                return false;
            }


            // --------------------------------------------------------
            // Reset session expires after 10 minutes
            // --------------------------------------------------------

            DateTime time = (DateTime)verifiedAt;
            TimeSpan resetAge = DateTime.UtcNow.Subtract(time);
            if (resetAge < TimeSpan.Zero ||
                resetAge.TotalMinutes > 10)
            {
                return false;
            }


            return true;
        }


        // ============================================================
        // CLEAR RESET SESSION
        // ============================================================

        private bool IsValidResetCsrf()
        {
            string expected = Convert.ToString(Session["PasswordResetCsrf"]);
            string submitted = Request.Form[hfResetCsrf.UniqueID];
            if (String.IsNullOrEmpty(expected) || String.IsNullOrEmpty(submitted))
                return false;

            try
            {
                byte[] expectedBytes = Convert.FromBase64String(expected);
                byte[] submittedBytes = Convert.FromBase64String(submitted);
                if (expectedBytes.Length != 32 || submittedBytes.Length != 32)
                    return false;

                int difference = 0;
                for (int i = 0; i < expectedBytes.Length; i++)
                    difference |= expectedBytes[i] ^ submittedBytes[i];
                return difference == 0;
            }
            catch (FormatException)
            {
                return false;
            }
        }

        private void ClearResetSession()
        {
            Session.Remove("PasswordResetCsrf");
            Session.Remove(
                "PasswordResetPhone");

            Session.Remove(
                "PasswordResetOtp");

            Session.Remove(
                "PasswordResetOtpExpiry");

            Session.Remove(
                "PasswordResetOtpAttempts");

            Session.Remove(
                "PasswordResetRequestId");

            Session.Remove(
                "PasswordResetEmail");

            Session.Remove(
                "PasswordResetVerified");

            Session.Remove(
                "PasswordResetOtpVerifiedAt");

            Session.Remove(
                "OtpDeliveryMessage");
        }


        // ============================================================
        // MESSAGE
        // ============================================================

        private void ShowMessage(
            string message)
        {
            lblMessage.Text =
                message;

            lblMessage.Visible =
                true;
        }
    }
}