<%@ Page Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="VettingDetails.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.VettingDetails" %>

<asp:Content ID="TitleContent"
    ContentPlaceHolderID="TitleContent"
    runat="server">
    Background Check Certificate
</asp:Content>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

<style type="text/css">
    :root {
        --gps-navy:#0f3073;
        --gps-navy-dark:#091f4a;
        --gps-blue:#1b4f91;
        --gps-gold:#c9a84c;
        --success:#10b981;
        --success-light:#ecfdf5;
        --danger:#dc3545;
        --danger-light:#fff1f2;
        --gray-900:#172033;
        --gray-700:#334155;
        --gray-600:#475569;
        --gray-500:#64748b;
        --gray-400:#94a3b8;
        --gray-300:#cbd5e1;
        --gray-200:#e2e8f0;
        --gray-100:#f1f5f9;
        --gray-50:#f8fafc;
    }

    * { box-sizing:border-box; }

    .certificate-page {
        min-height:100vh;
        padding:40px 18px 60px;
        background:
            radial-gradient(circle at 10% 10%, rgba(201,168,76,.13), transparent 35%),
            radial-gradient(circle at 90% 90%, rgba(27,79,145,.12), transparent 35%),
            #f5f7fb;
    }

    .certificate-container {
        width:100%;
        max-width:1000px;
        margin:0 auto;
    }

    .page-header {
        background:linear-gradient(135deg,var(--gps-navy),var(--gps-navy-dark));
        color:#fff;
        border-radius:18px;
        padding:25px 30px;
        margin-bottom:22px;
        box-shadow:0 15px 40px rgba(15,48,115,.18);
    }

    .header-content {
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:20px;
    }

    .brand-area {
        display:flex;
        align-items:center;
        gap:16px;
    }

    .gps-shield {
        width:58px;
        height:65px;
        background:linear-gradient(135deg,var(--gps-gold),#e1c878);
        color:var(--gps-navy);
        display:flex;
        align-items:center;
        justify-content:center;
        font-size:17px;
        font-weight:900;
        clip-path:polygon(50% 0%,91% 14%,91% 57%,76% 80%,50% 100%,24% 80%,9% 57%,9% 14%);
    }

    .header-title {
        margin:0;
        font-size:24px;
        font-weight:800;
    }

    .header-subtitle {
        margin-top:5px;
        color:rgba(255,255,255,.78);
        font-size:13px;
    }

    .secure-badge {
        padding:10px 14px;
        border:1px solid rgba(255,255,255,.18);
        border-radius:12px;
        background:rgba(255,255,255,.10);
        font-size:11px;
        font-weight:700;
        white-space:nowrap;
    }

    .message-box {
        display:none;
        margin-bottom:20px;
        padding:14px 16px;
        border-radius:10px;
        font-size:12px;
        line-height:1.6;
    }

    .message-box.show { display:block; }

    .message-error {
        background:var(--danger-light);
        border:1px solid #fecdd3;
        color:#b42318;
    }

    .message-success {
        background:var(--success-light);
        border:1px solid #a7f3d0;
        color:#047857;
    }

    .certificate-shell {
        background:#fff;
        border:1px solid var(--gray-200);
        border-radius:18px;
        overflow:hidden;
        box-shadow:0 12px 35px rgba(15,23,42,.07);
    }

    .certificate-topbar {
        padding:20px 28px;
        border-bottom:1px solid var(--gray-200);
        background:linear-gradient(180deg,#fff,#fbfcfe);
        display:flex;
        justify-content:space-between;
        align-items:center;
        gap:15px;
    }

    .topbar-title {
        color:var(--gps-navy);
        font-size:17px;
        font-weight:800;
    }

    .status-pill {
        display:inline-flex;
        align-items:center;
        padding:7px 12px;
        border-radius:999px;
        background:var(--success-light);
        border:1px solid #a7f3d0;
        color:#047857;
        font-size:10px;
        font-weight:800;
    }

    .certificate-document {
        margin:30px;
        border:2px solid var(--gps-gold);
        padding:34px;
        background:#fff;
        position:relative;
    }

    .certificate-document:before {
        content:"";
        position:absolute;
        inset:9px;
        border:1px solid rgba(201,168,76,.45);
        pointer-events:none;
    }

    .document-inner {
        position:relative;
        z-index:1;
    }

    .official-heading {
        text-align:center;
        border-bottom:1px solid var(--gray-200);
        padding-bottom:22px;
        margin-bottom:25px;
    }

    .republic {
        color:var(--gray-700);
        font-size:12px;
        font-weight:800;
        letter-spacing:1.4px;
        text-transform:uppercase;
    }

    .police-service {
        color:var(--gps-navy);
        font-size:22px;
        font-weight:900;
        margin-top:7px;
    }

    .certificate-title {
        color:var(--gps-navy);
        font-size:24px;
        font-weight:900;
        letter-spacing:.8px;
        margin-top:17px;
    }

    .certificate-subtitle {
        color:var(--gray-500);
        font-size:11px;
        margin-top:6px;
    }

    .reference-row {
        display:grid;
        grid-template-columns:1fr 1fr;
        gap:15px;
        margin:22px 0;
    }

    .reference-box {
        padding:12px 14px;
        background:var(--gray-50);
        border:1px solid var(--gray-200);
        border-radius:9px;
    }

    .reference-label {
        display:block;
        color:var(--gray-400);
        font-size:9px;
        text-transform:uppercase;
        letter-spacing:.7px;
        font-weight:800;
        margin-bottom:4px;
    }

    .reference-value {
        display:block;
        color:var(--gray-900);
        font-size:12px;
        font-weight:800;
        word-break:break-word;
    }

    .section-title {
        color:var(--gps-navy);
        font-size:13px;
        font-weight:900;
        margin:24px 0 12px;
        padding-bottom:8px;
        border-bottom:1px solid var(--gray-200);
    }

    .details-grid {
        display:grid;
        grid-template-columns:repeat(2,1fr);
        border:1px solid var(--gray-200);
        border-radius:10px;
        overflow:hidden;
    }

    .detail-item {
        padding:12px 14px;
        border-right:1px solid var(--gray-200);
        border-bottom:1px solid var(--gray-200);
    }

    .detail-item:nth-child(2n) { border-right:none; }

    .detail-item:nth-last-child(-n+2) { border-bottom:none; }

    .detail-label {
        color:var(--gray-400);
        font-size:9px;
        font-weight:800;
        text-transform:uppercase;
        letter-spacing:.5px;
        margin-bottom:5px;
    }

    .detail-value {
        color:var(--gray-900);
        font-size:12px;
        font-weight:700;
        word-break:break-word;
    }

    .payment-box {
        margin-top:22px;
        padding:16px;
        border-radius:10px;
        background:var(--success-light);
        border:1px solid #a7f3d0;
    }

    .payment-box-title {
        color:#047857;
        font-size:11px;
        font-weight:900;
        margin-bottom:10px;
    }

    .payment-grid {
        display:grid;
        grid-template-columns:repeat(4,1fr);
        gap:10px;
    }

    .payment-item {
        background:#fff;
        border:1px solid #d1fae5;
        border-radius:8px;
        padding:10px;
    }

    .payment-label {
        color:var(--gray-400);
        font-size:8px;
        font-weight:800;
        text-transform:uppercase;
        margin-bottom:4px;
    }

    .payment-value {
        color:var(--gray-900);
        font-size:10px;
        font-weight:800;
        word-break:break-word;
    }

    .certificate-footer {
        margin-top:25px;
        padding-top:18px;
        border-top:1px solid var(--gray-200);
        display:flex;
        justify-content:space-between;
        gap:20px;
        color:var(--gray-500);
        font-size:9px;
        line-height:1.6;
    }

    .actions {
        display:flex;
        justify-content:center;
        gap:10px;
        padding:0 30px 30px;
    }

    .action-button,
    .action-link {
        display:inline-flex;
        align-items:center;
        justify-content:center;
        min-width:180px;
        padding:12px 18px;
        border-radius:9px;
        text-decoration:none;
        border:1px solid var(--gray-300);
        background:#fff;
        color:var(--gps-navy);
        font-size:12px;
        font-weight:800;
        cursor:pointer;
    }

    .action-button.primary {
        border:none;
        color:#fff;
        background:linear-gradient(135deg,var(--gps-navy),var(--gps-blue));
        box-shadow:0 6px 16px rgba(15,48,115,.18);
    }

    .action-link:hover,
    .action-button:hover {
        transform:translateY(-1px);
    }

    @media(max-width:760px) {
        .header-content,
        .certificate-topbar,
        .certificate-footer {
            flex-direction:column;
            align-items:flex-start;
        }

        .reference-row,
        .details-grid {
            grid-template-columns:1fr;
        }

        .detail-item,
        .detail-item:nth-child(2n),
        .detail-item:nth-last-child(-n+2) {
            border-right:none;
            border-bottom:1px solid var(--gray-200);
        }

        .detail-item:last-child { border-bottom:none; }

        .payment-grid {
            grid-template-columns:repeat(2,1fr);
        }

        .actions {
            flex-direction:column;
        }

        .action-button,
        .action-link {
            width:100%;
        }
    }

    @media(max-width:560px) {
        .certificate-page { padding:20px 10px 40px; }
        .page-header { padding:20px; }
        .certificate-document { margin:15px; padding:24px 18px; }
        .certificate-document:before { inset:6px; }
        .payment-grid { grid-template-columns:1fr; }
    }

    @media print {
        body { background:#fff !important; }

        .certificate-page {
            padding:0 !important;
            background:#fff !important;
        }

        .page-header,
        .certificate-topbar,
        .actions,
        .message-box {
            display:none !important;
        }

        .certificate-container {
            max-width:none !important;
        }

        .certificate-shell {
            border:none !important;
            box-shadow:none !important;
        }

        .certificate-document {
            margin:0 !important;
            min-height:95vh;
            page-break-inside:avoid;
        }

        .certificate-document:before {
            display:block;
        }
    }
</style>

</asp:Content>

<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="certificate-page">
    <div class="certificate-container">

        <div class="page-header">
            <div class="header-content">
                <div class="brand-area">
                    <div class="gps-shield">GPS</div>
                    <div>
                        <h1 class="header-title">Background Check Certificate</h1>
                        <div class="header-subtitle">
                            Ghana Police Service Background Verification System
                        </div>
                    </div>
                </div>

                <div class="secure-badge">
                    🔒 Secure Citizen Certificate
                </div>
            </div>
        </div>

        <div id="pnlError"
             runat="server"
             class="message-box message-error">
            <span id="litError" runat="server"></span>
        </div>

        <div id="pnlSuccess"
             runat="server"
             class="message-box message-success">
            <span id="litSuccess" runat="server"></span>
        </div>

        <section id="pnlCertificate"
                 runat="server"
                 class="certificate-shell">

            <div class="certificate-topbar">
                <div class="topbar-title">
                    Official Background Check Certificate
                </div>

                <div class="status-pill">
                    <span id="lblCertificateStatus" runat="server">
                        Issued
                    </span>
                </div>
            </div>

            <div id="printCertificateArea"
                 class="certificate-document">

                <div class="document-inner">

                    <div class="official-heading">
                        <div class="republic">
                            Republic of Ghana
                        </div>

                        <div class="police-service">
                            Ghana Police Service
                        </div>

                        <div class="certificate-title">
                            BACKGROUND CHECK CERTIFICATE
                        </div>

                        <div class="certificate-subtitle">
                            Certificate of background verification issued through
                            the Ghana Police Service Background Verification System
                        </div>
                    </div>

                    <div class="reference-row">

                        <div class="reference-box">
                            <span class="reference-label">
                                Certificate Reference
                            </span>

                            <span id="lblCertificateReference"
                                  runat="server"
                                  class="reference-value">
                            </span>
                        </div>

                        <div class="reference-box">
                            <span class="reference-label">
                                Application Reference
                            </span>

                            <span id="lblApplicationReference"
                                  runat="server"
                                  class="reference-value">
                            </span>
                        </div>

                    </div>

                    <div class="section-title">
                        Applicant Information
                    </div>

                    <div class="details-grid">

                        <div class="detail-item">
                            <div class="detail-label">Full Name</div>
                            <div id="lblFullName"
                                 runat="server"
                                 class="detail-value">
                            </div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Gender</div>
                            <div id="lblGender"
                                 runat="server"
                                 class="detail-value">
                            </div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Date of Birth</div>
                            <div id="lblDateOfBirth"
                                 runat="server"
                                 class="detail-value">
                            </div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">National ID Type</div>
                            <div id="lblNationalId"
                                 runat="server"
                                 class="detail-value">
                            </div>
                        </div>

                    </div>

                    <div class="section-title">
                        Application Information
                    </div>

                    <div class="details-grid">

                        <div class="detail-item">
                            <div class="detail-label">Application Purpose</div>
                            <div id="lblPurpose"
                                 runat="server"
                                 class="detail-value">
                            </div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Application Status</div>
                            <div id="lblApplicationStatus"
                                 runat="server"
                                 class="detail-value">
                            </div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Date Submitted</div>
                            <div id="lblDateSubmitted"
                                 runat="server"
                                 class="detail-value">
                            </div>
                        </div>

                        <div class="detail-item">
                            <div class="detail-label">Certificate Issue Date</div>
                            <div id="lblIssueDate"
                                 runat="server"
                                 class="detail-value">
                            </div>
                        </div>

                    </div>

                    <div class="payment-box">
                        <div class="payment-box-title">
                            Payment Verification
                        </div>

                        <div class="payment-grid">

                            <div class="payment-item">
                                <div class="payment-label">Method</div>
                                <div id="lblPaymentMethod"
                                     runat="server"
                                     class="payment-value">
                                </div>
                            </div>

                            <div class="payment-item">
                                <div class="payment-label">Amount</div>
                                <div id="lblAmountPaid"
                                     runat="server"
                                     class="payment-value">
                                </div>
                            </div>

                            <div class="payment-item">
                                <div class="payment-label">Transaction</div>
                                <div id="lblTransactionId"
                                     runat="server"
                                     class="payment-value">
                                </div>
                            </div>

                            <div class="payment-item">
                                <div class="payment-label">Verification</div>
                                <div id="lblPaymentVerification"
                                     runat="server"
                                     class="payment-value">
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="certificate-footer">
                        <div>
                            This certificate was generated from the Ghana Police
                            Service Background Verification System.
                        </div>

                        <div>
                            Certificate Status:
                            <strong>Issued</strong>
                        </div>
                    </div>

                </div>
            </div>

            <div class="actions">
                <button id="btnPrint"
                        runat="server"
                        type="button"
                        class="action-button primary"
                        onclick="window.print(); return false;">
                    🖨 Print Certificate
                </button>

                <a id="lnkBackToApplication"
                   runat="server"
                   class="action-link"
                   href="SubmitApplication.aspx">
                    ← Back to Application
                </a>
            </div>

        </section>

    </div>
</div>

</asp:Content>
