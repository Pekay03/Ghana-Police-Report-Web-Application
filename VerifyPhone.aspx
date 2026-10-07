<%@ Page Title="Verify Phone"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="VerifyPhone.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.VerifyPhone" %>

<asp:Content
    ID="TitleContent"
    ContentPlaceHolderID="TitleContent"
    runat="server">

    Verify Phone

</asp:Content>


<asp:Content
    ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

    <style type="text/css">

        .verify-wrapper {
            min-height: 620px;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 40px 20px;
        }

        .verify-card {
            width: 100%;
            max-width: 460px;
            background: #ffffff;
            border-radius: 16px;
            padding: 42px;
            box-shadow:
                0 12px 45px rgba(0,0,0,0.08);
            border: 1px solid #e6edf5;
            text-align: center;
        }

        .verify-icon {
            width: 72px;
            height: 72px;
            margin: 0 auto 22px;
            border-radius: 50%;
            background: #eaf2fb;
            color: #0b3b78;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
        }

        .verify-title {
            color: #102a43;
            font-size: 25px;
            font-weight: 800;
            margin-bottom: 10px;
        }

        .verify-text {
            color: #7b8794;
            font-size: 13px;
            line-height: 1.7;
            margin-bottom: 25px;
        }

        .phone-box {
            padding: 15px;
            background: #f1f6fc;
            border: 1px solid #dbe8f5;
            border-radius: 9px;
            color: #0b3b78;
            font-weight: 800;
            margin-bottom: 25px;
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
            font-weight: 700;
            cursor: pointer;
        }

        .secondary-button {
            display: block;
            margin-top: 15px;
            color: #0b3b78;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
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

    </style>

</asp:Content>


<asp:Content
    ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="verify-wrapper">

        <div class="verify-card">

            <div class="verify-icon">
                📱
            </div>

            <h1 class="verify-title">
                Verify Your Phone
            </h1>

            <div class="verify-text">
                If this number is registered, a six-digit
                verification code will be sent to the phone below.
            </div>


            <asp:Label
                ID="lblMessage"
                runat="server"
                CssClass="message"
                Visible="false">
            </asp:Label>


            <div class="phone-box">

                <asp:Label
                    ID="lblPhone"
                    runat="server">
                </asp:Label>

            </div>


            <asp:Button
                ID="btnSendOtp"
                runat="server"
                Text="Send Verification Code"
                CssClass="primary-button"
                OnClick="btnSendOtp_Click" />


            <a
                href="ForgotPassword.aspx"
                class="secondary-button">

                ← Change Phone Number

            </a>

        </div>

    </div>

</asp:Content>