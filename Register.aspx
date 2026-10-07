<%@ Page Title="Create Account"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Register.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.Register" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <style type="text/css">

        /* =========================================================
           ROOT
        ========================================================= */

        :root {
            --police-navy: #0f3073;
            --police-navy-dark: #0a2254;
            --police-blue: #1b4f91;
            --police-gold: #c9a84c;

            --police-light: #eef3fb;

            --success: #10b981;
            --success-light: #ecfdf5;

            --danger: #dc3545;
            --danger-light: #fff1f2;

            --gray-900: #172033;
            --gray-700: #334155;
            --gray-600: #475569;
            --gray-500: #64748b;
            --gray-400: #94a3b8;
            --gray-300: #cbd5e1;
            --gray-200: #e2e8f0;
            --gray-100: #f1f5f9;
            --gray-50: #f8fafc;
        }

        * {
            box-sizing: border-box;
        }


        /* =========================================================
           PAGE
        ========================================================= */

        .register-page {
            min-height: 100vh;

            display: flex;
            align-items: center;
            justify-content: center;

            padding: 45px 18px;

            background:
                radial-gradient(
                    circle at 15% 15%,
                    rgba(201,168,76,.16),
                    transparent 42%
                ),
                radial-gradient(
                    circle at 85% 85%,
                    rgba(27,79,145,.28),
                    transparent 45%
                ),
                linear-gradient(
                    135deg,
                    var(--police-navy),
                    var(--police-navy-dark)
                );
        }


        /* =========================================================
           CARD
        ========================================================= */

        .register-shell {
            width: 100%;
            max-width: 720px;
        }

        .register-card {
            width: 100%;

            background: rgba(255,255,255,.98);

            border-radius: 22px;

            padding: 42px;

            box-shadow:
                0 25px 65px rgba(0,0,0,.35);

            border: 1px solid rgba(255,255,255,.25);

            animation: registerFade .55s ease;
        }

        @keyframes registerFade {
            from {
                opacity: 0;
                transform: translateY(20px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }


        /* =========================================================
           HEADER
        ========================================================= */

        .register-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .register-logo {
            width: 70px;
            height: 78px;

            margin: 0 auto 20px;

            display: flex;
            align-items: center;
            justify-content: center;

            background: #0b3b78;
            color: white;
            font-weight: 900;
            font-size: 17px;

            clip-path: polygon(
                50% 0%,
                92% 15%,
                92% 55%,
                75% 80%,
                50% 100%,
                25% 80%,
                8% 55%,
                8% 15%
            );
        }

        .register-logo span {
            color: inherit;
            font-size: inherit;
            font-weight: inherit;
        }

        .register-title {
            margin: 0;

            color: var(--police-navy);

            font-size: 27px;
            font-weight: 800;

            letter-spacing: -.5px;
        }

        .register-subtitle {
            margin-top: 6px;

            color: var(--gray-500);

            font-size: 13px;
        }


        /* =========================================================
           MESSAGE
        ========================================================= */

        .message,
        .success-message {
            display: block;

            padding: 13px 15px;

            margin-bottom: 20px;

            border-radius: 10px;

            font-size: 13px;

            line-height: 1.5;

            text-align: left;
        }

        .message {
            color: #991b1b;

            background: var(--danger-light);

            border: 1px solid #fecaca;
        }

        .success-message {
            color: #047857;

            background: var(--success-light);

            border: 1px solid #a7f3d0;
        }


        /* =========================================================
           ACCOUNT TYPE
        ========================================================= */

        .role-title {
            display: block;

            margin-bottom: 12px;

            color: var(--gray-700);

            font-size: 14px;
            font-weight: 700;

            letter-spacing: .2px;
        }

        .account-types {
            display: grid;

            grid-template-columns:
                repeat(3, 1fr);

            gap: 12px;

            margin-bottom: 30px;
        }


        /* Hide the actual ASP.NET radio button.
           The complete card becomes clickable. */

        .account-option {
            position: relative;

            display: block;

            cursor: pointer;

            user-select: none;
        }

        .account-option input[type="radio"] {
            position: absolute;

            opacity: 0;

            pointer-events: none;
        }


        /* =========================================================
           PROFESSIONAL ROLE CARDS
        ========================================================= */

        .account-card {
            min-height: 150px;

            display: flex;

            flex-direction: column;

            align-items: center;

            justify-content: center;

            text-align: center;

            padding: 18px 12px;

            background: #ffffff;

            border: 2px solid var(--gray-200);

            border-radius: 14px;

            transition:
                border-color .2s ease,
                background .2s ease,
                box-shadow .2s ease,
                transform .2s ease;
        }

        .account-option:hover .account-card {
            transform: translateY(-2px);

            border-color: #b8c4d4;

            box-shadow:
                0 7px 18px rgba(15,48,115,.08);
        }


        /* =========================================================
           ROLE ICON
        ========================================================= */

        .account-icon {
            width: 52px;
            height: 52px;

            display: flex;

            align-items: center;
            justify-content: center;

            margin-bottom: 10px;

            border-radius: 14px;

            background: var(--gray-100);

            font-size: 25px;

            transition: all .2s ease;
        }

        .account-name {
            display: block;

            color: var(--gray-700);

            font-size: 14px;

            font-weight: 800;
        }

        .account-description {
            display: block;

            margin-top: 4px;

            color: var(--gray-500);

            font-size: 11px;

            line-height: 1.35;
        }


        /* =========================================================
           CITIZEN SELECTED
        ========================================================= */

        .account-option:has(
            input[value="Citizen"]:checked
        ) .account-card {
            border-color: var(--police-blue);

            background: var(--police-light);

            box-shadow:
                0 0 0 3px rgba(27,79,145,.10);
        }


        /* =========================================================
           OFFICER SELECTED
        ========================================================= */

        .account-option:has(
            input[value="Police Officer"]:checked
        ) .account-card {
            border-color: var(--police-gold);

            background: #fffbeb;

            box-shadow:
                0 0 0 3px rgba(201,168,76,.12);
        }


        /* =========================================================
           ADMIN SELECTED
        ========================================================= */

        .account-option:has(
            input[value="Administrator"]:checked
        ) .account-card {
            border-color: var(--success);

            background: var(--success-light);

            box-shadow:
                0 0 0 3px rgba(16,185,129,.10);
        }


        /* =========================================================
           FALLBACK SELECTED CLASS
        ========================================================= */

        .account-option.selected .account-card {
            border-color: var(--police-blue);

            background: var(--police-light);

            box-shadow:
                0 0 0 3px rgba(27,79,145,.10);
        }


        /* =========================================================
           FORM SECTION
        ========================================================= */

        .form-section {
            margin-bottom: 25px;
        }

        .form-section-title {
            margin-bottom: 16px;

            padding-bottom: 9px;

            border-bottom: 1px solid var(--gray-200);

            color: var(--police-navy);

            font-size: 14px;

            font-weight: 800;

            letter-spacing: .2px;
        }


        /* =========================================================
           FORM GRID
        ========================================================= */

        .form-grid {
            display: grid;

            grid-template-columns:
                repeat(2, 1fr);

            gap: 15px;
        }


        /* =========================================================
           FIELD
        ========================================================= */

        .field {
            margin-bottom: 17px;
        }

        .field-full {
            grid-column: 1 / -1;
        }

        .field label {
            display: block;

            margin-bottom: 6px;

            color: var(--gray-700);

            font-size: 13px;

            font-weight: 700;
        }

        .required {
            color: var(--danger);
        }


        /* =========================================================
           INPUT
        ========================================================= */

        .input {
            width: 100%;

            padding: 12px 14px;

            border: 2px solid var(--gray-200);

            border-radius: 10px;

            background: #ffffff;

            color: var(--gray-900);

            font-size: 14px;

            outline: none;

            transition:
                border-color .2s ease,
                box-shadow .2s ease;
        }

        .input::placeholder {
            color: var(--gray-400);
        }

        .input:focus {
            border-color: var(--police-navy);

            box-shadow:
                0 0 0 4px rgba(15,48,115,.08);
        }


        /* =========================================================
           OFFICER / ADMIN SECTION
        ========================================================= */

        .officer-fields {
            display: none;

            padding: 18px;

            margin-top: 5px;

            background: var(--gray-50);

            border: 1px dashed var(--gray-300);

            border-radius: 13px;
        }

        .officer-fields.show {
            display: block;

            animation: sectionOpen .25s ease;
        }

        @keyframes sectionOpen {
            from {
                opacity: 0;
                transform: translateY(-5px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }


        /* =========================================================
           PASSWORD
        ========================================================= */

        .password-strength {
            height: 5px;

            margin-top: 7px;

            overflow: hidden;

            background: var(--gray-200);

            border-radius: 5px;
        }

        .password-strength-bar {
            width: 0%;

            height: 100%;

            border-radius: 5px;

            transition:
                width .25s ease,
                background .25s ease;
        }

        .password-strength-text {
            margin-top: 5px;

            color: var(--gray-500);

            font-size: 11px;
        }

        .password-requirements {
            display: flex;

            flex-wrap: wrap;

            gap: 5px 14px;

            margin-top: 7px;

            font-size: 11px;
        }

        .req-not-met {
            color: var(--danger);
        }

        .req-met {
            color: var(--success);
        }

        .confirm-status {
            margin-top: 5px;

            font-size: 11px;
        }

        .confirm-status.default {
            color: var(--gray-400);
        }

        .confirm-status.success {
            color: var(--success);
        }

        .confirm-status.error {
            color: var(--danger);
        }


        /* =========================================================
           VALIDATION
        ========================================================= */

        .field-error {
            display: block;

            margin-top: 5px;

            color: var(--danger);

            font-size: 11px;
        }


        /* =========================================================
           REGISTER BUTTON
        ========================================================= */

        .register-button {
            width: 100%;

            padding: 14px;

            border: none;

            border-radius: 10px;

            background:
                linear-gradient(
                    135deg,
                    var(--police-navy),
                    var(--police-blue)
                );

            color: #ffffff;

            font-size: 15px;

            font-weight: 800;

            letter-spacing: .3px;

            cursor: pointer;

            box-shadow:
                0 5px 16px rgba(15,48,115,.22);

            transition:
                transform .2s ease,
                box-shadow .2s ease,
                opacity .2s ease;
        }

        .register-button:hover {
            transform: translateY(-2px);

            box-shadow:
                0 9px 23px rgba(15,48,115,.28);
        }

        .register-button:active {
            transform: translateY(0);
        }


        /* =========================================================
           LOGIN LINK
        ========================================================= */

        .login-link {
            margin-top: 22px;

            padding-top: 18px;

            border-top: 1px solid var(--gray-100);

            text-align: center;

            color: var(--gray-500);

            font-size: 13px;
        }

        .login-link a {
            color: var(--police-navy);

            font-weight: 800;

            text-decoration: none;
        }

        .login-link a:hover {
            color: var(--police-gold);

            text-decoration: underline;
        }


        /* =========================================================
           SECURITY NOTE
        ========================================================= */

        .security-note {
            margin-top: 20px;

            padding: 14px;

            border-radius: 10px;

            background: var(--police-light);

            border: 1px solid #d9e5f5;

            color: var(--gray-600);

            font-size: 11px;

            line-height: 1.65;

            text-align: center;
        }

        .security-note strong {
            color: var(--police-navy);
        }


        /* =========================================================
           RESPONSIVE
        ========================================================= */

        @media screen and (max-width: 650px) {

            .register-card {
                padding: 30px 22px;
            }

            .account-types {
                grid-template-columns: 1fr;
            }

            .account-card {
                min-height: 105px;

                flex-direction: row;

                justify-content: flex-start;

                text-align: left;

                padding: 15px;
            }

            .account-icon {
                flex-shrink: 0;

                margin: 0 13px 0 0;
            }

            .form-grid {
                grid-template-columns: 1fr;

                gap: 0;
            }

            .field-full {
                grid-column: auto;
            }

            .register-title {
                font-size: 23px;
            }
        }

    </style>

</asp:Content>


<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="register-page">

        <div class="register-shell">

            <div class="register-card">

                <!-- =================================================
                     HEADER
                ================================================== -->

                <div class="register-header">

                    <div class="register-logo">
                        <span>GPS</span>
                    </div>

                    <h1 class="register-title">
                        Create an Account
                    </h1>

                    <div class="register-subtitle">
                        Join the Ghana Police Background Check Portal
                    </div>

                </div>


                <!-- =================================================
                     ERROR MESSAGE
                ================================================== -->

                <asp:Label
                    ID="lblMessage"
                    runat="server"
                    CssClass="message"
                    Visible="false">
                </asp:Label>


                <!-- =================================================
                     SUCCESS MESSAGE
                ================================================== -->

                <asp:Label
                    ID="lblSuccess"
                    runat="server"
                    CssClass="success-message"
                    Visible="false">
                </asp:Label>


                <asp:Panel ID="pnlCitizenAccountType" runat="server" CssClass="field register-account-type">
                    <span class="role-title">Account type</span>
                    <div class="account-card selected">
                        <span class="account-icon">👤</span>
                        <span>
                            <span class="account-name">Citizen</span>
                            <span class="account-description">Create an account to apply for a background check.</span>
                        </span>
                    </div>
                    <p class="security-note">Public sign-up creates a citizen account. Staff accounts require an administrator unless local assessment mode is explicitly enabled on this computer.</p>
                </asp:Panel>

                <asp:Panel ID="pnlAssessmentAccountType" runat="server"
                    CssClass="field register-account-type" Visible="false">
                    <label for="<%= ddlAssessmentRole.ClientID %>">Account type — local assessment</label>
                    <asp:DropDownList ID="ddlAssessmentRole" runat="server" CssClass="input">
                        <asp:ListItem Value="Citizen" Selected="True">Citizen</asp:ListItem>
                        <asp:ListItem Value="Police Officer">Police Officer</asp:ListItem>
                        <asp:ListItem Value="Administrator">Administrator</asp:ListItem>
                    </asp:DropDownList>
                    <div id="assessmentStaffDetails" style="display:none;" class="form-section">
                        <div class="form-section-title">Officer / administrator staff details</div>
                        <p class="security-note">Staff profile saving is deferred: the existing database has no staff/badge ID, station or official-rank fields. These fields are unavailable rather than accepting information that cannot be saved. Local assessment accounts can still be created.</p>
                        <div class="form-group">
                            <label for="assessmentBadge">Staff / badge ID</label>
                            <input id="assessmentBadge" type="text" class="input" disabled="disabled" placeholder="Staff profile storage unavailable" />
                        </div>
                        <div class="form-group">
                            <label for="assessmentStation">Station</label>
                            <input id="assessmentStation" type="text" class="input" disabled="disabled" placeholder="Staff profile storage unavailable" />
                        </div>
                        <div class="form-group">
                            <label for="assessmentRank">Official rank</label>
                            <input id="assessmentRank" type="text" class="input" disabled="disabled" placeholder="Staff profile storage unavailable" />
                        </div>
                    </div>
                    <p class="security-note">Choose the dashboard role to assess. This creates a real account in your configured database using your chosen password. Sign out before signing in with another role's account. Role selection is available only through localhost on this computer.</p>
                </asp:Panel>


                <!-- =================================================
                     PERSONAL INFORMATION
                ================================================== -->

                <div class="form-section">

                    <div class="form-section-title">
                        Personal Information
                    </div>


                    <!-- FULL NAME -->

                    <div class="field">

                        <label for="<%= txtFullName.ClientID %>">
                            Full Name
                            <span class="required">*</span>
                        </label>

                        <asp:TextBox
                            ID="txtFullName"
                            runat="server"
                            CssClass="input"
                            placeholder="Enter your full legal name"
                            MaxLength="100">
                        </asp:TextBox>

                    </div>


                    <!-- EMAIL + PHONE -->

                    <div class="form-grid">

                        <div class="field">

                            <label for="<%= txtEmail.ClientID %>">
                                Email Address
                                <span class="required">*</span>
                            </label>

                            <asp:TextBox
                                ID="txtEmail"
                                runat="server"
                                CssClass="input"
                                TextMode="Email"
                                placeholder="example@email.com"
                                MaxLength="100">
                            </asp:TextBox>

                        </div>


                        <div class="field">

                            <label for="<%= txtPhone.ClientID %>">
                                Ghana Phone Number
                                <span class="required">*</span>
                            </label>

                            <asp:TextBox
                                ID="txtPhone"
                                runat="server"
                                CssClass="input"
                                placeholder="0241234567"
                                MaxLength="10">
                            </asp:TextBox>

                        </div>

                    </div>

                </div>


                <!-- =================================================
                     ACCOUNT SECURITY
                ================================================== -->

                <div class="form-section">

                    <div class="form-section-title">
                        Account Security
                    </div>


                    <!-- PASSWORD -->

                    <div class="field">

                        <label for="<%= txtPassword.ClientID %>">
                            Create Password
                            <span class="required">*</span>
                        </label>

                        <asp:TextBox
                            ID="txtPassword"
                            runat="server"
                            CssClass="input"
                            TextMode="Password"
                            placeholder="Create a strong password"
                            MaxLength="100">
                        </asp:TextBox>


                        <div class="password-strength">

                            <div
                                id="passwordStrengthBar"
                                class="password-strength-bar">
                            </div>

                        </div>


                        <div
                            id="passwordStrengthText"
                            class="password-strength-text">

                            Enter a password to see strength

                        </div>


                        <div class="password-requirements">

                            <span
                                id="reqLength"
                                class="req-not-met">
                                ✗ 8+ characters
                            </span>

                            <span
                                id="reqUpper"
                                class="req-not-met">
                                ✗ Uppercase
                            </span>

                            <span
                                id="reqLower"
                                class="req-not-met">
                                ✗ Lowercase
                            </span>

                            <span
                                id="reqNumber"
                                class="req-not-met">
                                ✗ Number
                            </span>

                            <span
                                id="reqSpecial"
                                class="req-not-met">
                                ✗ Special character
                            </span>

                        </div>

                    </div>


                    <!-- CONFIRM PASSWORD -->

                    <div class="field">

                        <label for="<%= txtConfirmPassword.ClientID %>">
                            Confirm Password
                            <span class="required">*</span>
                        </label>

                        <asp:TextBox
                            ID="txtConfirmPassword"
                            runat="server"
                            CssClass="input"
                            TextMode="Password"
                            placeholder="Re-enter your password"
                            MaxLength="100">
                        </asp:TextBox>


                        <div
                            id="confirmPasswordStatus"
                            class="confirm-status default">

                            Re-enter your password to confirm

                        </div>

                    </div>

                </div>


                <!-- =================================================
                     REGISTER
                ================================================== -->

                <asp:Button
                    ID="btnRegister"
                    runat="server"
                    Text="Register →"
                    CssClass="register-button"
                    OnClick="btnRegister_Click" />


                <!-- =================================================
                     LOGIN
                ================================================== -->

                <div class="login-link">

                    Already have an account?

                    <a href="Login.aspx">
                        Sign In Here
                    </a>

                </div>


                <!-- =================================================
                     SECURITY
                ================================================== -->

                <div class="security-note">

                    <strong>Account Security</strong>

                    <br />

                    Your account information is securely stored
                    in the Ghana Police Background Check System.

                    <br />

                    A valid Ghana phone number is required for
                    account verification and password recovery.

                </div>

            </div>

        </div>

    </div>


    <!-- =============================================================
         JAVASCRIPT
    ============================================================= -->

    <script type="text/javascript">

        document.addEventListener("DOMContentLoaded", function () {
            var assessmentRole = document.getElementById("<%= ddlAssessmentRole.ClientID %>");
            var assessmentStaffDetails = document.getElementById("assessmentStaffDetails");
            function syncAssessmentStaffDetails() {
                if (!(assessmentRole instanceof HTMLSelectElement) || !assessmentStaffDetails) return;
                assessmentStaffDetails.style.display =
                    assessmentRole.value === "Police Officer" || assessmentRole.value === "Administrator" ? "" : "none";
            }
            if (assessmentRole instanceof HTMLSelectElement)
                assessmentRole.addEventListener("change", syncAssessmentStaffDetails);
            syncAssessmentStaffDetails();


            /* =====================================================
               PASSWORD STRENGTH
            ===================================================== */

            var password =
                document.getElementById(
                    "<%= txtPassword.ClientID %>"
                );

            var confirmPassword =
                document.getElementById(
                    "<%= txtConfirmPassword.ClientID %>"
                );


            if (password instanceof HTMLInputElement) {
            password.addEventListener(
                "input",
                updatePasswordStrength
            );
            }


            if (confirmPassword instanceof HTMLInputElement) {
            confirmPassword.addEventListener(
                "input",
                checkPasswordMatch
            );
            }


            function updatePasswordStrength() {

                if (!(password instanceof HTMLInputElement)) {
                    return;
                }

                var value =
                    password.value;


                var length =
                    value.length >= 8;

                var upper =
                    /[A-Z]/.test(value);

                var lower =
                    /[a-z]/.test(value);

                var number =
                    /[0-9]/.test(value);

                var special =
                    /[^A-Za-z0-9]/.test(value);


                updateRequirement(
                    "reqLength",
                    length,
                    "8+ characters"
                );

                updateRequirement(
                    "reqUpper",
                    upper,
                    "Uppercase"
                );

                updateRequirement(
                    "reqLower",
                    lower,
                    "Lowercase"
                );

                updateRequirement(
                    "reqNumber",
                    number,
                    "Number"
                );

                updateRequirement(
                    "reqSpecial",
                    special,
                    "Special character"
                );


                var strength = 0;

                if (length) strength++;
                if (upper) strength++;
                if (lower) strength++;
                if (number) strength++;
                if (special) strength++;


                var bar =
                    document.getElementById(
                        "passwordStrengthBar"
                    );

                var text =
                    document.getElementById(
                        "passwordStrengthText"
                    );


                if (!bar || !text) {
                    return;
                }

                var percentages = [
                    0,
                    20,
                    40,
                    60,
                    80,
                    100
                ];


                var labels = [
                    "Enter a password to see strength",
                    "Very Weak",
                    "Weak",
                    "Fair",
                    "Strong",
                    "Very Strong"
                ];


                var backgrounds = [
                    "#e2e8f0",
                    "#dc3545",
                    "#dc3545",
                    "#ffc107",
                    "#10b981",
                    "#10b981"
                ];


                bar.style.width =
                    percentages[strength] + "%";

                bar.style.background =
                    backgrounds[strength];

                text.textContent =
                    labels[strength];

            }


            function updateRequirement(
                id = "",
                met = false,
                label = ""
            ) {

                var element =
                    document.getElementById(id);

                if (!element) {
                    return;
                }

                if (met) {

                    element.className =
                        "req-met";

                    element.textContent =
                        "✓ " + label;

                }
                else {

                    element.className =
                        "req-not-met";

                    element.textContent =
                        "✗ " + label;

                }

            }


            /* =====================================================
               CONFIRM PASSWORD
            ===================================================== */

            function checkPasswordMatch() {

                var status =
                    document.getElementById(
                        "confirmPasswordStatus"
                    );

                if (!(password instanceof HTMLInputElement) ||
                    !(confirmPassword instanceof HTMLInputElement) ||
                    !status) {
                    return;
                }

                if (confirmPassword.value.length === 0) {

                    confirmPassword.className =
                        "input";

                    status.className =
                        "confirm-status default";

                    status.textContent =
                        "Re-enter your password to confirm";

                    return;

                }


                if (
                    password.value ===
                    confirmPassword.value
                ) {

                    confirmPassword.className =
                        "input";

                    status.className =
                        "confirm-status success";

                    status.textContent =
                        "✓ Passwords match";

                }
                else {

                    confirmPassword.className =
                        "input";

                    status.className =
                        "confirm-status error";

                    status.textContent =
                        "✗ Passwords do not match";

                }

            }

        });

    </script>

</asp:Content>