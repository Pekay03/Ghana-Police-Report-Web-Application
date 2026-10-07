using System;
using System.Text.RegularExpressions;

namespace PoliceBackgroundCheckSystem
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ClearRecoverySession();

                if (Request.QueryString["required"] == "1")
                {
                    ShowMessage(
                        "An administrator has required a password reset. Verify your registered phone number to choose a new password.");
                }
            }
        }


        // ============================================================
        // CONTINUE BUTTON
        // ============================================================

        protected void btnContinue_Click(
            object sender,
            EventArgs e)
        {
            ClearMessage();

            string phone = txtPhone.Text.Trim();


            // --------------------------------------------------------
            // CHECK EMPTY PHONE
            // --------------------------------------------------------

            if (string.IsNullOrWhiteSpace(phone))
            {
                ShowMessage(
                    "Please enter your registered Ghana phone number."
                );

                return;
            }


            // --------------------------------------------------------
            // NORMALIZE PHONE
            // --------------------------------------------------------

            string normalizedPhone =
                NormalizeGhanaPhone(phone);


            if (string.IsNullOrEmpty(normalizedPhone))
            {
                ShowMessage(
                    "Please enter a valid Ghana mobile number."
                );

                return;
            }


            // --------------------------------------------------------
            // CLEAR OLD RESET INFORMATION
            // --------------------------------------------------------

            Session.Remove("PasswordResetOtp");
            Session.Remove("PasswordResetOtpExpiry");
            Session.Remove("PasswordResetOtpAttempts");
            Session.Remove("PasswordResetRequestId");
            Session.Remove("PasswordResetVerified");
            Session.Remove("PasswordResetEmail");


            // --------------------------------------------------------
            // SAVE PHONE
            // --------------------------------------------------------

            Session["PasswordResetPhone"] =
                normalizedPhone;


            // --------------------------------------------------------
            // MOVE TO PHONE VERIFICATION
            // --------------------------------------------------------

            Response.Redirect(
                "VerifyPhone.aspx",
                false
            );

            Context.ApplicationInstance
                .CompleteRequest();
        }


        // ============================================================
        // GHANA PHONE NORMALIZATION
        // ============================================================

        private string NormalizeGhanaPhone(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone))
            {
                return "";
            }


            phone = phone
                .Trim()
                .Replace(" ", "")
                .Replace("-", "")
                .Replace("(", "")
                .Replace(")", "");


            // --------------------------------------------------------
            // LOCAL GHANA FORMAT
            // Example: 0241234567
            // --------------------------------------------------------

            if (Regex.IsMatch(
                phone,
                @"^0(2[0-9]|5[0-9])[0-9]{7}$"))
            {
                return phone;
            }


            // --------------------------------------------------------
            // INTERNATIONAL FORMAT
            // Example: +233241234567
            // --------------------------------------------------------

            if (Regex.IsMatch(
                phone,
                @"^\+233(2[0-9]|5[0-9])[0-9]{7}$"))
            {
                return "0" +
                       phone.Substring(4);
            }


            // --------------------------------------------------------
            // INTERNATIONAL WITHOUT +
            // Example: 233241234567
            // --------------------------------------------------------

            if (Regex.IsMatch(
                phone,
                @"^233(2[0-9]|5[0-9])[0-9]{7}$"))
            {
                return "0" +
                       phone.Substring(3);
            }


            return "";
        }


        // ============================================================
        // CLEAR RECOVERY SESSION
        // ============================================================

        private void ClearRecoverySession()
        {
            Session.Remove("PasswordResetPhone");
            Session.Remove("PasswordResetOtp");
            Session.Remove("PasswordResetOtpExpiry");
            Session.Remove("PasswordResetOtpAttempts");
            Session.Remove("PasswordResetEmail");
            Session.Remove("PasswordResetRequestId");
            Session.Remove("PasswordResetVerified");
        }


        // ============================================================
        // CLEAR MESSAGE
        // ============================================================

        private void ClearMessage()
        {
            lblMessage.Text = "";
            lblMessage.Visible = false;
        }


        // ============================================================
        // SHOW MESSAGE
        // ============================================================

        private void ShowMessage(string message)
        {
            lblMessage.Text = message;
            lblMessage.Visible = true;
        }
    }
}