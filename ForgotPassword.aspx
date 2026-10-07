<%@ Page Title="Forgot Password"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="ForgotPassword.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.ForgotPassword" %>


<asp:Content ID="TitleContent"
    ContentPlaceHolderID="TitleContent"
    runat="server">

    Forgot Password

</asp:Content>


<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

<style type="text/css">

    .forgot-wrapper {
        min-height: 620px;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 40px 20px;
        background: #f7f9fc;
    }

    .forgot-card {
        width: 100%;
        max-width: 470px;
        background: #ffffff;
        border-radius: 18px;
        padding: 40px;
        box-shadow: 0 15px 45px rgba(0,0,0,.08);
        border: 1px solid #e5eaf0;
    }

    .forgot-logo {
        width: 70px;
        height: 78px;
        margin: 0 auto 20px;

        background: #0b3b78;
        color: #ffffff;

        display: flex;
        align-items: center;
        justify-content: center;

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

    .forgot-title {
        text-align: center;
        color: #102a43;
        font-size: 26px;
        font-weight: 800;
        margin: 0 0 7px;
    }

    .forgot-subtitle {
        text-align: center;
        color: #7b8794;
        font-size: 13px;
        line-height: 1.6;
        margin-bottom: 30px;
    }

    .message {
        display: block;
        padding: 12px;
        margin-bottom: 20px;

        border-radius: 8px;

        background: #fff1f2;
        border: 1px solid #fecdd3;

        color: #b42318;

        font-size: 13px;
        text-align: center;
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

        color: #102a43;
        font-size: 14px;

        outline: none;

        transition: all .2s ease;
    }

    .input:focus {
        border-color: #0b3b78;
        background: #ffffff;

        box-shadow:
            0 0 0 3px rgba(11,59,120,.08);
    }

    .phone-help {
        margin-top: 7px;

        color: #7b8794;
        font-size: 11px;
        line-height: 1.5;
    }

    .continue-button {
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

        color: #ffffff;

        font-size: 14px;
        font-weight: 700;

        cursor: pointer;

        margin-top: 5px;

        transition: opacity .2s ease;
    }

    .continue-button:hover {
        opacity: .92;
    }

    .back-login {
        text-align: center;
        margin-top: 21px;

        font-size: 13px;
        color: #52606d;
    }

    .back-login a {
        color: #0b3b78;
        font-weight: 700;
        text-decoration: none;
    }

    .back-login a:hover {
        text-decoration: underline;
    }

    .security-note {
        margin-top: 22px;

        padding: 15px;

        background: #f1f6fc;

        border: 1px solid #dbe8f5;

        border-radius: 9px;

        color: #52606d;

        font-size: 12px;

        line-height: 1.7;

        text-align: center;
    }

    .security-icon {
        font-size: 22px;
        margin-bottom: 5px;
    }

    @media screen and (max-width: 520px) {

        .forgot-card {
            padding: 30px 22px;
        }

    }

</style>

</asp:Content>


<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">


<div class="forgot-wrapper">

    <div class="forgot-card">


        <!-- GPS LOGO -->

        <div class="forgot-logo">
            GPS
        </div>


        <!-- TITLE -->

        <h1 class="forgot-title">
            Forgot Password?
        </h1>


        <div class="forgot-subtitle">

            Enter the Ghana mobile number registered
            with your account.

            <br />

            We will use it to verify your identity
            before allowing you to reset your password.

        </div>


        <!-- MESSAGE -->

        <asp:Label
            ID="lblMessage"
            runat="server"
            CssClass="message"
            Visible="false">
        </asp:Label>


        <!-- PHONE -->

        <div class="field">

            <label for="<%= txtPhone.ClientID %>">

                Registered Ghana Phone Number

            </label>


            <asp:TextBox
                ID="txtPhone"
                runat="server"
                CssClass="input"
                placeholder="0241234567"
                MaxLength="15"
                autocomplete="tel">
            </asp:TextBox>


            <div class="phone-help">

                Accepted formats:
                0241234567,
                +233241234567,
                or 233241234567.

            </div>

        </div>


        <!-- CONTINUE -->

        <asp:Button
            ID="btnContinue"
            runat="server"
            Text="Continue"
            CssClass="continue-button"
            OnClick="btnContinue_Click" />


        <!-- DIRECT LOGIN -->

        <div class="back-login">

            Remember your password?

            <a href="Login.aspx">
                Back to Login
            </a>

        </div>


        <!-- SECURITY -->

        <div class="security-note">

            <div class="security-icon">
                🔐
            </div>

            <strong>Account Security</strong>

            <br />

            Your phone number is used only for
            account verification and password recovery.

        </div>


    </div>

</div>


</asp:Content>