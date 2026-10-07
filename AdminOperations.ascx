<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdminOperations.ascx.cs" Inherits="PoliceBackgroundCheckSystem.AdminOperations" %>
<%@ Register Src="~/IdentityReview.ascx" TagPrefix="uc" TagName="IdentityReview" %>
<%@ Register Src="~/StaffProfiles.ascx" TagPrefix="uc" TagName="StaffProfiles" %>
<%@ Register Src="~/SmsTracking.ascx" TagPrefix="uc" TagName="SmsTracking" %>
<style type="text/css">
    .po-ops { --po-navy:#0b2447; --po-navy2:#19376d; --po-ink:#14213a; --po-muted:#4d5d78; --po-faint:#7d8aa3; --po-line:#d9e1ee; --po-soft:#f3f6fb; --po-tint:#e3ebf8; color:var(--po-ink); font-size:12px; }
    .po-ops *, .po-ops *::before, .po-ops *::after { box-sizing:border-box; }
    .po-ops .po-nav { display:flex; flex-wrap:wrap; gap:6px; padding:10px 12px; margin:0 0 20px; background:#fff; border:1px solid var(--po-line); border-bottom:3px solid var(--po-navy); border-radius:4px; position:sticky; top:0; z-index:4; }
    .po-ops .po-nav a { padding:7px 12px; border:1px solid var(--po-line); border-radius:3px; font-size:11px; font-weight:700; color:var(--po-navy); text-decoration:none; background:var(--po-soft); }
    .po-ops .po-nav a:hover { background:var(--po-navy); color:#fff; }
    .po-ops .po-section { margin-bottom:36px; scroll-margin-top:70px; }
    .po-ops .po-section-title { margin:0 0 14px; padding-bottom:8px; border-bottom:1px solid var(--po-line); font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:1.2px; color:var(--po-navy); }
    .po-ops .po-card { background:#fff; border:1px solid var(--po-line); border-top:3px solid var(--po-navy); border-radius:4px; box-shadow:0 1px 2px rgba(11,36,71,.08),0 2px 6px rgba(11,36,71,.06); margin-bottom:16px; overflow:hidden; }
    .po-ops .po-card-head { padding:14px 20px; background:var(--po-soft); border-bottom:1px solid var(--po-line); }
    .po-ops .po-card-title { margin:0; font-size:13px; font-weight:700; text-transform:uppercase; letter-spacing:.8px; color:var(--po-navy); }
    .po-ops .po-card-sub { margin-top:3px; font-size:11px; color:var(--po-faint); }
    .po-ops .po-card-body { padding:20px 24px 22px; }
    .po-ops .po-card { margin-bottom:24px; }
    .po-ops .po-stat { display:inline-block; margin:0 0 14px; padding:10px 16px; border:1px solid var(--po-line); border-left:4px solid var(--po-navy); background:#fff; font-weight:700; color:var(--po-navy); }
    .po-ops .po-notice { margin:0 0 12px; padding:11px 14px; border:1px solid #b9c9e3; border-left:4px solid var(--po-navy); border-radius:3px; background:#eaf0f8; color:#19376d; font-size:12px; line-height:1.6; }
    .po-ops .po-notice:last-child { margin-bottom:0; }
    .po-ops .po-message { display:block; margin:0 0 14px; padding:11px 14px; border-radius:3px; background:#eaf0f8; border:1px solid #b9c9e3; color:#19376d; font-weight:600; }
    .po-ops .po-toolbar { padding:14px 20px; background:#eef3fa; border-bottom:1px solid var(--po-line); }
    .po-ops .po-filter { display:grid; grid-template-columns:1.5fr repeat(5,1fr) auto auto; gap:9px; align-items:end; }
    .po-ops label { display:block; margin-bottom:5px; font-size:9px; font-weight:700; letter-spacing:.4px; text-transform:uppercase; color:var(--po-faint); }
    .po-ops .po-input { width:100%; height:36px; padding:0 11px; border:1px solid #b8c6dd; border-radius:3px; background:#fff; font-size:12px; color:var(--po-ink); outline:none; font-family:inherit; }
    .po-ops .po-input:focus { border-color:var(--po-navy); box-shadow:0 0 0 3px rgba(23,43,77,.10); }
    .po-ops .po-btn { height:36px; padding:0 15px; border:1px solid var(--po-navy); border-radius:3px; font-size:11px; font-weight:700; cursor:pointer; background:var(--po-navy); color:#fff; }
    .po-ops .po-btn:hover { background:var(--po-navy2); }
    .po-ops .po-btn-light { background:#fff; color:var(--po-muted); border-color:#b8c6dd; }
    .po-ops .po-btn-light:hover { background:var(--po-soft); }
    .po-ops .po-hint { margin-top:8px; font-size:11px; color:var(--po-muted); line-height:1.5; }
    .po-ops .po-link { display:inline-block; padding:8px 14px; border:1px solid var(--po-navy); border-radius:3px; background:#fff; color:var(--po-navy); font-size:11px; font-weight:700; text-decoration:none; }
    .po-ops .po-link:hover { background:var(--po-navy); color:#fff; }
    .po-ops .po-deferred { display:inline-block; margin-bottom:8px; padding:3px 9px; border-radius:3px; background:var(--po-navy); color:#fff; font-size:9.5px; font-weight:700; letter-spacing:.4px; text-transform:uppercase; }
    .po-ops .po-list { margin:6px 0 0 18px; padding:0; line-height:1.7; }
    .po-ops .po-grid2 { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
    .po-ops .po-wrap { overflow-x:auto; }
    .po-ops .po-table { width:100%; border-collapse:collapse; font-size:12px; }
    .po-ops .po-table th { padding:12px 16px; text-align:left; white-space:nowrap; font-size:10px; font-weight:700; letter-spacing:.3px; text-transform:uppercase; background:var(--po-navy); color:#fff; border:0; }
    .po-ops .po-table th a { color:#fff; }
    .po-ops .po-table td { padding:12px 16px; border-bottom:1px solid var(--po-line); color:var(--po-ink); vertical-align:middle; }
    .po-ops .po-table tr:nth-child(even) td { background:#f7f9fd; }
    .po-ops .po-table tr:hover td { background:var(--po-tint); }
    .po-ops .po-table .po-empty { padding:18px; text-align:center; color:var(--po-muted); background:#fff; }
    .po-ops .po-table a { color:var(--po-navy); font-weight:700; }
    .po-ops .po-pager td { padding:11px 14px; text-align:center; background:#fff; }
    .po-ops .po-pager a, .po-ops .po-pager span { display:inline-block; margin:0 2px; padding:5px 9px; border:1px solid var(--po-line); border-radius:3px; text-decoration:none; color:var(--po-navy); font-size:11px; font-weight:700; }
    .po-ops .po-pager span { background:var(--po-navy); color:#fff; border-color:var(--po-navy); }
    .po-ops .po-sub-title { margin:18px 0 8px; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.8px; color:var(--po-navy2); }
    .po-ops .po-ribbon { display:flex; flex-wrap:wrap; gap:0; margin:0 0 12px; border:1px solid var(--po-line); border-radius:3px; background:#fff; }
    .po-ops .po-ribbon .po-rb { flex:1 1 150px; padding:7px 12px; border-right:1px solid var(--po-line); font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.3px; color:var(--po-faint); }
    .po-ops .po-ribbon .po-rb:last-child { border-right:0; }
    .po-ops .po-ribbon .po-rb span { display:block; margin-top:2px; font-size:14px; letter-spacing:0; color:var(--po-navy); }
    .po-ops .po-ribbon-wrap { padding:14px 20px 0; }
    .po-ops .po-input:focus-visible, .po-ops .po-btn:focus-visible, .po-ops a:focus-visible { outline:2px solid var(--po-navy); outline-offset:2px; }
    .po-ops .po-table caption { caption-side:top; text-align:left; padding:0; height:0; overflow:hidden; }
    .po-ops .po-filter-wide { grid-template-columns:1.5fr repeat(4,1fr) auto auto; }
    @media (max-width:1150px) { .po-ops .po-filter-wide { grid-template-columns:1fr 1fr 1fr; } }
    @media (max-width:620px) { .po-ops .po-filter-wide { grid-template-columns:1fr; } }
    @media (max-width:1150px) { .po-ops .po-filter { grid-template-columns:1fr 1fr 1fr; } }
    @media (max-width:800px) { .po-ops .po-grid2 { grid-template-columns:1fr; } .po-ops .po-nav { position:static; } }
    @media (max-width:620px) { .po-ops .po-filter { grid-template-columns:1fr; } .po-ops .po-card-body, .po-ops .po-toolbar { padding-left:14px; padding-right:14px; } }
</style>

<div class="po-ops">

    <asp:Label ID="lblModuleMessage" runat="server" CssClass="po-message" EnableViewState="false"></asp:Label>

    <!-- 1. APPLICATION MANAGEMENT -->
    <asp:Panel ID="pnlModuleApplications" runat="server">
    <section id="po-applications" class="po-section">
        <h2 class="po-section-title">Application management</h2>
        <div class="po-card">
            <div class="po-card-head">
                <h3 class="po-card-title">Applications</h3>
                <div class="po-card-sub">Search and narrow applications by status, region and submission date</div>
            </div>
            <div class="po-toolbar">
                <div class="po-filter" style="grid-template-columns:repeat(auto-fit,minmax(140px,1fr))">
                    <div>
                        <label for="<%= txtModuleSearch.ClientID %>">Search</label>
                        <asp:TextBox ID="txtModuleSearch" runat="server" CssClass="po-input" MaxLength="150" placeholder="Reference, name or ID number"></asp:TextBox>
                    </div>
                    <div>
                        <label for="<%= ddlModuleStatus.ClientID %>">Status</label>
                        <asp:DropDownList ID="ddlModuleStatus" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                            <asp:ListItem Value="Pending">Pending</asp:ListItem>
                            <asp:ListItem Value="Approved">Approved</asp:ListItem>
                            <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label for="<%= ddlModuleRegion.ClientID %>">Region (inferred)</label>
                        <asp:DropDownList ID="ddlModuleRegion" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                            <asp:ListItem Value="GA">Greater Accra</asp:ListItem>
                            <asp:ListItem Value="AK">Ashanti</asp:ListItem>
                            <asp:ListItem Value="ER">Eastern</asp:ListItem>
                            <asp:ListItem Value="WR">Western</asp:ListItem>
                            <asp:ListItem Value="CR">Central</asp:ListItem>
                            <asp:ListItem Value="VR">Volta</asp:ListItem>
                            <asp:ListItem Value="NR">Northern</asp:ListItem>
                            <asp:ListItem Value="UE">Upper East</asp:ListItem>
                            <asp:ListItem Value="UW">Upper West</asp:ListItem>
                            <asp:ListItem Value="BR">Bono</asp:ListItem>
                            <asp:ListItem Value="BE">Bono East</asp:ListItem>
                            <asp:ListItem Value="AF">Ahafo</asp:ListItem>
                            <asp:ListItem Value="WN">Western North</asp:ListItem>
                            <asp:ListItem Value="OT">Oti</asp:ListItem>
                            <asp:ListItem Value="SV">Savannah</asp:ListItem>
                            <asp:ListItem Value="NE">North East</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label for="<%= txtModuleFrom.ClientID %>">From</label>
                        <asp:TextBox ID="txtModuleFrom" runat="server" CssClass="po-input" TextMode="Date"></asp:TextBox>
                    </div>
                    <div>
                        <label for="<%= txtModuleTo.ClientID %>">To</label>
                        <asp:TextBox ID="txtModuleTo" runat="server" CssClass="po-input" TextMode="Date"></asp:TextBox>
                    </div>
                    <div>
                        <label for="<%= ddlModulePriority.ClientID %>">Priority</label>
                        <asp:DropDownList ID="ddlModulePriority" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                            <asp:ListItem Value="Normal">Normal</asp:ListItem>
                            <asp:ListItem Value="High">High</asp:ListItem>
                            <asp:ListItem Value="Urgent">Urgent</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label for="<%= ddlModulePurpose.ClientID %>">Purpose</label>
                        <asp:DropDownList ID="ddlModulePurpose" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label for="<%= ddlModuleOfficer.ClientID %>">Assigned officer</label>
                        <asp:DropDownList ID="ddlModuleOfficer" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label for="<%= ddlModuleAssignment.ClientID %>">Assignment</label>
                        <asp:DropDownList ID="ddlModuleAssignment" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                            <asp:ListItem Value="Assigned">Assigned</asp:ListItem>
                            <asp:ListItem Value="Unassigned">Unassigned</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label for="<%= ddlModuleProcessing.ClientID %>">Processing</label>
                        <asp:DropDownList ID="ddlModuleProcessing" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                            <asp:ListItem Value="Open">Open applications</asp:ListItem>
                            <asp:ListItem Value="Completed">Final reviewed</asp:ListItem>
                            <asp:ListItem Value="OverTarget">Exceeding target</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <asp:Button ID="btnModuleSearch" runat="server" Text="Search" CssClass="po-btn" OnClick="btnModuleSearch_Click" />
                    <asp:Button ID="btnModuleClear" runat="server" Text="Clear" CssClass="po-btn po-btn-light" OnClick="btnModuleClear_Click" CausesValidation="false" />
                </div>
                <div class="po-hint">Regions are inferred from the GPS location recorded with each application; they are not a declared address. Notice grids on this page list at most 1000 rows. Use these filters to narrow applications further. Analytics aggregate all database rows.</div>
            </div>
            <div class="po-ribbon-wrap"><div class="po-ribbon" role="group" aria-label="Application summary">
                <div class="po-rb">Urgent<span><asp:Label ID="lblUrgentApplications" runat="server" Text="Unavailable"></asp:Label></span></div>
                <div class="po-rb">Unassigned<span><asp:Label ID="lblUnassignedApplications" runat="server" Text="Unavailable"></asp:Label></span></div>
                <div class="po-rb">Awaiting identity review<span><asp:Label ID="lblAwaitingReview" runat="server" Text="Unavailable"></asp:Label></span></div>
                <div class="po-rb">Over processing target<span><asp:Label ID="lblOverdueApplications" runat="server" Text="Unavailable"></asp:Label></span></div>
                <div class="po-rb">Target<span><asp:Label ID="lblProcessingTarget" runat="server" Text="Unavailable"></asp:Label></span></div>
                <div class="po-rb">Scope<span style="font-size:11px"><asp:Label ID="lblApplicationScope" runat="server" Text="Unavailable"></asp:Label></span></div>
            </div></div>
            <div class="po-wrap">
                <asp:GridView ID="gvManagedApplications" runat="server" AutoGenerateColumns="false" DataKeyNames="application_id"
                    CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" UseAccessibleHeader="true"
                    OnPageIndexChanging="grid_PageIndexChanging" OnRowCommand="gvManagedApplications_RowCommand"
                    EmptyDataText="No applications match the current filters." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="application_id" HeaderText="Application" HtmlEncode="true" />
                        <asp:BoundField DataField="FullName" HeaderText="Applicant" HtmlEncode="true" />
                        <asp:BoundField DataField="Purpose" HeaderText="Purpose" HtmlEncode="true" />
                        <asp:BoundField DataField="Status" HeaderText="Status" HtmlEncode="true" />
                        <asp:BoundField DataField="Priority" HeaderText="Priority" HtmlEncode="true" />
                        <asp:BoundField DataField="AssignedOfficer" HeaderText="Officer" HtmlEncode="true" NullDisplayText="Unassigned" />
                        <asp:BoundField DataField="DateSubmitted" HeaderText="Submitted" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" />
                        <asp:BoundField DataField="CompletedProcessingHours" HeaderText="Completed (hours)" DataFormatString="{0:0.0}" HtmlEncode="false" NullDisplayText="Not final / timestamp unavailable" />
                        <asp:BoundField DataField="OpenAgeHours" HeaderText="Open age (hours)" DataFormatString="{0:0.0}" HtmlEncode="false" NullDisplayText="Not applicable / unavailable" />
                        <asp:ButtonField CommandName="Inspect" Text="Inspect" ButtonType="Link" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <div class="po-notice">Assign officers and set priority in an application's Management inspection section. Local document decisions remain in Identity Review. Final application approval and rejection remain officer-only.</div>
    </section>
    </asp:Panel>

    <!-- 2. IDENTITY VERIFICATION CENTRE -->
    <asp:Panel ID="pnlModuleIdentity" runat="server">
    <section id="po-identity" class="po-section">
        <h2 class="po-section-title">Identity Verification Centre</h2>
        <uc:IdentityReview ID="identityReview" runat="server" />
    </section>
    </asp:Panel>

    <!-- 3. OFFICER MANAGEMENT -->
    <asp:Panel ID="pnlModuleOfficers" runat="server">
    <section id="po-officers" class="po-section">
        <h2 class="po-section-title">Officer management</h2>
        <div class="po-card">
            <div class="po-card-head">
                <h3 class="po-card-title">Officers</h3>
                <div class="po-card-sub">Listing is limited to 1000 rows</div>
            </div>
            <div class="po-card-body">
                <div class="po-notice">Officer activation, deactivation and role changes remain in existing user management. <a href="#" class="po-link" onclick="gaSwitchTab('users'); return false;">Open accounts panel</a></div>
            </div>
            <div class="po-wrap">
                <asp:GridView ID="gvOfficers" runat="server" AutoGenerateColumns="false" DataKeyNames="UserID" OnRowCommand="gvOfficers_RowCommand" OnRowDataBound="gvOfficers_RowDataBound" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No officer records were found." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="UserID" HeaderText="User ID" HtmlEncode="true" />
                        <asp:BoundField DataField="Officer" HeaderText="Officer" HtmlEncode="true" />
                        <asp:BoundField DataField="StaffNumber" HeaderText="Staff number" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="Department" HeaderText="Department" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="Station" HeaderText="Station" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="Rank" HeaderText="Rank" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="AccountState" HeaderText="Account state" HtmlEncode="true" />
                        <asp:BoundField DataField="LastLoginAt" HeaderText="Last login" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" NullDisplayText="Never recorded" />
                        <asp:BoundField DataField="ActiveAssignments" HeaderText="Active" HtmlEncode="true" />
                        <asp:BoundField DataField="PendingAssignments" HeaderText="Pending" HtmlEncode="true" />
                        <asp:BoundField DataField="UnderReviewAssignments" HeaderText="Under review" HtmlEncode="true" />
                        <asp:BoundField DataField="CompletedAssignments" HeaderText="Completed" HtmlEncode="true" />
                        <asp:BoundField DataField="RecordedDecisions" HeaderText="Recorded decisions" HtmlEncode="true" />
                        <asp:ButtonField Text="Profile" CommandName="Profile" ButtonType="Link" />
                        <asp:ButtonField Text="Worklist" CommandName="Worklist" ButtonType="Link" />
                        <asp:ButtonField Text="Assign" CommandName="Assign" ButtonType="Link" />
                        <asp:ButtonField Text="Activity" CommandName="Activity" ButtonType="Link" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <uc:StaffProfiles ID="staffProfiles" runat="server" OnSaved="staffProfiles_Saved" />
    </section>
    </asp:Panel>

    <!-- 4. CASES / POLICE REPORTS -->
    <asp:Panel ID="pnlModuleCases" runat="server">
    <section id="po-cases" class="po-section">
        <h2 class="po-section-title">Police reports and workflow</h2>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Report search</h3><div class="po-card-sub">Filters application outcomes, police reviews and workflow events by application reference</div></div>
            <div class="po-toolbar">
                <div class="po-filter" style="grid-template-columns:2fr auto">
                    <div>
                        <label for="<%= txtWorkflowSearch.ClientID %>">Reference</label>
                        <asp:TextBox ID="txtWorkflowSearch" runat="server" CssClass="po-input" MaxLength="50" placeholder="Application reference"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnWorkflowSearch" runat="server" Text="Search" CssClass="po-btn" OnClick="btnWorkflowSearch_Click" />
                </div>
            </div>
        </div>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Report applications</h3><div class="po-card-sub">Application, assignment and recorded review outcome</div></div>
            <div class="po-wrap">
                <asp:GridView ID="gvReportApplications" runat="server" AutoGenerateColumns="false" DataKeyNames="application_id" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20" OnRowCommand="gvReportApplications_RowCommand" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No report applications match." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="application_id" HeaderText="Application" HtmlEncode="true" />
                        <asp:BoundField DataField="FullName" HeaderText="Applicant" HtmlEncode="true" />
                        <asp:BoundField DataField="Purpose" HeaderText="Purpose" HtmlEncode="true" />
                        <asp:BoundField DataField="Status" HeaderText="Status" HtmlEncode="true" />
                        <asp:BoundField DataField="AssignedOfficer" HeaderText="Assigned officer" HtmlEncode="true" NullDisplayText="Unassigned" />
                        <asp:BoundField DataField="ReviewedAt" HeaderText="Reviewed" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" NullDisplayText="Not reviewed" />
                        <asp:BoundField DataField="ReviewOutcome" HeaderText="Review outcome" HtmlEncode="true" NullDisplayText="No outcome recorded" />
                        <asp:ButtonField CommandName="Inspect" Text="Inspect" ButtonType="Link" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Application workflow events</h3><div class="po-card-sub">Recorded workflow history</div></div>
            <div class="po-wrap">
                <asp:GridView ID="gvWorkflowEvents" runat="server" AutoGenerateColumns="false" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No workflow events match." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="Application" HeaderText="Application" HtmlEncode="true" />
                        <asp:BoundField DataField="ActionAt" HeaderText="Action time" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" />
                        <asp:BoundField DataField="ActionType" HeaderText="Action" HtmlEncode="true" />
                        <asp:BoundField DataField="FromStatus" HeaderText="From status" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="ToStatus" HeaderText="To status" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="Actor" HeaderText="Actor" HtmlEncode="true" NullDisplayText="System" />
                        <asp:BoundField DataField="Notes" HeaderText="Notes" HtmlEncode="true" NullDisplayText="None" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>
    </asp:Panel>

    <!-- 5. SECURITY -->
    <asp:Panel ID="pnlModuleSecurity" runat="server">
    <section id="po-security" class="po-section">
        <h2 class="po-section-title">Security</h2>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Security events</h3><div class="po-card-sub">Recorded account audit logs only. IP and user agent appear only when recorded; no device identity or separate result is inferred. Listing is limited to 1000 rows.</div></div>
            <div class="po-toolbar">
                <div class="po-filter" style="grid-template-columns:2fr 1fr auto auto">
                    <div>
                        <label for="<%= txtSecuritySearch.ClientID %>">Search</label>
                        <asp:TextBox ID="txtSecuritySearch" runat="server" CssClass="po-input" MaxLength="150" placeholder="Actor, target or details"></asp:TextBox>
                    </div>
                    <div>
                        <label for="<%= ddlSecurityEvent.ClientID %>">Event type</label>
                        <asp:DropDownList ID="ddlSecurityEvent" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <asp:Button ID="btnSecuritySearch" runat="server" Text="Search" CssClass="po-btn" OnClick="btnSecuritySearch_Click" />
                    <asp:Button ID="btnSecurityClear" runat="server" Text="Clear" CssClass="po-btn po-btn-light" OnClick="btnSecurityClear_Click" CausesValidation="false" />
                </div>
            </div>
            <div class="po-ribbon-wrap"><div class="po-ribbon"><div class="po-rb">Security log summary<span style="font-size:12px"><asp:Label ID="lblSecuritySummary" runat="server" Text="Unavailable"></asp:Label></span></div></div></div>
            <div class="po-wrap">
                <asp:GridView ID="gvSecurity" runat="server" AutoGenerateColumns="false" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No security event records were found." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="CreatedAt" HeaderText="Time" DataFormatString="{0:dd MMM yyyy HH:mm:ss}" HtmlEncode="false" />
                        <asp:BoundField DataField="ActionType" HeaderText="Event" HtmlEncode="true" />
                        <asp:BoundField DataField="Actor" HeaderText="Actor" HtmlEncode="true" NullDisplayText="System" />
                        <asp:BoundField DataField="Target" HeaderText="Target" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="Details" HeaderText="Details" HtmlEncode="true" NullDisplayText="None" />
                        <asp:BoundField DataField="IPAddress" HeaderText="Recorded IP" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="UserAgent" HeaderText="Recorded user agent" HtmlEncode="true" NullDisplayText="Not recorded" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <div class="po-grid2">
            <div class="po-card">
                <div class="po-card-head"><h3 class="po-card-title">Failed login attempts and account locks</h3><div class="po-card-sub">Current lock state and failed-attempt counters. Listing is limited to 1000 rows.</div></div>
                <div class="po-wrap">
                    <asp:GridView ID="gvLockedAccounts" runat="server" AutoGenerateColumns="true" CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No locked accounts were found." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager" />
                </div>
            </div>
            <div class="po-card">
                <div class="po-card-head"><h3 class="po-card-title">Password reset requests</h3><div class="po-card-sub">Listing is limited to 1000 rows</div></div>
                <div class="po-wrap">
                    <asp:GridView ID="gvPasswordResets" runat="server" AutoGenerateColumns="true" CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No password reset requests were found." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager" />
                </div>
            </div>
        </div>
    </section>
    </asp:Panel>

    <!-- 6. ANALYTICS / REPORTING -->
    <asp:Panel ID="pnlModuleAnalytics" runat="server">
    <section id="po-analytics" class="po-section">
        <h2 class="po-section-title">Analytics and reporting</h2>
        <div class="po-notice">Analytics tables aggregate all database rows, not only the first 1000. They are tabular summaries; no estimated figures are shown.</div>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Officer assigned workload</h3><div class="po-card-sub">Counts of assignment records per officer account</div></div>
            <div class="po-wrap">
                <asp:GridView ID="gvAnalyticsWorkload" runat="server" AutoGenerateColumns="false" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No assignment workload has been recorded." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="Officer" HeaderText="Officer" HtmlEncode="true" />
                        <asp:BoundField DataField="Assigned" HeaderText="Assigned" HtmlEncode="true" />
                        <asp:BoundField DataField="Pending" HeaderText="Pending" HtmlEncode="true" />
                        <asp:BoundField DataField="UnderReview" HeaderText="Under review" HtmlEncode="true" />
                        <asp:BoundField DataField="Completed" HeaderText="Completed" HtmlEncode="true" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Operational queue</h3><div class="po-card-sub">Application counts per indicator; indicators can overlap</div></div>
            <div class="po-wrap">
                <asp:GridView ID="gvAnalyticsQueue" runat="server" AutoGenerateColumns="false" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" EmptyDataText="No queue indicators are available." EmptyDataRowStyle-CssClass="po-empty">
                    <Columns>
                        <asp:BoundField DataField="Indicator" HeaderText="Indicator" HtmlEncode="true" />
                        <asp:BoundField DataField="Applications" HeaderText="Applications" HtmlEncode="true" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Completed applications by recorded reviewer text</h3>
                <div class="po-card-sub">Legacy reviewer names are not unique officer IDs. These are counts by stored text, not reliable per-account or assigned-workload figures.</div></div>
            <div class="po-wrap"><asp:GridView ID="gvAnalyticsOfficerActivity" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No completed applications have been recorded." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager"><Columns><asp:BoundField DataField="RecordedReviewerText" HeaderText="Recorded reviewer text" HtmlEncode="true" /><asp:BoundField DataField="ApprovedApplications" HeaderText="Approved" HtmlEncode="true" /><asp:BoundField DataField="RejectedApplications" HeaderText="Rejected" HtmlEncode="true" /></Columns></asp:GridView></div>
        </div>
        <div class="po-grid2">
            <div class="po-card"><div class="po-card-head"><h3 class="po-card-title">Applications by month</h3></div>
                <div class="po-wrap"><asp:GridView ID="gvAnalyticsMonth" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No monthly application data is available." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager"><Columns><asp:BoundField DataField="Month" HeaderText="Month" HtmlEncode="true" /><asp:BoundField DataField="Applications" HeaderText="Applications" HtmlEncode="true" /></Columns></asp:GridView></div></div>
            <div class="po-card"><div class="po-card-head"><h3 class="po-card-title">Applications by purpose</h3></div>
                <div class="po-wrap"><asp:GridView ID="gvAnalyticsPurpose" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No purpose data is available." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager"><Columns><asp:BoundField DataField="Purpose" HeaderText="Purpose" HtmlEncode="true" /><asp:BoundField DataField="Applications" HeaderText="Applications" HtmlEncode="true" /></Columns></asp:GridView></div></div>
            <div class="po-card"><div class="po-card-head"><h3 class="po-card-title">Applications by region</h3><div class="po-card-sub">Regions inferred from GPS</div></div>
                <div class="po-wrap"><asp:GridView ID="gvAnalyticsRegion" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No regional data is available." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager"><Columns><asp:BoundField DataField="InferredRegion" HeaderText="Inferred region" HtmlEncode="true" /><asp:BoundField DataField="Applications" HeaderText="Applications" HtmlEncode="true" /></Columns></asp:GridView></div></div>
            <div class="po-card"><div class="po-card-head"><h3 class="po-card-title">Application status shares</h3><div class="po-card-sub">Percent denominator is all applications, not only completed ones.</div></div>
                <div class="po-wrap"><asp:GridView ID="gvAnalyticsRates" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No rate data is available." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager"><Columns><asp:BoundField DataField="Status" HeaderText="Status" HtmlEncode="true" /><asp:BoundField DataField="Applications" HeaderText="Applications" HtmlEncode="true" /><asp:BoundField DataField="Percent" HeaderText="Percent of all applications" HtmlEncode="true" /></Columns></asp:GridView></div></div>
            <div class="po-card"><div class="po-card-head"><h3 class="po-card-title">Identity verification outcomes</h3></div>
                <div class="po-wrap"><asp:GridView ID="gvAnalyticsVerification" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" CssClass="po-table" GridLines="None" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No identity verification data is available." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager"><Columns><asp:BoundField DataField="ReviewOutcome" HeaderText="Review outcome" HtmlEncode="true" /><asp:BoundField DataField="ReviewEvents" HeaderText="Review events" HtmlEncode="true" /></Columns></asp:GridView></div></div>
            <div class="po-card"><div class="po-card-head"><h3 class="po-card-title">Processing time</h3><div class="po-card-sub">Final reviewed applications with valid timestamps only. Hours.</div></div>
                <div class="po-wrap"><asp:GridView ID="gvAnalyticsProcessing" runat="server" AutoGenerateColumns="false" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No processing time data is available." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="CompletedApplicationsWithValidTimestamps" HeaderText="Completed applications (valid timestamps)" HtmlEncode="true" />
                        <asp:BoundField DataField="AverageHours" HeaderText="Average hours" DataFormatString="{0:0.0}" HtmlEncode="false" NullDisplayText="Not available" />
                        <asp:BoundField DataField="MedianHours" HeaderText="Median hours" DataFormatString="{0:0.0}" HtmlEncode="false" NullDisplayText="Not available" />
                        <asp:BoundField DataField="MinimumHours" HeaderText="Minimum hours" DataFormatString="{0:0.0}" HtmlEncode="false" NullDisplayText="Not available" />
                        <asp:BoundField DataField="MaximumHours" HeaderText="Maximum hours" DataFormatString="{0:0.0}" HtmlEncode="false" NullDisplayText="Not available" />
                    </Columns>
                </asp:GridView></div></div>
        </div>
    </section>
    </asp:Panel>

    <!-- 7. NOTIFICATIONS -->
    <asp:Panel ID="pnlModuleNotifications" runat="server">
    <section id="po-notifications" class="po-section">
        <h2 class="po-section-title">Notifications</h2>
        <uc:SmsTracking ID="smsTracking" runat="server" />
    </section>
    </asp:Panel>

    <!-- 8. PAYMENTS -->
    <asp:Panel ID="pnlModulePayments" runat="server">
    <section id="po-payments" class="po-section">
        <h2 class="po-section-title">Payments</h2>
        <div class="po-notice">The existing Hubtel workflow stores PaymentVerified as 0 (pending/unresolved), 1 (provider-confirmed paid), or 2 (failed/cancelled) for HBT- transaction references. Other references are legacy/unconfirmed, not provider-confirmed success. Recorded amounts include unsuccessful requests and are not all collected revenue. Listing is limited to 1000 rows.</div>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Payment statistics by verification state</h3><div class="po-card-sub">Recorded amounts are totals of requests in each state. Only the Successful state reflects provider-confirmed payment; other totals are not collected revenue.</div></div>
            <div class="po-wrap">
                <asp:GridView ID="gvPaymentStatistics" runat="server" AutoGenerateColumns="false" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No payment statistics are available." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="Verification" HeaderText="Verification" HtmlEncode="true" />
                        <asp:BoundField DataField="PaymentRecords" HeaderText="Payment records" HtmlEncode="true" />
                        <asp:BoundField DataField="RecordedAmountGHS" HeaderText="Recorded amount (GHS)" DataFormatString="{0:N2}" HtmlEncode="false" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
        <div class="po-card">
            <div class="po-card-head"><h3 class="po-card-title">Payment records</h3></div>
            <div class="po-toolbar">
                <div class="po-filter" style="grid-template-columns:2fr 1fr auto auto">
                    <div>
                        <label for="<%= txtPaymentSearch.ClientID %>">Search</label>
                        <asp:TextBox ID="txtPaymentSearch" runat="server" CssClass="po-input" MaxLength="150" placeholder="Transaction or application reference"></asp:TextBox>
                    </div>
                    <div>
                        <label for="<%= ddlPaymentState.ClientID %>">Verification</label>
                        <asp:DropDownList ID="ddlPaymentState" runat="server" CssClass="po-input">
                            <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                            <asp:ListItem Value="Successful">Successful</asp:ListItem>
                            <asp:ListItem Value="Pending">Pending</asp:ListItem>
                            <asp:ListItem Value="Failed">Failed</asp:ListItem>
                            <asp:ListItem Value="Legacy">Legacy</asp:ListItem>
                            <asp:ListItem Value="Unknown">Unknown</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <asp:Button ID="btnPaymentSearch" runat="server" Text="Search" CssClass="po-btn" OnClick="btnPaymentSearch_Click" />
                    <asp:Button ID="btnPaymentClear" runat="server" Text="Clear" CssClass="po-btn po-btn-light" OnClick="btnPaymentClear_Click" CausesValidation="false" />
                </div>
            </div>
            <div class="po-wrap">
                <asp:GridView ID="gvPayments" runat="server" AutoGenerateColumns="false" CssClass="po-table" GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20" OnPageIndexChanging="grid_PageIndexChanging" EmptyDataText="No payment records were found." EmptyDataRowStyle-CssClass="po-empty" PagerStyle-CssClass="po-pager">
                    <Columns>
                        <asp:BoundField DataField="PaymentID" HeaderText="Payment" HtmlEncode="true" />
                        <asp:BoundField DataField="TransactionID" HeaderText="Transaction" HtmlEncode="true" />
                        <asp:BoundField DataField="Application" HeaderText="Application" HtmlEncode="true" />
                        <asp:BoundField DataField="PaymentMethod" HeaderText="Method" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="RecordedAmountGHS" HeaderText="Recorded amount (GHS)" DataFormatString="{0:N2}" HtmlEncode="false" />
                        <asp:BoundField DataField="PaymentDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" />
                        <asp:BoundField DataField="Verification" HeaderText="Verification" HtmlEncode="true" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </section>
    </asp:Panel>
</div>
