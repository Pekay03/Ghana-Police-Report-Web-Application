<%@ Page Title="Login"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Login.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.Login" %>


<asp:Content ID="TitleContent"
    ContentPlaceHolderID="TitleContent"
    runat="server">

    Secure Login

</asp:Content>


<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <style type="text/css">

        .login-wrapper {
            min-height: 620px;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-card {
            width: 100%;
            max-width: 450px;
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08);
            border: 1px solid #e7edf4;
            box-sizing: border-box;
        }

        .login-logo {
            width: 70px;
            height: 78px;
            margin: 0 auto 20px;

            background: #0b3b78;
            color: white;

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

        .login-title {
            text-align: center;
            margin-bottom: 5px;
            color: #102a43;
            font-size: 25px;
            font-weight: 800;
        }

        .login-subtitle {
            text-align: center;
            color: #7b8794;
            font-size: 13px;
            margin-bottom: 30px;
        }

        .field {
            margin-bottom: 18px;
        }

        .field label {
            display: block;
            margin-bottom: 7px;
            font-size: 13px;
            font-weight: 700;
            color: #334e68;
        }

        .input {
            width: 100%;
            padding: 13px 14px;

            border: 1px solid #ccd6e0;
            border-radius: 7px;

            background: #f8fafc;

            font-size: 14px;

            outline: none;

            box-sizing: border-box;
        }

        .input:focus {
            border-color: #0b3b78;
            background: white;

            box-shadow:
                0 0 0 3px rgba(11, 59, 120, 0.08);
        }

        .login-button {
            width: 100%;

            padding: 13px;

            border: none;
            border-radius: 7px;

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

            margin-top: 5px;
        }

        .login-button:hover {
            opacity: 0.93;
        }

        .links {
            display: flex;
            justify-content: space-between;

            margin-top: 18px;

            font-size: 12px;
        }

        .links a {
            color: #0b3b78;
            text-decoration: none;
            font-weight: 600;
        }

        .links a:hover {
            text-decoration: underline;
        }

        .message {
            display: block;

            margin-bottom: 18px;
            padding: 11px;

            border-radius: 7px;

            background: #fff1f2;
            color: #b42318;

            font-size: 13px;

            text-align: center;
        }

        .account-info {
            margin-top: 25px;

            padding: 15px;

            border-radius: 8px;

            background: #f1f6fc;

            border: 1px solid #dbe8f5;

            font-size: 12px;

            color: #52606d;

            line-height: 1.7;

            text-align: center;
        }

        .account-info strong {
            color: #0b3b78;
        }

        .account-info a {
            color: #0b3b78;
            font-weight: 700;
            text-decoration: none;
        }

        .account-info a:hover {
            text-decoration: underline;
        }

        @media screen and (max-width: 520px) {

            .login-card {
                padding: 30px 22px;
            }

            .links {
                flex-direction: column;
                gap: 12px;
                text-align: center;
            }

        }

    </style>

</asp:Content>


<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">


    <div class="login-wrapper">

        <div class="login-card">


            <!-- =====================================================
                 LOGO
            ====================================================== -->

            <div class="login-logo">
                GPS
            </div>


            <!-- =====================================================
                 TITLE
            ====================================================== -->

            <h1 class="login-title">
                Secure Login
            </h1>


            <div class="login-subtitle">
                Ghana Police Background Check System
            </div>


            <!-- =====================================================
                 ERROR / INFORMATION MESSAGE
            ====================================================== -->

            <asp:Label
                ID="lblMessage"
                runat="server"
                CssClass="message"
                Visible="false">
            </asp:Label>


            <!-- =====================================================
                 USERNAME
            ====================================================== -->

            <div class="field">

                <label for="<%= txtUsername.ClientID %>">
                    Email address
                </label>

                <asp:TextBox
                    ID="txtUsername"
                    runat="server"
                    CssClass="input"
                    placeholder="Enter your account email address"
                    autocomplete="username">
                </asp:TextBox>

            </div>


            <!-- =====================================================
                 PASSWORD
            ====================================================== -->

            <div class="field">

                <label for="<%= txtPassword.ClientID %>">
                    Password
                </label>

                <asp:TextBox
                    ID="txtPassword"
                    runat="server"
                    CssClass="input"
                    TextMode="Password"
                    placeholder="Enter your password"
                    autocomplete="current-password">
                </asp:TextBox>

            </div>


            <!-- =====================================================
                 LOGIN BUTTON
            ====================================================== -->

            <asp:Button
                ID="btnLogin"
                runat="server"
                Text="Sign In"
                CssClass="login-button"
                OnClick="btnLogin_Click" />


            <!-- =====================================================
                 LINKS
            ====================================================== -->

            <div class="links">

                <a href="ForgotPassword.aspx">
                    Forgot Password?
                </a>

                <a href="Register.aspx">
                    Create Account
                </a>

            </div>


            <!-- =====================================================
                 ACCOUNT INFORMATION
            ====================================================== -->

            <div class="account-info">

                Don't have an account yet?

                <br />

                <a href="Register.aspx">
                    Register here
                </a>

                to create your Citizen, Officer or
                Administrator account.

            </div>


        </div>

    </div>

</asp:Content>