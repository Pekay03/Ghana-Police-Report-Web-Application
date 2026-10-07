<%@ Page Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="CertificateManagement.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.CertificateManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .cm-page{max-width:1400px;margin:0 auto;padding:30px 24px 50px;font-family:Segoe UI,Tahoma,sans-serif;color:#14213a}
        .cm-hero{background:linear-gradient(135deg,#0b2447,#19376d);border-radius:6px;padding:30px;color:#fff;display:flex;justify-content:space-between;gap:24px;align-items:flex-end;box-shadow:0 16px 40px rgba(11,36,71,.18);margin-bottom:24px}
        .cm-eyebrow{font-size:12px;font-weight:800;letter-spacing:.13em;text-transform:uppercase;color:#a9c1ea;margin-bottom:9px}
        .cm-hero h1{margin:0;font-size:34px;line-height:1.08}
        .cm-hero p{margin:10px 0 0;color:#d6e2f5;max-width:700px}
        .cm-hero-meta{text-align:right;min-width:180px}
        .cm-hero-meta .label{font-size:12px;color:#a9bde0}
        .cm-hero-meta .value{font-size:18px;font-weight:800;margin-top:4px}
        .cm-kpis{display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:14px;margin-bottom:24px}
        .cm-kpi{background:#fff;border:1px solid #d9e1ee;border-radius:18px;padding:20px;box-shadow:0 8px 24px rgba(11,36,71,.06)}
        .cm-kpi.primary{background:#eaf0f9;border-color:#c9d6ec}
        .cm-kpi .label{font-size:12px;text-transform:uppercase;letter-spacing:.08em;color:#5b6b86;font-weight:800}
        .cm-kpi .value{font-size:30px;font-weight:900;margin-top:8px}
        .cm-kpi .sub{font-size:12px;color:#5b6b86;margin-top:5px}
        .cm-toolbar{background:#fff;border:1px solid #d9e1ee;border-radius:18px;padding:16px;display:grid;grid-template-columns:1.5fr 1fr 1fr auto;gap:12px;align-items:end;margin-bottom:16px}
        .cm-field label{display:block;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.07em;color:#5b6b86;margin-bottom:6px}
        .cm-input,.cm-select{width:100%;box-sizing:border-box;border:1px solid #b8c6dd;border-radius:11px;padding:11px 12px;background:#f7f9fd;color:#14213a}
        .cm-btn{border:0;border-radius:11px;padding:11px 18px;background:#0b2447;color:#fff;font-weight:800;cursor:pointer}
        .cm-btn:hover{background:#19376d}
        .cm-table-wrap{background:#fff;border:1px solid #d9e1ee;border-radius:20px;overflow:hidden;box-shadow:0 8px 24px rgba(11,36,71,.06)}
        .cm-table{width:100%;border-collapse:collapse}
        .cm-table th{background:#0b2447;color:#fff;font-size:11px;text-transform:uppercase;letter-spacing:.06em;text-align:left;padding:14px 16px;border-bottom:1px solid #d9e1ee}
        .cm-table td{padding:15px 16px;border-bottom:1px solid #dfe6f1;font-size:13px;vertical-align:middle}
        .cm-table tr:hover td{background:#eef3fa}
        .cm-ref{font-weight:850;color:#0b2447}
        .cm-name{font-weight:750}
        .cm-pill{display:inline-flex;align-items:center;padding:5px 9px;border-radius:999px;font-size:11px;font-weight:850}
        .cm-pill.issued{background:#0b2447;color:#ffffff}
        .cm-pill.other{background:#eef1f6;color:#4d5d78}
        .cm-action{display:inline-block;padding:7px 11px;border:1px solid #b8c6dd;border-radius:9px;color:#0b2447;text-decoration:none;font-weight:800;background:#fff}
        .cm-action:hover{background:#e3ebf8}
        .cm-empty{padding:45px;text-align:center;color:#5b6b86}
        .cm-pager{padding:15px 18px;display:flex;justify-content:space-between;align-items:center;gap:10px}
        .cm-error{display:block;margin-bottom:15px;background:#e3ebf8;color:#0b2447;border:1px solid #9fb3d3;padding:12px 14px;border-radius:12px}
        @media(max-width:1050px){.cm-kpis{grid-template-columns:1fr 1fr}.cm-toolbar{grid-template-columns:1fr 1fr}}
        @media(max-width:700px){.cm-page{padding:20px 14px 35px}.cm-hero{display:block}.cm-hero-meta{text-align:left;margin-top:20px}.cm-kpis{grid-template-columns:1fr}.cm-toolbar{grid-template-columns:1fr}.cm-table-wrap{overflow-x:auto}.cm-table{min-width:900px}}
    </style>

    <div class="cm-page">
        <section class="cm-hero">
            <div>
                <div class="cm-eyebrow">Administrative Operations · Records</div>
                <h1>Certificate Management</h1>
                <p>Manage issued background-check certificates, certificate references and issuance records linked to approved applications and verified payments.</p>
            </div>
            <div class="cm-hero-meta">
                <div class="label">Administrative View</div>
                <div class="value">Certificate Operations</div>
            </div>
        </section>

        <asp:Label ID="lblError" runat="server" CssClass="cm-error" Visible="false"></asp:Label>

        <section class="cm-kpis">
            <div class="cm-kpi primary">
                <div class="label">Certificates Issued</div>
                <div class="value"><asp:Label ID="lblTotalCertificates" runat="server">0</asp:Label></div>
                <div class="sub">Certificate records in the system</div>
            </div>
            <div class="cm-kpi">
                <div class="label">Issued Today</div>
                <div class="value"><asp:Label ID="lblIssuedToday" runat="server">0</asp:Label></div>
                <div class="sub">Created today</div>
            </div>
            <div class="cm-kpi">
                <div class="label">Verified Payments</div>
                <div class="value"><asp:Label ID="lblPaidApplications" runat="server">0</asp:Label></div>
                <div class="sub">Payment-backed applications</div>
            </div>
            <div class="cm-kpi">
                <div class="label">Awaiting Certificate</div>
                <div class="value"><asp:Label ID="lblAwaitingCertificates" runat="server">0</asp:Label></div>
                <div class="sub">Approved + paid applications</div>
            </div>
        </section>

        <section class="cm-toolbar">
            <div class="cm-field">
                <label>Search</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="cm-input" placeholder="Certificate, application ID or applicant"></asp:TextBox>
            </div>
            <div class="cm-field">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="cm-select">
                    <asp:ListItem Text="All statuses" Value=""></asp:ListItem>
                    <asp:ListItem Text="Issued" Value="Issued"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="cm-field">
                <label>Sort</label>
                <asp:DropDownList ID="ddlSort" runat="server" CssClass="cm-select">
                    <asp:ListItem Text="Newest first" Value="newest"></asp:ListItem>
                    <asp:ListItem Text="Oldest first" Value="oldest"></asp:ListItem>
                    <asp:ListItem Text="Applicant A-Z" Value="name"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <asp:Button ID="btnFilter" runat="server" Text="Apply Filters" CssClass="cm-btn" OnClick="btnFilter_Click" />
        </section>

        <section class="cm-table-wrap">
            <asp:GridView ID="gvCertificates" runat="server"
                AutoGenerateColumns="False"
                CssClass="cm-table"
                GridLines="None"
                AllowPaging="True"
                PageSize="10"
                OnPageIndexChanging="gvCertificates_PageIndexChanging"
                EmptyDataText="No certificate records match the current filters.">
                <Columns>
                    <asp:BoundField DataField="CertificateReference" HeaderText="Certificate" />
                    <asp:BoundField DataField="ApplicationReference" HeaderText="Application" />
                    <asp:BoundField DataField="FullName" HeaderText="Applicant" />
                    <asp:BoundField DataField="Purpose" HeaderText="Purpose" />
                    <asp:BoundField DataField="IssueDate" HeaderText="Issue Date" DataFormatString="{0:dd MMM yyyy, HH:mm}" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='<%# String.Equals(Convert.ToString(Eval("CertificateStatus")), "Issued", StringComparison.OrdinalIgnoreCase) ? "cm-pill issued" : "cm-pill other" %>'>
                                <%# Convert.ToString(Eval("CertificateStatus")) %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Inspect">
                        <ItemTemplate>
                            <a class="cm-action" href='<%# "VettingDetails.aspx?applicationId=" + Server.UrlEncode(Convert.ToString(Eval("ApplicationReference"))) %>'>View</a>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataRowStyle CssClass="cm-empty" />
                <PagerStyle CssClass="cm-pager" />
            </asp:GridView>
        </section>
    </div>
</asp:Content>
