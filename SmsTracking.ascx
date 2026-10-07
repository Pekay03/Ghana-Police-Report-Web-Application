<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SmsTracking.ascx.cs" Inherits="PoliceBackgroundCheckSystem.SmsTracking" %>
<style type="text/css">
    .sm-root { --n:#0b2447; --n2:#19376d; --ink:#14213a; --mu:#4d5d78; --fa:#7d8aa3; --ln:#d9e1ee; --so:#f3f6fb; color:var(--ink); font-size:12px; }
    .sm-root *, .sm-root *::before, .sm-root *::after { box-sizing:border-box; }
    .sm-root .sm-card { background:#fff; border:1px solid var(--ln); border-top:3px solid var(--n); border-radius:4px; margin-bottom:24px; overflow:hidden; }
    .sm-root .sm-head { padding:14px 20px; background:var(--so); border-bottom:1px solid var(--ln); }
    .sm-root .sm-title { margin:0; font-size:13px; text-transform:uppercase; letter-spacing:.8px; color:var(--n); }
    .sm-root .sm-sub { margin-top:3px; font-size:11px; color:var(--fa); }
    .sm-root .sm-notice { margin:20px 24px; padding:12px 16px; border:1px solid #b9c9e3; border-left:4px solid var(--n); border-radius:3px; background:#eaf0f8; color:#19376d; line-height:1.65; }
    .sm-root .sm-msg { display:block; margin:16px 24px 0; padding:11px 14px; border:1px solid #b9c9e3; background:#eaf0f8; color:#19376d; font-weight:600; border-radius:3px; }
    .sm-root .sm-msg:empty { display:none; }
    .sm-root .sm-filter { display:grid; grid-template-columns:2fr 1fr auto auto; gap:10px; align-items:end; padding:16px 24px; background:#eef3fa; border-top:1px solid var(--ln); border-bottom:1px solid var(--ln); }
    .sm-root label { display:block; margin-bottom:5px; font-size:9px; font-weight:700; letter-spacing:.4px; text-transform:uppercase; color:var(--fa); }
    .sm-root .sm-in { width:100%; height:36px; padding:0 11px; border:1px solid #b8c6dd; border-radius:3px; background:#fff; font-size:12px; color:var(--ink); font-family:inherit; }
    .sm-root .sm-in:focus { outline:none; border-color:var(--n); box-shadow:0 0 0 3px rgba(23,43,77,.10); }
    .sm-root .sm-btn { height:36px; padding:0 18px; border:1px solid var(--n); border-radius:3px; background:var(--n); color:#fff; font-size:11px; font-weight:700; cursor:pointer; }
    .sm-root .sm-btn:hover { background:var(--n2); }
    .sm-root .sm-wrap { overflow-x:auto; }
    .sm-root .sm-table { width:100%; border-collapse:collapse; font-size:12px; }
    .sm-root .sm-table th { padding:12px 16px; text-align:left; white-space:nowrap; font-size:10px; text-transform:uppercase; background:var(--n); color:#fff; }
    .sm-root .sm-table td { padding:12px 16px; border-bottom:1px solid var(--ln); }
    .sm-root .sm-table tr:nth-child(even) td { background:#f7f9fd; }
    .sm-root .sm-empty { padding:18px; text-align:center; color:var(--mu); background:#fff; }
    .sm-root .sm-pager td { padding:11px 14px; text-align:center; background:#fff; }
    .sm-root .sm-pager a, .sm-root .sm-pager span { display:inline-block; margin:0 2px; padding:5px 9px; border:1px solid var(--ln); border-radius:3px; text-decoration:none; color:var(--n); font-size:11px; font-weight:700; }
    .sm-root .sm-pager span { background:var(--n); color:#fff; border-color:var(--n); }
    .sm-root .sm-in:focus-visible, .sm-root .sm-btn:focus-visible { outline:2px solid var(--n); outline-offset:2px; }
    @media (max-width:700px) { .sm-root .sm-filter { grid-template-columns:1fr; padding:16px 14px; } .sm-root .sm-notice, .sm-root .sm-msg { margin-left:14px; margin-right:14px; } }
</style>
<div class="sm-root">
    <div class="sm-card">
        <div class="sm-head"><h3 class="sm-title">SMS tracking</h3><div class="sm-sub">Messages recorded by the system</div></div>
        <div class="sm-notice">Provider accepted means the provider accepted the message request over HTTP; an accepted response is not delivery to the handset. Delivery confirmation is pending verification of the Hubtel account and API receipt capability, and official handset receipts are unverified. A separate Sent state is not recorded. These logs never store credentials, OTPs or message bodies; errors are limited to safe outcome summaries.</div>
        <asp:Label ID="lblSmsMessage" runat="server" CssClass="sm-msg" EnableViewState="false"></asp:Label>
        <div class="sm-head" style="border-top:1px solid var(--ln);margin-top:16px"><h3 class="sm-title">Summary by state</h3></div>
        <div class="sm-wrap">
            <asp:GridView ID="gvSmsSummary" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="sm-table" GridLines="None" EmptyDataText="No SMS records have been stored." EmptyDataRowStyle-CssClass="sm-empty">
                <Columns>
                    <asp:BoundField DataField="StatusDisplay" HeaderText="State" HtmlEncode="true" />
                    <asp:BoundField DataField="Messages" HeaderText="Messages" HtmlEncode="true" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
    <div class="sm-card">
        <div class="sm-head"><h3 class="sm-title">Message log</h3><div class="sm-sub">Search by application reference, internal message reference or provider message ID</div></div>
        <div class="sm-filter">
            <div><label for="<%= txtSmsSearch.ClientID %>">Search</label><asp:TextBox ID="txtSmsSearch" runat="server" CssClass="sm-in" MaxLength="150" placeholder="Application or message reference"></asp:TextBox></div>
            <div><label for="<%= ddlSmsState.ClientID %>">State</label>
                <asp:DropDownList ID="ddlSmsState" runat="server" CssClass="sm-in">
                    <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                    <asp:ListItem Value="Pending">Pending</asp:ListItem>
                    <asp:ListItem Value="Submitted">Provider accepted</asp:ListItem>
                    <asp:ListItem Value="Delivered">Delivered</asp:ListItem>
                    <asp:ListItem Value="Failed">Failed</asp:ListItem>
                    <asp:ListItem Value="Unknown">Unknown</asp:ListItem>
                </asp:DropDownList></div>
            <asp:Button ID="btnSmsSearch" runat="server" Text="Search" CssClass="sm-btn" OnClick="btnSmsSearch_Click" />
            <asp:Button ID="btnSmsClear" runat="server" Text="Clear" CssClass="sm-btn" style="background:#fff;color:#4d5d78;border-color:#b8c6dd" OnClick="btnSmsClear_Click" CausesValidation="false" />
        </div>
        <div class="sm-wrap">
            <asp:GridView ID="gvSmsDelivery" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="sm-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No SMS messages match." EmptyDataRowStyle-CssClass="sm-empty" PagerStyle-CssClass="sm-pager">
                <Columns>
                    <asp:BoundField DataField="Recipient" HeaderText="Recipient (masked)" HtmlEncode="true" />
                    <asp:BoundField DataField="MessageType" HeaderText="Message type" HtmlEncode="true" />
                    <asp:BoundField DataField="Provider" HeaderText="Provider" HtmlEncode="true" />
                    <asp:BoundField DataField="Application" HeaderText="Application" HtmlEncode="true" NullDisplayText="Not linked" />
                    <asp:BoundField DataField="StatusDisplay" HeaderText="State" HtmlEncode="true" />
                    <asp:BoundField DataField="CreatedAt" HeaderText="Created" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" />
                    <asp:BoundField DataField="AcceptedAt" HeaderText="Provider accepted" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" NullDisplayText="Not recorded" />
                    <asp:BoundField DataField="DeliveredAt" HeaderText="Delivered" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" NullDisplayText="Not confirmed" />
                    <asp:BoundField DataField="MessageReference" HeaderText="Message reference" HtmlEncode="true" NullDisplayText="Not recorded" />
                    <asp:BoundField DataField="ProviderMessageID" HeaderText="Provider message ID" HtmlEncode="true" NullDisplayText="Not recorded" />
                    <asp:BoundField DataField="ErrorMessage" HeaderText="Error" HtmlEncode="true" NullDisplayText="None" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
</div>
