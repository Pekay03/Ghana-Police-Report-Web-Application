<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="IdentityReview.ascx.cs" Inherits="PoliceBackgroundCheckSystem.IdentityReview" %>
<style type="text/css">
    .po-review { --rv-navy:#0b2447; --rv-navy2:#19376d; --rv-ink:#14213a; --rv-muted:#4d5d78; --rv-faint:#7d8aa3; --rv-line:#d9e1ee; --rv-soft:#f3f6fb; --rv-tint:#e3ebf8; color:var(--rv-ink); font-size:12px; }
    .po-review *, .po-review *::before, .po-review *::after { box-sizing:border-box; }
    .po-review .rv-card { background:#fff; border:1px solid var(--rv-line); border-radius:4px; border-top:3px solid var(--rv-navy); box-shadow:0 1px 2px rgba(11,36,71,.08),0 2px 6px rgba(11,36,71,.06); margin-bottom:16px; overflow:hidden; }
    .po-review .rv-head { padding:14px 20px; background:var(--rv-soft); border-bottom:1px solid var(--rv-line); }
    .po-review .rv-title { margin:0; font-size:13px; font-weight:700; text-transform:uppercase; letter-spacing:.8px; color:var(--rv-navy); }
    .po-review .rv-sub { margin-top:3px; font-size:11px; color:var(--rv-faint); }
    .po-review .rv-body { padding:16px 20px 18px; }
    .po-review .rv-notice { margin:0 0 12px; padding:11px 14px; border:1px solid #b9c9e3; border-left:4px solid var(--rv-navy); border-radius:3px; background:#eaf0f8; color:#19376d; font-size:12px; line-height:1.6; }
    .po-review .rv-notice ul { margin:6px 0 0 18px; padding:0; }
    .po-review .rv-message { display:block; margin:0 0 12px; padding:11px 14px; border-radius:3px; background:#eaf0f8; border:1px solid #b9c9e3; color:#19376d; font-weight:600; }
    .po-review .rv-row { display:grid; grid-template-columns:minmax(0,1fr) auto; gap:9px; align-items:end; }
    .po-review label, .po-review .rv-label { display:block; margin-bottom:5px; font-size:9px; font-weight:700; letter-spacing:.4px; text-transform:uppercase; color:var(--rv-faint); }
    .po-review .rv-input { width:100%; padding:0 11px; height:36px; border:1px solid #b8c6dd; border-radius:3px; background:#fff; font-size:12px; color:var(--rv-ink); outline:none; font-family:inherit; }
    .po-review textarea.rv-input { height:auto; min-height:90px; padding:9px 11px; resize:vertical; }
    .po-review .rv-input:focus { border-color:var(--rv-navy); box-shadow:0 0 0 3px rgba(23,43,77,.10); }
    .po-review .rv-btn { height:36px; padding:0 16px; border:0; border-radius:3px; background:var(--rv-navy); color:#fff; font-size:11px; font-weight:700; cursor:pointer; }
    .po-review .rv-btn:hover { background:var(--rv-navy2); }
    .po-review .rv-ref { display:inline-block; padding:4px 9px; border-radius:3px; background:var(--rv-navy); color:#fff; font-size:10px; font-weight:700; letter-spacing:.5px; text-transform:uppercase; }
    .po-review .rv-grid2 { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
    .po-review .rv-scroll { overflow-x:auto; }
    .po-review table { width:100%; border-collapse:collapse; font-size:12px; }
    .po-review th { padding:11px 14px; text-align:left; white-space:nowrap; font-size:10px; font-weight:700; letter-spacing:.3px; text-transform:uppercase; background:var(--rv-navy); color:#fff; }
    .po-review td { padding:11px 14px; border-bottom:1px solid var(--rv-line); color:var(--rv-ink); vertical-align:top; }
    .po-review tr:nth-child(even) td { background:#f7f9fd; }
    .po-review .rv-docs { list-style:none; margin:0; padding:0; }
    .po-review .rv-docs li { display:flex; justify-content:space-between; gap:12px; align-items:center; padding:10px 0; border-bottom:1px solid var(--rv-line); }
    .po-review .rv-docs li:last-child { border-bottom:0; }
    .po-review .rv-docs a { color:var(--rv-navy); font-weight:700; }
    .po-review .rv-avail { padding:3px 9px; border-radius:3px; background:var(--rv-tint); color:var(--rv-navy); font-size:10px; font-weight:700; text-transform:uppercase; }
    .po-review .rv-meta { margin-top:5px; font-size:11px; color:var(--rv-faint); }
    .po-review .rv-input:focus-visible, .po-review .rv-btn:focus-visible, .po-review a:focus-visible { outline:2px solid var(--rv-navy); outline-offset:2px; }
    .po-review .rv-docs a[target="_blank"]::after { content:" (new tab)"; font-weight:400; font-size:10px; color:var(--rv-faint); }
    @media (max-width:800px) { .po-review .rv-grid2 { grid-template-columns:1fr; } .po-review .rv-row { grid-template-columns:1fr; } }
</style>

<div class="po-review">
    <div class="rv-card">
        <div class="rv-head">
            <h3 class="rv-title">Identity document review</h3>
            <div class="rv-sub">Manual review of locally held applicant documents</div>
        </div>
        <div class="rv-body">
            <div class="rv-notice">
                <strong>Read before reviewing.</strong>
                <ul>
                    <li>Manual/local document consistency checking is non-authoritative. It is not NIA verification and does not confirm identity with the National Identification Authority.</li>
                    <li>Flagged and Rejected decisions require a written reason.</li>
                    <li>A document decision does not approve or reject the application. Application status is changed separately.</li>
                    <li>Missing mandatory documents block a Verified decision.</li>
                </ul>
            </div>
            <asp:Label ID="lblReviewMessage" runat="server" CssClass="rv-message" EnableViewState="false"></asp:Label>
            <div class="rv-row">
                <div>
                    <label for="<%= txtReviewReference.ClientID %>">Application reference</label>
                    <asp:TextBox ID="txtReviewReference" runat="server" CssClass="rv-input" MaxLength="50" placeholder="Enter the application reference"></asp:TextBox>
                </div>
                <asp:Button ID="btnLoadReview" runat="server" Text="Load review" CssClass="rv-btn" OnClick="btnLoadReview_Click" CausesValidation="false" />
            </div>
        </div>
    </div>

    <div class="rv-card">
        <div class="rv-head"><h3 class="rv-title">Pending local review queue</h3>
            <div class="rv-sub">Oldest pending applications with no recorded local document-review event. First 1,000 records; use a reference above for any other application.</div></div>
        <div class="rv-body rv-scroll">
            <asp:GridView ID="gvIdentityQueue" runat="server" AutoGenerateColumns="false" DataKeyNames="application_id"
                GridLines="None" UseAccessibleHeader="true" AllowPaging="true" PageSize="20"
                OnPageIndexChanging="gvIdentityQueue_PageIndexChanging" OnRowCommand="gvIdentityQueue_RowCommand"
                EmptyDataText="No pending applications without a recorded local review were found.">
                <Columns>
                    <asp:BoundField DataField="application_id" HeaderText="Application" HtmlEncode="true" />
                    <asp:BoundField DataField="FullName" HeaderText="Applicant" HtmlEncode="true" />
                    <asp:BoundField DataField="Status" HeaderText="Application status" HtmlEncode="true" />
                    <asp:BoundField DataField="DateSubmitted" HeaderText="Submitted" DataFormatString="{0:dd MMM yyyy HH:mm}" HtmlEncode="false" />
                    <asp:ButtonField CommandName="Review" Text="Open local review" ButtonType="Link" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
    <asp:Panel ID="pnlReview" runat="server" Visible="false">
        <asp:HiddenField ID="hidReviewCsrf" runat="server" />

        <div class="rv-card">
            <div class="rv-head">
                <h3 class="rv-title">Applicant record</h3>
                <div class="rv-sub">Reference <asp:Label ID="lblReviewReference" runat="server" CssClass="rv-ref"></asp:Label></div>
            </div>
            <div class="rv-body rv-scroll">
                <asp:DetailsView ID="gvApplicant" runat="server" AutoGenerateRows="true" GridLines="None" CellPadding="0" />
            </div>
        </div>

        <div class="rv-card">
            <div class="rv-head">
                <h3 class="rv-title">Stored local comparison</h3>
                <div class="rv-sub">Local consistency comparison. Non-authoritative; not NIA verification.</div>
            </div>
            <div class="rv-body rv-scroll">
                <div class="rv-notice">Stored comparison against local registry values, not content extracted from the uploaded document. This is not OCR or NIA verification. Compare the actual document preview manually.</div>
                <asp:Label ID="lblComparisonSource" runat="server" CssClass="rv-meta" style="display:block;margin:0 0 8px"></asp:Label>
                <asp:GridView ID="gvComparison" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" GridLines="None" EmptyDataText="No stored local comparison exists for this application.">
                    <Columns>
                        <asp:BoundField DataField="Field" HeaderText="Field" HtmlEncode="true" />
                        <asp:BoundField DataField="ApplicationValue" HeaderText="Application value" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="ComparedValue" HeaderText="Local registry value" HtmlEncode="true" NullDisplayText="Not recorded" />
                        <asp:BoundField DataField="Result" HeaderText="Result" HtmlEncode="true" NullDisplayText="Not recorded" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <div class="rv-grid2">
            <div class="rv-card">
                <div class="rv-head">
                    <h3 class="rv-title">Documents</h3>
                    <div class="rv-sub">Links open in a new tab</div>
                </div>
                <div class="rv-body">
                    <ul class="rv-docs">
                        <asp:Repeater ID="rptReviewDocuments" runat="server">
                            <ItemTemplate>
                                <li>
                                    <span><%#: Eval("Label") %></span>
                                    <span>
                                        <asp:HyperLink ID="lnkDocument" runat="server" NavigateUrl='<%# Eval("Url") %>' Target="_blank" rel="noopener" Text="Open"></asp:HyperLink>
                                        <span class="rv-avail"><%#: Eval("Availability") %></span>
                                    </span>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>
                </div>
            </div>

            <div class="rv-card">
                <div class="rv-head">
                    <h3 class="rv-title">Record decision</h3>
                    <div class="rv-sub">Reviewer, date, time and decision are recorded by the server</div>
                </div>
                <div class="rv-body">
                    <label for="<%= ddlReviewDecision.ClientID %>">Document decision</label>
                    <asp:DropDownList ID="ddlReviewDecision" runat="server" CssClass="rv-input">
                        <asp:ListItem Value="Verified">Verified</asp:ListItem>
                        <asp:ListItem Value="Flagged">Flagged</asp:ListItem>
                        <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                    </asp:DropDownList>
                    <div style="height:12px"></div>
                    <label for="<%= txtReviewReason.ClientID %>">Reason (required for Flagged and Rejected)</label>
                    <asp:TextBox ID="txtReviewReason" runat="server" CssClass="rv-input" TextMode="MultiLine" Rows="4" MaxLength="1000"></asp:TextBox>
                    <div class="rv-meta">Maximum 1000 characters. The server validates length and requirements.</div>
                    <div style="height:12px"></div>
                    <asp:Button ID="btnSaveReview" runat="server" Text="Save document decision" CssClass="rv-btn" OnClick="btnSaveReview_Click" CausesValidation="false" />
                </div>
            </div>
        </div>

        <div class="rv-card">
            <div class="rv-head">
                <h3 class="rv-title">Review history</h3>
                <div class="rv-sub">Complete recorded review history for this application, including legacy local-review notes.</div>
            </div>
            <div class="rv-body rv-scroll">
                <asp:GridView ID="gvReviewHistory" runat="server" AutoGenerateColumns="true" AllowPaging="false" GridLines="None" EmptyDataText="No review history has been recorded for this application." />
            </div>
        </div>
    </asp:Panel>
</div>
