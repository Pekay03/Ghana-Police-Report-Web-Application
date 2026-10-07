<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="StaffProfiles.ascx.cs" Inherits="PoliceBackgroundCheckSystem.StaffProfiles" %>
<style type="text/css">
    .sp-root { --n:#0b2447; --n2:#19376d; --ink:#14213a; --mu:#4d5d78; --fa:#7d8aa3; --ln:#d9e1ee; --so:#f3f6fb; color:var(--ink); font-size:12px; background:#fff; border:1px solid var(--ln); border-top:3px solid var(--n); border-radius:4px; padding:22px 24px; margin-bottom:24px; }
    .sp-root *, .sp-root *::before, .sp-root *::after { box-sizing:border-box; }
    .sp-root h3 { margin:0 0 4px; font-size:13px; text-transform:uppercase; letter-spacing:.8px; color:var(--n); }
    .sp-root .sp-sub { margin:0 0 16px; color:var(--fa); font-size:11px; }
    .sp-root .sp-msg { display:block; margin:0 0 14px; padding:11px 14px; border:1px solid #b9c9e3; border-left:4px solid var(--n); background:#eaf0f8; color:#19376d; font-weight:600; border-radius:3px; }
    .sp-root .sp-msg:empty { display:none; }
    .sp-root label { display:block; margin:0 0 5px; font-size:9px; font-weight:700; letter-spacing:.4px; text-transform:uppercase; color:var(--fa); }
    .sp-root .sp-in { width:100%; height:36px; padding:0 11px; border:1px solid #b8c6dd; border-radius:3px; background:#fff; font-size:12px; color:var(--ink); font-family:inherit; }
    .sp-root .sp-in:focus { outline:none; border-color:var(--n); box-shadow:0 0 0 3px rgba(23,43,77,.10); }
    .sp-root .sp-pick { max-width:420px; margin-bottom:20px; }
    .sp-root .sp-facts { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:20px; }
    .sp-root .sp-fact { padding:12px 14px; border:1px solid var(--ln); border-radius:3px; background:var(--so); }
    .sp-root .sp-fact span.k { display:block; font-size:9px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; color:var(--fa); margin-bottom:4px; }
    .sp-root .sp-fact .v { font-weight:700; color:var(--ink); }
    .sp-root .sp-form { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-bottom:18px; }
    .sp-root .sp-note { margin:0 0 16px; color:var(--mu); line-height:1.6; }
    .sp-root .sp-btn { height:36px; padding:0 18px; border:1px solid var(--n); border-radius:3px; background:var(--n); color:#fff; font-size:11px; font-weight:700; cursor:pointer; }
    .sp-root .sp-btn:hover { background:var(--n2); }
    .sp-root .sp-wrap { overflow-x:auto; margin-top:22px; border:1px solid var(--ln); border-radius:4px; }
    .sp-root .sp-table { width:100%; border-collapse:collapse; font-size:12px; }
    .sp-root .sp-table th { padding:11px 14px; text-align:left; white-space:nowrap; font-size:10px; text-transform:uppercase; background:var(--n); color:#fff; }
    .sp-root .sp-table td { padding:11px 14px; border-bottom:1px solid var(--ln); }
    .sp-root .sp-empty { padding:16px; text-align:center; color:var(--mu); }
    .sp-root .sp-links { display:flex; flex-wrap:wrap; gap:8px; margin-top:8px; }
    .sp-root .sp-link { display:inline-block; padding:8px 14px; border:1px solid var(--n); border-radius:3px; color:var(--n); font-size:11px; font-weight:700; text-decoration:none; background:#fff; }
    .sp-root .sp-link:hover { background:var(--n); color:#fff; }
    .sp-root .sp-in:focus-visible, .sp-root .sp-btn:focus-visible, .sp-root .sp-link:focus-visible, .sp-root a:focus-visible { outline:2px solid var(--n); outline-offset:2px; }
    .sp-root .sp-table a { color:var(--n); font-weight:700; }
    .sp-root .sp-table tr:nth-child(even) td { background:#f7f9fd; }
    @media (max-width:900px) { .sp-root .sp-form, .sp-root .sp-facts { grid-template-columns:1fr 1fr; } }
    @media (max-width:560px) { .sp-root .sp-form, .sp-root .sp-facts { grid-template-columns:1fr; } .sp-root { padding:16px 14px; } }
</style>
<div class="sp-root">
    <h3>Staff profiles</h3>
    <p class="sp-sub">Edit staff names and profile details. Roles, account state and sign-in contacts remain managed through the existing accounts panel. Legacy creation dates are not invented.</p>
    <asp:Label ID="lblProfileMessage" runat="server" CssClass="sp-msg" EnableViewState="false"></asp:Label>
    <asp:HiddenField ID="hidProfileCsrf" runat="server" />
    <div class="sp-pick">
        <label for="<%= ddlStaffUser.ClientID %>">Staff member</label>
        <asp:DropDownList ID="ddlStaffUser" runat="server" CssClass="sp-in" AutoPostBack="true" OnSelectedIndexChanged="ddlStaffUser_SelectedIndexChanged"></asp:DropDownList>
    </div>
    <asp:Panel ID="pnlProfileFields" runat="server" Visible="false">
        <div class="sp-facts">
            <div class="sp-fact"><span class="k">Name</span><asp:Label ID="lblStaffName" runat="server" CssClass="v"></asp:Label></div>
            <div class="sp-fact"><span class="k">Role (read-only)</span><asp:Label ID="lblStaffRole" runat="server" CssClass="v"></asp:Label></div>
            <div class="sp-fact"><span class="k">Account state (read-only)</span><asp:Label ID="lblStaffState" runat="server" CssClass="v"></asp:Label></div>
            <div class="sp-fact"><span class="k">Created</span><asp:Label ID="lblStaffCreated" runat="server" CssClass="v"></asp:Label></div>
            <div class="sp-fact"><span class="k">Last login</span><asp:Label ID="lblStaffLogin" runat="server" CssClass="v"></asp:Label></div>
            <div class="sp-fact"><span class="k">Assigned applications</span><asp:Label ID="lblStaffAssigned" runat="server" CssClass="v"></asp:Label></div>
        </div>
        <div class="sp-form">
            <div><label for="<%= txtStaffFirstName.ClientID %>">First name</label><asp:TextBox ID="txtStaffFirstName" runat="server" CssClass="sp-in" MaxLength="50"></asp:TextBox></div>
            <div><label for="<%= txtStaffLastName.ClientID %>">Last name</label><asp:TextBox ID="txtStaffLastName" runat="server" CssClass="sp-in" MaxLength="50"></asp:TextBox></div>
            <div><label for="<%= txtStaffEmail.ClientID %>">Sign-in email (read-only)</label><asp:TextBox ID="txtStaffEmail" runat="server" CssClass="sp-in" MaxLength="100" ReadOnly="true"></asp:TextBox></div>
            <div><label for="<%= txtStaffPhone.ClientID %>">Recovery phone (read-only)</label><asp:TextBox ID="txtStaffPhone" runat="server" CssClass="sp-in" MaxLength="20" ReadOnly="true"></asp:TextBox></div>
            <div><label for="<%= txtStaffNumber.ClientID %>">Staff number</label><asp:TextBox ID="txtStaffNumber" runat="server" CssClass="sp-in" MaxLength="50"></asp:TextBox></div>
            <div><label for="<%= txtStaffDepartment.ClientID %>">Department</label><asp:TextBox ID="txtStaffDepartment" runat="server" CssClass="sp-in" MaxLength="150"></asp:TextBox></div>
            <div><label for="<%= txtStaffStation.ClientID %>">Station</label><asp:TextBox ID="txtStaffStation" runat="server" CssClass="sp-in" MaxLength="150"></asp:TextBox></div>
            <div><label for="<%= txtStaffRank.ClientID %>">Rank</label><asp:TextBox ID="txtStaffRank" runat="server" CssClass="sp-in" MaxLength="100"></asp:TextBox></div>
        </div>
        <asp:Button ID="btnSaveStaff" runat="server" Text="Save profile" CssClass="sp-btn" OnClick="btnSaveStaff_Click" />
        <h3 style="margin-top:24px">Scoped navigation</h3>
        <div class="sp-links">
            <asp:HyperLink ID="hlStaffWorklist" runat="server" CssClass="sp-link">Worklist</asp:HyperLink>
            <asp:HyperLink ID="hlStaffAssign" runat="server" CssClass="sp-link">Assign application</asp:HyperLink>
            <asp:HyperLink ID="hlStaffAccounts" runat="server" CssClass="sp-link">Account management</asp:HyperLink>
        </div>
        <h3 style="margin-top:24px">Assignments</h3>
        <div class="sp-wrap" style="margin-top:8px">
            <asp:GridView ID="gvStaffAssignments" runat="server" AutoGenerateColumns="false" DataKeyNames="Application" OnRowCommand="gvStaffAssignments_RowCommand" UseAccessibleHeader="true" CssClass="sp-table" GridLines="None" EmptyDataText="No applications are assigned to this staff member." EmptyDataRowStyle-CssClass="sp-empty">
                <Columns>
                    <asp:BoundField DataField="Application" HeaderText="Application" HtmlEncode="true" />
                    <asp:BoundField DataField="Applicant" HeaderText="Applicant" HtmlEncode="true" />
                    <asp:BoundField DataField="Priority" HeaderText="Priority" HtmlEncode="true" />
                    <asp:BoundField DataField="Status" HeaderText="Status" HtmlEncode="true" />
                    <asp:BoundField DataField="AssignedAt" HeaderText="Assigned" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" />
                    <asp:BoundField DataField="AssignmentState" HeaderText="Assignment state" HtmlEncode="true" />
                    <asp:BoundField DataField="UnassignedAt" HeaderText="Unassigned" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" NullDisplayText="Not unassigned" />
                    <asp:ButtonField CommandName="Inspect" Text="Inspect" ButtonType="Link" />
                </Columns>
            </asp:GridView>
        </div>
        <h3 style="margin-top:24px">Recorded activity</h3>
        <div class="sp-wrap" style="margin-top:8px">
            <div id="po-staff-activity" tabindex="-1"></div>
            <asp:GridView ID="gvStaffActivity" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="sp-table" GridLines="None" EmptyDataText="No account activity has been recorded for this staff member." EmptyDataRowStyle-CssClass="sp-empty">
                <Columns>
                    <asp:BoundField DataField="CreatedAt" HeaderText="Time" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" />
                    <asp:BoundField DataField="ActionType" HeaderText="Action" HtmlEncode="true" />
                    <asp:BoundField DataField="Actor" HeaderText="Actor" HtmlEncode="true" NullDisplayText="System" />
                    <asp:BoundField DataField="Details" HeaderText="Details" HtmlEncode="true" NullDisplayText="None" />
                </Columns>
            </asp:GridView>
        </div>
    </asp:Panel>
</div>
