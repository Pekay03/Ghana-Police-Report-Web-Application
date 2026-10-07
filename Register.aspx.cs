using System;
using System.Text.RegularExpressions;

namespace PoliceBackgroundCheckSystem
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool assessment = DatabaseHelper.IsLocalAssessmentRoleSignupEnabled();
            pnlCitizenAccountType.Visible = !assessment;
            pnlAssessmentAccountType.Visible = assessment;
        }


        // ============================================================
        // REGISTER BUTTON
        // ============================================================

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // --------------------------------------------------------
            // HIDE OLD MESSAGES
            // --------------------------------------------------------

            lblMessage.Visible = false;
            lblSuccess.Visible = false;


            // --------------------------------------------------------
            // GET ACCOUNT TYPE
            // --------------------------------------------------------

            string role = GetSelectedRole();

            if (string.IsNullOrEmpty(role))
            {
                ShowError("Please select an account type.");
                return;
            }


            // --------------------------------------------------------
            // GET FORM VALUES
            // --------------------------------------------------------

            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;


            // --------------------------------------------------------
            // FULL NAME VALIDATION
            // --------------------------------------------------------

            if (string.IsNullOrWhiteSpace(fullName))
            {
                ShowError("Please enter your full name.");
                return;
            }


            // --------------------------------------------------------
            // EMAIL VALIDATION
            // --------------------------------------------------------

            if (string.IsNullOrWhiteSpace(email))
            {
                ShowError("Please enter your email address.");
                return;
            }

            if (!IsValidEmail(email))
            {
                ShowError("Please enter a valid email address.");
                return;
            }


            // --------------------------------------------------------
            // PHONE VALIDATION
            // --------------------------------------------------------

            string normalizedPhone = NormalizeGhanaPhone(phone);

            if (string.IsNullOrEmpty(normalizedPhone))
            {
                ShowError(
                    "Please enter a valid Ghana mobile number, for example 0241234567."
                );

                return;
            }


            // --------------------------------------------------------
            // PASSWORD VALIDATION
            // --------------------------------------------------------

            if (string.IsNullOrEmpty(password))
            {
                ShowError("Please create a password.");
                return;
            }

            if (password.Length < 8)
            {
                ShowError(
                    "Password must contain at least 8 characters."
                );

                return;
            }

            if (!Regex.IsMatch(password, "[A-Z]"))
            {
                ShowError(
                    "Password must contain at least one uppercase letter."
                );

                return;
            }

            if (!Regex.IsMatch(password, "[a-z]"))
            {
                ShowError(
                    "Password must contain at least one lowercase letter."
                );

                return;
            }

            if (!Regex.IsMatch(password, "[0-9]"))
            {
                ShowError(
                    "Password must contain at least one number."
                );

                return;
            }

            if (!Regex.IsMatch(password, @"[!@#$%^&*]"))
            {
                ShowError(
                    "Password must contain at least one special character."
                );

                return;
            }


            // --------------------------------------------------------
            // CONFIRM PASSWORD
            // --------------------------------------------------------

            if (string.IsNullOrEmpty(confirmPassword))
            {
                ShowError(
                    "Please confirm your password."
                );

                return;
            }

            if (password != confirmPassword)
            {
                ShowError(
                    "The passwords do not match."
                );

                return;
            }


            // --------------------------------------------------------
            // SPLIT FULL NAME
            // --------------------------------------------------------

            string firstName;
            string lastName;

            string[] nameParts =
                fullName.Split(
                    new char[] { ' ' },
                    StringSplitOptions.RemoveEmptyEntries
                );

            if (nameParts.Length == 1)
            {
                firstName = nameParts[0];
                lastName = "";
            }
            else
            {
                firstName = nameParts[0];

                lastName =
                    string.Join(
                        " ",
                        nameParts,
                        1,
                        nameParts.Length - 1
                    );
            }


            // --------------------------------------------------------
            // CREATE USER OBJECT
            // --------------------------------------------------------

            UserAccount user = new UserAccount();

            user.FirstName = firstName;
            user.LastName = lastName;
            user.Email = email;
            user.Phone = normalizedPhone;
            user.Password = password;
            user.Role = role;


            // --------------------------------------------------------
            // SAVE USER
            // --------------------------------------------------------

            // RegisterUser performs both duplicate checks on its connection.
            // Avoid the separate fail-silent EmailExists/PhoneExists helpers:
            // a connection error must be reported as a setup failure, not as
            // an assertion that the submitted account does not exist.
            string errorMessage;

            bool registered =
                DatabaseHelper.RegisterUser(
                    user,
                    out errorMessage
                );


            // --------------------------------------------------------
            // REGISTRATION FAILED
            // --------------------------------------------------------

            if (!registered)
            {
                ShowError(errorMessage);
                return;
            }


            // --------------------------------------------------------
            // SUCCESS
            // --------------------------------------------------------

            try
            {
                string messageId = PoliceBackgroundCheckSystem.Helpers.HubtelSmsService.SendRegistrationConfirmation(normalizedPhone, user.UserID);
                ShowSuccess("Account created. Hubtel accepted your registration SMS for delivery (reference " +
                    messageId + "). Handset delivery is not yet confirmed. You can now sign in.");
            }
            catch (Exception smsException)
            {
                System.Diagnostics.Trace.TraceError(
                    "Registration account created, but SMS acceptance failed ({0}).",
                    smsException.GetType().Name);
                string detail = smsException is System.Configuration.ConfigurationErrorsException ||
                    smsException is InvalidOperationException || smsException is FormatException
                    ? smsException.Message
                    : "The SMS provider could not be reached or returned an invalid response.";
                ShowError("Your account was created, but the registration SMS was not confirmed. " +
                    detail + " You can sign in; do not register the same account again.");
            }


            // --------------------------------------------------------
            // CLEAR FORM
            // --------------------------------------------------------

            txtFullName.Text = "";
            txtEmail.Text = "";
            txtPhone.Text = "";
            txtPassword.Text = "";
            txtConfirmPassword.Text = "";
        }


        // ============================================================
        // GET SELECTED ROLE
        // ============================================================

        private string GetSelectedRole()
        {
            // Re-check on every POST; a hidden/forged form field cannot enable
            // privileged signup when the local assessment gate is closed.
            if (!DatabaseHelper.IsLocalAssessmentRoleSignupEnabled())
                return "Citizen";

            string role = ddlAssessmentRole.SelectedValue;
            if (role == "Citizen" || role == "Police Officer" || role == "Administrator")
                return role;

            return string.Empty;
        }


        // ============================================================
        // EMAIL VALIDATION
        // ============================================================

        private bool IsValidEmail(string email)
        {
            return Regex.IsMatch(
                email,
                @"^[^@\s]+@[^@\s]+\.[^@\s]+$"
            );
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

            phone =
                phone.Trim()
                     .Replace(" ", "")
                     .Replace("-", "");


            // 0241234567
            if (Regex.IsMatch(
                phone,
                @"^0(2[0-9]|5[0-9])[0-9]{7}$"))
            {
                return phone;
            }


            // +233241234567
            if (Regex.IsMatch(
                phone,
                @"^\+233(2[0-9]|5[0-9])[0-9]{7}$"))
            {
                return "0" + phone.Substring(4);
            }


            // 233241234567
            if (Regex.IsMatch(
                phone,
                @"^233(2[0-9]|5[0-9])[0-9]{7}$"))
            {
                return "0" + phone.Substring(3);
            }


            return "";
        }


        // ============================================================
        // ERROR MESSAGE
        // ============================================================

        private void ShowError(string message)
        {
            lblSuccess.Visible = false;

            lblMessage.Text = message;
            lblMessage.Visible = true;
        }


        // ============================================================
        // SUCCESS MESSAGE
        // ============================================================

        private void ShowSuccess(string message)
        {
            lblMessage.Visible = false;

            lblSuccess.Text = message;
            lblSuccess.Visible = true;
        }
    }
}