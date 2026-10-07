<%@ Page Title="Verify OTP"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="VerifyOTP.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.VerifyOTP" %>

<asp:Content
    ID="TitleContent"
    ContentPlaceHolderID="TitleContent"
    runat="server">

    Verify OTP

</asp:Content>


<asp:Content
    ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <style type="text/css">

        .otp-wrapper {
            min-height: 620px;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 40px 20px;
        }

        .otp-card {
            width: 100%;
            max-width: 460px;
            background: white;
            border-radius: 16px;
            padding: 42px;
            box-shadow:
                0 12px 45px rgba(0,0,0,0.08);
            border: 1px solid #e6edf5;
            text-align: center;
        }

        .otp-icon {
            width: 72px;
            height: 72px;
            margin: 0 auto 22px;
            border-radius: 50%;
            background: #eaf2fb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
        }

        .otp-title {
            color: #102a43;
            font-size: 25px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .otp-text {
            color: #7b8794;
            font-size: 13px;
            line-height: 1.6;
            margin-bottom: 25px;
        }

        .otp-input {
            width: 100%;
            box-sizing: border-box;
            padding: 15px;
            border: 1px solid #ccd6e0;
            border-radius: 8px;
            background: #f8fafc;
            text-align: center;
            font-size: 25px;
            font-weight: 800;
            letter-spacing: 8px;
            outline: none;
        }

        .otp-input:focus {
            border-color: #0b3b78;
            background: white;
        }

        .primary-button {
            width: 100%;
            padding: 14px;
            margin-top: 20px;
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
            font-size: 13px;
        }

        .timer {
            margin-top: 20px;
            color: #52606d;
            font-size: 12px;
        }

        .resend {
            display: block;
            margin-top: 18px;
            color: #0b3b78;
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
        }

    </style>

</asp:Content>


<asp:Content
    ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="otp-wrapper">

        <div class="otp-card">

            <div class="otp-icon">
                🔢
            </div>

            <h1 class="otp-title">
                Enter Verification Code
            </h1>

            <div class="otp-text">

                If this phone number is registered, a code should arrive shortly.

            </div>


            <asp:Label
                ID="lblMessage"
                runat="server"
                CssClass="message"
                Visible="false">
            </asp:Label>


            <asp:TextBox
                ID="txtOtp"
                runat="server"
                CssClass="otp-input"
                MaxLength="6"
                autocomplete="one-time-code">
            </asp:TextBox>


            <asp:Button
                ID="btnVerify"
                runat="server"
                Text="Verify Code"
                CssClass="primary-button"
                OnClick="btnVerify_Click" />


            <div class="timer">
                Verification code expires after
                <strong>5 minutes</strong>.
            </div>


            <a
                href="VerifyPhone.aspx"
                class="resend">

                Resend Code

            </a>

        </div>

    </div>

</asp:Content>