using System;
using PoliceBackgroundCheckSystem.Helpers;

namespace PoliceBackgroundCheckSystem
{
    public partial class VerifyPhone : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string phone =
                    Convert.ToString(
                        Session["PasswordResetPhone"]);

                if (string.IsNullOrWhiteSpace(phone))
                {
                    Response.Redirect(
                        "ForgotPassword.aspx",
                        false);

                    Context.ApplicationInstance
                           .CompleteRequest();

                    return;
                }

                lblPhone.Text =
                    MaskPhone(phone);
            }
        }


        // ============================================================
        // SEND OTP
        // ============================================================

        protected void btnSendOtp_Click(
            object sender,
            EventArgs e)
        {
            string phone =
                Convert.ToString(
                    Session["PasswordResetPhone"]);

            Session.Remove("PasswordResetRequestId");
            Session.Remove("PasswordResetVerified");
            Session.Remove("PasswordResetOtpVerifiedAt");

            if (string.IsNullOrWhiteSpace(phone))
            {
                Response.Redirect(
                    "ForgotPassword.aspx",
                    false);

                Context.ApplicationInstance
                       .CompleteRequest();

                return;
            }


            // --------------------------------------------------------
            // FIND ACCOUNT
            // --------------------------------------------------------

            UserAccount user =
                DatabaseHelper.GetUserByPhone(phone);


            // --------------------------------------------------------
            // USER ENUMERATION PROTECTION
            // --------------------------------------------------------

            string otp =
                SecurityHelper.GenerateOtp();


            // --------------------------------------------------------
            // STORE OTP
            // --------------------------------------------------------

            Session["PasswordResetOtp"] =
                otp;

            Session["PasswordResetOtpExpiry"] =
                DateTime.UtcNow.AddMinutes(5);

            Session["PasswordResetOtpAttempts"] =
                0;


            long resetRequestId = 0;
            bool canSend = user != null &&
                user.IsActive &&
                DatabaseHelper.TryCreatePasswordResetRequest(
                    user.UserID,
                    out resetRequestId);

            if (canSend)
            {
                try
                {
                    HubtelSmsService.SendVerificationCode(phone, otp, user.UserID);
                    Session["PasswordResetEmail"] = user.Email;
                    Session["PasswordResetRequestId"] = resetRequestId;
                    DatabaseHelper.SetPasswordResetRequestDeliveryStatus(
                        resetRequestId,
                        true);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError(
                        "Password-reset SMS delivery failed ({0}).",
                        ex.GetType().Name);

                    DatabaseHelper.SetPasswordResetRequestDeliveryStatus(
                        resetRequestId,
                        false);
                    // Keep the response indistinguishable from an unknown
                    // phone number and do not allow an undelivered code
                    // to complete a reset.
                    Session["PasswordResetEmail"] = "__NO_ACCOUNT__";
                }
            }
            else
            {
                Session["PasswordResetEmail"] = "__NO_ACCOUNT__";
            }

            Session["OtpDeliveryMessage"] =
                "If this phone number is registered, a verification code should arrive shortly. It expires in five minutes.";


            // --------------------------------------------------------
            // MOVE TO OTP PAGE
            // --------------------------------------------------------

            Response.Redirect(
                "VerifyOTP.aspx",
                false);

            Context.ApplicationInstance
                   .CompleteRequest();
        }


        // ============================================================
        // ============================================================
        // MASK PHONE
        // ============================================================

        private string MaskPhone(string phone)
        {
            if (phone.Length < 4)
            {
                return phone;
            }

            return phone.Substring(0, 3)
                   + "****"
                   + phone.Substring(
                       phone.Length - 3);
        }
    }
}