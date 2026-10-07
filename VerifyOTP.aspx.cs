using System;

namespace PoliceBackgroundCheckSystem
{
    public partial class VerifyOTP : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!IsOtpSessionValid())
                {
                    Response.Redirect(
                        "ForgotPassword.aspx",
                        false);

                    Context.ApplicationInstance
                           .CompleteRequest();

                    return;
                }

                string deliveryMessage =
                    Convert.ToString(Session["OtpDeliveryMessage"]);

                if (!String.IsNullOrWhiteSpace(deliveryMessage))
                {
                    lblMessage.Text = Server.HtmlEncode(deliveryMessage);
                    lblMessage.Visible = true;
                    Session.Remove("OtpDeliveryMessage");
                }
            }
        }


        // ============================================================
        // VERIFY OTP
        // ============================================================

        protected void btnVerify_Click(
            object sender,
            EventArgs e)
        {
            string enteredOtp =
                txtOtp.Text.Trim();

            string storedOtp =
                Convert.ToString(
                    Session["PasswordResetOtp"]);


            if (string.IsNullOrWhiteSpace(enteredOtp))
            {
                ShowMessage(
                    "Please enter the six-digit verification code.");

                return;
            }


            if (enteredOtp.Length != 6)
            {
                ShowMessage(
                    "The verification code must contain 6 digits.");

                return;
            }


            // --------------------------------------------------------
            // CHECK EXPIRY
            // --------------------------------------------------------

            object expiryObject =
                Session["PasswordResetOtpExpiry"];

            if (expiryObject == null)
            {
                ShowMessage(
                    "Your verification code has expired. "
                    + "Please request a new code.");

                return;
            }

            DateTime expiry =
                (DateTime)expiryObject;

            if (DateTime.UtcNow > expiry)
            {
                Session.Remove(
                    "PasswordResetOtp");

                ShowMessage(
                    "Your verification code has expired. "
                    + "Please request a new code.");

                return;
            }


            // --------------------------------------------------------
            // CHECK ATTEMPTS
            // --------------------------------------------------------

            int attempts =
                Convert.ToInt32(
                    Session["PasswordResetOtpAttempts"] ?? 0);

            if (attempts >= 5)
            {
                ClearOtpSession();

                ShowMessage(
                    "Too many incorrect attempts. "
                    + "Please request a new verification code.");

                return;
            }


            // --------------------------------------------------------
            // COMPARE OTP
            // --------------------------------------------------------

            if (!string.Equals(
                enteredOtp,
                storedOtp,
                StringComparison.Ordinal))
            {
                attempts++;

                Session["PasswordResetOtpAttempts"] =
                    attempts;

                int remaining =
                    5 - attempts;

                ShowMessage(
                    "Incorrect verification code. "
                    + remaining +
                    " attempt(s) remaining.");

                return;
            }


            // --------------------------------------------------------
            // OTP SUCCESSFUL
            // --------------------------------------------------------

            string email =
                Convert.ToString(
                    Session["PasswordResetEmail"]);


            if (string.IsNullOrWhiteSpace(email) ||
                email == "__NO_ACCOUNT__")
            {
                ClearOtpSession();

                ShowMessage(
                    "We could not complete the password reset request.");

                return;
            }


            // --------------------------------------------------------
            // MARK OTP AS VERIFIED
            // --------------------------------------------------------

            Session["PasswordResetVerified"] =
                true;

            Session["PasswordResetOtpVerifiedAt"] =
                DateTime.UtcNow;


            // --------------------------------------------------------
            // OTP SHOULD NOT BE REUSED
            // --------------------------------------------------------

            Session.Remove(
                "PasswordResetOtp");

            Session.Remove(
                "PasswordResetOtpExpiry");

            Session.Remove(
                "PasswordResetOtpAttempts");


            // --------------------------------------------------------
            // MOVE TO PASSWORD RESET
            // --------------------------------------------------------

            Response.Redirect(
                "ResetPassword.aspx",
                false);

            Context.ApplicationInstance
                   .CompleteRequest();
        }


        // ============================================================
        // CHECK OTP SESSION
        // ============================================================

        private bool IsOtpSessionValid()
        {
            string phone =
                Convert.ToString(
                    Session["PasswordResetPhone"]);

            string otp =
                Convert.ToString(
                    Session["PasswordResetOtp"]);

            object expiry =
                Session["PasswordResetOtpExpiry"];

            if (string.IsNullOrWhiteSpace(phone))
            {
                return false;
            }

            if (string.IsNullOrWhiteSpace(otp))
            {
                return false;
            }

            if (expiry == null)
            {
                return false;
            }

            DateTime expiryDate =
                (DateTime)expiry;

            if (DateTime.UtcNow > expiryDate)
            {
                return false;
            }

            return true;
        }


        // ============================================================
        // CLEAR OTP
        // ============================================================

        private void ClearOtpSession()
        {
            Session.Remove(
                "PasswordResetOtp");

            Session.Remove(
                "PasswordResetOtpExpiry");

            Session.Remove(
                "PasswordResetOtpAttempts");
        }


        // ============================================================
        // MESSAGE
        // ============================================================

        private void ShowMessage(string message)
        {
            lblMessage.Text =
                message;

            lblMessage.Visible =
                true;
        }
    }
}