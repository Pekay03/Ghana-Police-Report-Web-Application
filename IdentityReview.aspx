<%@ Page Title="Local Identity Document Review" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="IdentityReview.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.IdentityReviewPage" %>
<%@ Register Src="~/IdentityReview.ascx" TagPrefix="uc" TagName="IdentityReview" %>
<asp:Content ID="reviewContent" ContentPlaceHolderID="MainContent" runat="server">
    <main style="max-width:1200px;margin:32px auto;padding:24px;">
        <h1 style="color:#0b2447;">Local identity document review</h1>
        <p><a href="VettingDashboard.aspx">Officer dashboard</a> |
           <a href="AdminDashboard.aspx?tab=operations">Administration modules</a></p>
        <uc:IdentityReview ID="localIdentityReview" runat="server" />
    </main>
</asp:Content>
