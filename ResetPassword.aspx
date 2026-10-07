<%@ Page Title="Reset Password"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="ResetPassword.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.ResetPassword" %>

<asp:Content
    ID="TitleContent"
    ContentPlaceHolderID="TitleContent"
    runat="server">

    Reset Password

</asp:Content>


<asp:Content
    ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <style type="text/css">

        .reset-wrapper {
            min-height: 620px;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 40px 20px;
        }

        .reset-card {
            width: 100%;
            max-width: 470px;
            background: white;
            border-radius: 16px;
            padding: 42px;
            box-shadow:
                0 12px 45px rgba(0,0,0,0.08);
            border: 1px solid #e6edf5;
        }

        .reset-icon {
            width: 70px;
            height: 70px;
            margin: 0 auto 22px;
            border-radius: 50%;
            background: #eaf2fb;
            color: #0b3b78;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
        }

        .reset-title {
            text-align: center;
            color: #102a43;
            font-size: 25px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .reset-subtitle {
            text-align: center;
            color: #7b8794;
            font-size: 13px;
            line-height: 1.6;
            margin-bottom: 28px;
        }

        .field {
            margin-bottom: 20px;
        }

        .field label {
            display: block;
            margin-bottom: 8px;
            color: #334e68;
            font-size: 13px;
            font-weight: 700;
        }

        .input {
            width: 100%;
            box-sizing: border-box;
            padding: 14px;
            border: 1px solid #ccd6e0;
            border-radius: 8px;
            background: #f8fafc;
            font-size: 14px;
            outline: none;
        }

        .input:focus {
            border-color: #0b3b78;
            background: white;
            box-shadow:
                0 0 0 3px rgba(11,59,120,0.08);
        }

        .requirements {
            padding: 15px;
            background: #f8fafc;
            border: 1px solid #e6edf5;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 12px;
            color: #52606d;
            line-height: 1.8;
        }

        .requirement {
            display: block;
        }

        .valid {
            color: #16803c;
            font-weight: 700;
        }

        .invalid {
            color: #b42318;
        }

        .primary-button {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 8px;
            background:
                linear-gradient(
                    135deg,
                    #0b3b78,
                    #1259a2
                );
            color: white;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
        }

        .message {
            display: block;
            margin-bottom: 20px;
            padding: 12px;
            border-radius: 8px;
            background: #fff1f2;
            color: #b42318;
            text-align: center;
            font-size: 13px;
        }

        .success {
            background: #ecfdf3;
            color: #16803c;
        }

        .password-strength {
            margin-top: 8px;
            height: 6px;
            border-radius: 5px;
            background: #e6edf5;
            overflow: hidden;
        }

        .strength-bar {
            height: 100%;
            width: 0%;
            transition: width .2s ease;
        }

        .match-message {
            margin-top: 7px;
            font-size: 12px;
        }

    </style>


    <script type="text/javascript">

        function validatePassword() {

            var passwordInput =
                document.getElementById(
                    '<%= txtNewPassword.ClientID %>'
                );
            if (!(passwordInput instanceof HTMLInputElement)) {
                return;
            }
            var password = passwordInput.value;

            var length =
                password.length >= 8;

            var upper =
                /[A-Z]/.test(password);

            var lower =
                /[a-z]/.test(password);

            var number =
                /[0-9]/.test(password);

            var special =
                /[!@#$%^&*]/.test(password);


            setRequirement(
                'reqLength',
                length
            );

            setRequirement(
                'reqUpper',
                upper
            );

            setRequirement(
                'reqLower',
                lower
            );

            setRequirement(
                'reqNumber',
                number
            );

            setRequirement(
                'reqSpecial',
                special
            );


            var score = 0;

            if (length) score++;
            if (upper) score++;
            if (lower) score++;
            if (number) score++;
            if (special) score++;


            var bar =
                document.getElementById(
                    'strengthBar'
                );

            if (!bar) {
                checkPasswordMatch();
                return;
            }
            if (score === 0) {
                bar.style.width = '0%';
            }
            else if (score <= 2) {
                bar.style.width = '40%';
            }
            else if (score <= 4) {
                bar.style.width = '75%';
            }
            else {
                bar.style.width = '100%';
            }


            checkPasswordMatch();
        }


        function setRequirement(
            id = '',
            valid = false) {

            var element =
                document.getElementById(id);

            if (!element) {
                return;
            }
            if (valid) {

                element.className =
                    'requirement valid';

                element.innerHTML =
                    '✓ ' +
                    element.getAttribute(
                        'data-text'
                    );

            }
            else {

                element.className =
                    'requirement invalid';

                element.innerHTML =
                    '✗ ' +
                    element.getAttribute(
                        'data-text'
                    );
            }
        }


        function checkPasswordMatch() {

            var passwordInput =
                document.getElementById(
                    '<%= txtNewPassword.ClientID %>'
                );

            var confirmPasswordInput =
                document.getElementById(
                    '<%= txtConfirmPassword.ClientID %>'
                );

            var message =
                document.getElementById(
                    'matchMessage'
                );

            if (!(passwordInput instanceof HTMLInputElement) ||
                !(confirmPasswordInput instanceof HTMLInputElement) ||
                !message) {
                return;
            }
            var password = passwordInput.value;
            var confirmPassword = confirmPasswordInput.value;
            if (confirmPassword.length === 0) {

                message.innerHTML = '';

                return;
            }

            if (password === confirmPassword) {

                message.innerHTML =
                    '✓ Passwords match';

                message.className =
                    'match-message valid';

            }
            else {

                message.innerHTML =
                    '✗ Passwords do not match';

                message.className =
                    'match-message invalid';
            }
        }

    </script>

</asp:Content>


<asp:Content
    ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <asp:HiddenField ID="hfResetCsrf" runat="server" />

    <div class="reset-wrapper">

        <div class="reset-card">

            <div class="reset-icon">
                🔑
            </div>

            <h1 class="reset-title">
                Create New Password
            </h1>

            <div class="reset-subtitle">
                Your identity has been verified.
                Create a strong new password for your account.
            </div>


            <asp:Label
                ID="lblMessage"
                runat="server"
                CssClass="message"
                Visible="false">
            </asp:Label>


            <div class="field">

                <label for="<%= txtNewPassword.ClientID %>">
                    New Password
                </label>

                <asp:TextBox
                    ID="txtNewPassword"
                    runat="server"
                    CssClass="input"
                    TextMode="Password"
                    placeholder="Enter new password"
                    onkeyup="validatePassword();">
                </asp:TextBox>

            </div>


            <div class="requirements">

                <strong>Password requirements</strong>

                <span
                    id="reqLength"
                    class="requirement invalid"
                    data-text="At least 8 characters">
                    ✗ At least 8 characters
                </span>

                <span
                    id="reqUpper"
                    class="requirement invalid"
                    data-text="One uppercase letter (A-Z)">
                    ✗ One uppercase letter (A-Z)
                </span>

                <span
                    id="reqLower"
                    class="requirement invalid"
                    data-text="One lowercase letter (a-z)">
                    ✗ One lowercase letter (a-z)
                </span>

                <span
                    id="reqNumber"
                    class="requirement invalid"
                    data-text="One number (0-9)">
                    ✗ One number (0-9)
                </span>

                <span
                    id="reqSpecial"
                    class="requirement invalid"
                    data-text="One special character (!@#$%^&*)">
                    ✗ One special character (!@#$%^&*)
                </span>

                <div class="password-strength">
                    <div
                        id="strengthBar"
                        class="strength-bar">
                    </div>
                </div>

            </div>


            <div class="field">

                <label for="<%= txtConfirmPassword.ClientID %>">
                    Confirm New Password
                </label>

                <asp:TextBox
                    ID="txtConfirmPassword"
                    runat="server"
                    CssClass="input"
                    TextMode="Password"
                    placeholder="Confirm new password"
                    onkeyup="checkPasswordMatch();">
                </asp:TextBox>

                <div
                    id="matchMessage"
                    class="match-message">
                </div>

            </div>


            <asp:Button
                ID="btnResetPassword"
                runat="server"
                Text="Reset Password"
                CssClass="primary-button"
                OnClick="btnResetPassword_Click" />

        </div>

    </div>

</asp:Content>