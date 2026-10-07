<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ApplicationManagement.ascx.cs" Inherits="PoliceBackgroundCheckSystem.ApplicationManagement" %>
<style type="text/css">
    .am-root { --n:#0b2447; --n2:#19376d; --ink:#14213a; --mu:#4d5d78; --fa:#7d8aa3; --ln:#d9e1ee; --so:#f3f6fb; color:var(--ink); font-size:12px; }
    .am-root *, .am-root *::before, .am-root *::after { box-sizing:border-box; }
    .am-root .am-msg { display:block; margin:0 0 14px; padding:11px 14px; border:1px solid #b9c9e3; border-left:4px solid var(--n); background:#eaf0f8; color:#19376d; font-weight:600; border-radius:3px; }
    .am-root .am-msg:empty { display:none; }
    .am-root .am-grid { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:22px; }
    .am-root .am-box { border:1px solid var(--ln); border-top:3px solid var(--n); border-radius:4px; background:#fff; padding:18px 20px; }
    .am-root h5 { margin:0 0 6px; font-size:12px; text-transform:uppercase; letter-spacing:.8px; color:var(--n); }
    .am-root .am-cur { margin:0 0 14px; color:var(--mu); }
    .am-root .am-cur strong { color:var(--ink); }
    .am-root label { display:block; margin:12px 0 5px; font-size:9px; font-weight:700; letter-spacing:.4px; text-transform:uppercase; color:var(--fa); }
    .am-root .am-in { width:100%; min-height:36px; padding:7px 11px; border:1px solid #b8c6dd; border-radius:3px; background:#fff; font-size:12px; color:var(--ink); font-family:inherit; }
    .am-root .am-in:focus { outline:none; border-color:var(--n); box-shadow:0 0 0 3px rgba(23,43,77,.10); }
    .am-root textarea.am-in { min-height:72px; resize:vertical; }
    .am-root .am-actions { display:flex; flex-wrap:wrap; gap:8px; margin-top:14px; }
    .am-root .am-btn { height:36px; padding:0 16px; border:1px solid var(--n); border-radius:3px; background:var(--n); color:#fff; font-size:11px; font-weight:700; cursor:pointer; }
    .am-root .am-btn:hover { background:var(--n2); }
    .am-root .am-btn-light { background:#fff; color:var(--n); }
    .am-root .am-btn-light:hover { background:var(--so); }
    .am-root .am-wrap { overflow-x:auto; margin-bottom:18px; border:1px solid var(--ln); border-radius:4px; }
    .am-root .am-table { width:100%; border-collapse:collapse; font-size:12px; }
    .am-root .am-table th { padding:11px 14px; text-align:left; white-space:nowrap; font-size:10px; text-transform:uppercase; letter-spacing:.3px; background:var(--n); color:#fff; }
    .am-root .am-table td { padding:11px 14px; border-bottom:1px solid var(--ln); }
    .am-root .am-table tr:nth-child(even) td { background:#f7f9fd; }
    .am-root .am-empty { padding:16px; text-align:center; color:var(--mu); }
    @media (max-width:800px) { .am-root .am-grid { grid-template-columns:1fr; } }
</style>
<div class="am-root">
    <asp:Label ID="lblManagementMessage" runat="server" CssClass="am-msg" EnableViewState="false"></asp:Label>
    <asp:HiddenField ID="hidManagementCsrf" runat="server" />
    <div class="am-grid">
        <div class="am-box">
            <h5>Officer assignment</h5>
            <p class="am-cur">Assigned officer: <strong><asp:Label ID="lblAssignedOfficer" runat="server" Text="Unavailable"></asp:Label></strong></p>
            <label for="<%= ddlAssignOfficer.ClientID %>">Officer</label>
            <asp:DropDownList ID="ddlAssignOfficer" runat="server" CssClass="am-in"></asp:DropDownList>
            <label for="<%= txtAssignmentReason.ClientID %>">Reason</label>
            <asp:TextBox ID="txtAssignmentReason" runat="server" CssClass="am-in" TextMode="MultiLine" Rows="3" MaxLength="1000"></asp:TextBox>
            <div class="am-actions">
                <asp:Button ID="btnAssign" runat="server" Text="Assign officer" CssClass="am-btn" OnClick="btnAssign_Click" />
                <asp:Button ID="btnUnassign" runat="server" Text="Remove assignment" CssClass="am-btn am-btn-light" OnClick="btnUnassign_Click" />
            </div>
        </div>
        <div class="am-box">
            <h5>Priority</h5>
            <p class="am-cur">Current priority: <strong><asp:Label ID="lblCurrentPriority" runat="server" Text="Unavailable"></asp:Label></strong></p>
            <label for="<%= ddlPriority.ClientID %>">Set priority</label>
            <asp:DropDownList ID="ddlPriority" runat="server" CssClass="am-in">
                <asp:ListItem Value="Normal">Normal</asp:ListItem>
                <asp:ListItem Value="High">High</asp:ListItem>
                <asp:ListItem Value="Urgent">Urgent</asp:ListItem>
            </asp:DropDownList>
            <div class="am-actions">
                <asp:Button ID="btnPriority" runat="server" Text="Save priority" CssClass="am-btn" OnClick="btnPriority_Click" />
            </div>
        </div>
    </div>
    <h5>Assignment history</h5>
    <div class="am-wrap">
        <asp:GridView ID="gvAssignmentHistory" runat="server" AutoGenerateColumns="true" CssClass="am-table" GridLines="None" EmptyDataText="No assignment history has been recorded." EmptyDataRowStyle-CssClass="am-empty" />
    </div>
    <h5>Workflow history</h5>
    <div class="am-wrap">
        <asp:GridView ID="gvWorkflowHistory" runat="server" AutoGenerateColumns="true" CssClass="am-table" GridLines="None" EmptyDataText="No workflow history has been recorded." EmptyDataRowStyle-CssClass="am-empty" />
    </div>
</div>
