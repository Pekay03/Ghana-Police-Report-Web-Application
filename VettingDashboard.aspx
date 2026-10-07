<%@ Page Title="Officer Vetting Dashboard"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="VettingDashboard.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.VettingDashboard" %>

<asp:Content ID="TitleContent"
    ContentPlaceHolderID="TitleContent"
    runat="server">

    Officer Vetting Dashboard

</asp:Content>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

<style type="text/css">

    .officer-dashboard {
        padding: 25px 0 40px;
    }

    .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
        margin-bottom: 25px;
        flex-wrap: wrap;
    }

    .dashboard-title-area h1 {
        margin: 0;
        color: #102a43;
        font-size: 30px;
        font-weight: 800;
    }

    .dashboard-title-area p {
        margin: 7px 0 0;
        color: #6b7280;
        font-size: 13px;
    }

    .officer-session {
        background: white;
        border: 1px solid #e1e8f0;
        border-radius: 10px;
        padding: 12px 17px;
        min-width: 220px;
        box-shadow: 0 4px 18px rgba(0,0,0,0.05);
    }

    .officer-session-label {
        font-size: 10px;
        color: #7b8794;
        text-transform: uppercase;
        letter-spacing: .7px;
        font-weight: 700;
    }

    .officer-session-name {
        margin-top: 3px;
        color: #102a43;
        font-size: 14px;
        font-weight: 800;
    }

    .officer-session-id {
        margin-top: 3px;
        color: #0b3b78;
        font-size: 12px;
        font-weight: 700;
    }

    .statistics {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 18px;
        margin-bottom: 25px;
    }

    .stat-card {
        background: white;
        border: 1px solid #e5ebf2;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 5px 22px rgba(0,0,0,0.05);
    }

    .stat-label {
        color: #7b8794;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: .5px;
    }

    .stat-number {
        margin-top: 8px;
        color: #102a43;
        font-size: 29px;
        font-weight: 800;
    }

    .stat-description {
        margin-top: 3px;
        color: #9aa5b1;
        font-size: 11px;
    }

    .filter-panel {
        background: white;
        border: 1px solid #e5ebf2;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 5px 22px rgba(0,0,0,0.05);
    }

    .filter-title {
        color: #102a43;
        font-size: 15px;
        font-weight: 800;
        margin-bottom: 15px;
    }

    .filter-row {
        display: grid;
        grid-template-columns: 180px 1fr 1fr auto;
        gap: 12px;
        align-items: end;
    }

    .filter-field label {
        display: block;
        color: #52606d;
        font-size: 11px;
        font-weight: 700;
        margin-bottom: 6px;
    }

    .filter-input,
    .filter-select {
        width: 100%;
        box-sizing: border-box;
        padding: 11px 12px;
        border: 1px solid #ccd6e0;
        border-radius: 7px;
        background: #f8fafc;
        font-size: 13px;
        color: #243b53;
        outline: none;
    }

    .filter-input:focus,
    .filter-select:focus {
        border-color: #0b3b78;
        background: white;
    }

    .filter-button {
        padding: 11px 20px;
        border: none;
        border-radius: 7px;
        background: #0b3b78;
        color: white;
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
    }

    .filter-button:hover {
        opacity: .92;
    }

    .clear-button {
        display: inline-block;
        padding: 10px 18px;
        border-radius: 7px;
        border: 1px solid #ccd6e0;
        color: #52606d;
        text-decoration: none;
        font-size: 13px;
        font-weight: 700;
        background: white;
        margin-left: 6px;
    }

    .applications-panel {
        background: white;
        border: 1px solid #e5ebf2;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 5px 25px rgba(0,0,0,0.05);
    }

    .applications-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 19px 20px;
        border-bottom: 1px solid #e8edf3;
        gap: 15px;
        flex-wrap: wrap;
    }

    .applications-header h2 {
        margin: 0;
        color: #102a43;
        font-size: 16px;
        font-weight: 800;
    }

    .applications-header span {
        color: #7b8794;
        font-size: 12px;
    }

    .table-wrapper {
        width: 100%;
        overflow-x: auto;
    }

    .applications-grid {
        width: 100%;
        border-collapse: collapse;
        min-width: 950px;
    }

    .applications-grid th {
        background: #f7f9fc;
        color: #52606d;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: .4px;
        font-weight: 800;
        padding: 13px 12px;
        text-align: left;
        border-bottom: 1px solid #e5ebf2;
        white-space: nowrap;
    }

    .applications-grid th a {
        color: #52606d;
        text-decoration: none;
    }

    .applications-grid td {
        padding: 14px 12px;
        color: #334e68;
        font-size: 12px;
        border-bottom: 1px solid #edf1f5;
        vertical-align: middle;
    }

    .applications-grid tr:hover td {
        background: #f9fbfd;
    }

    .view-button {
        display: inline-block;
        padding: 7px 12px;
        background: #eaf1fb;
        color: #0b3b78;
        border-radius: 6px;
        text-decoration: none;
        font-size: 11px;
        font-weight: 800;
        border: none;
        cursor: pointer;
    }

    .view-button:hover {
        background: #dce9f8;
    }

    .status-badge {
        display: inline-block;
        padding: 5px 9px;
        border-radius: 20px;
        font-size: 10px;
        font-weight: 800;
        white-space: nowrap;
    }

    .status-pending {
        background: #eaf1fb;
        color: #365f97;
    }

    .status-approved {
        background: #dce9f8;
        color: #19376d;
    }

    .status-rejected {
        background: #fff0f0;
        color: #b42318;
    }

    .status-payment {
        background: #edf4ff;
        color: #245b9c;
    }

    .status-default {
        background: #eef1f4;
        color: #52606d;
    }

    .modal-overlay {
        position: fixed;
        inset: 0;
        background: rgba(15, 23, 42, .65);
        z-index: 9999;
        display: none;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }

    .modal-overlay.show {
        display: flex;
    }

    .application-modal {
        width: 100%;
        max-width: 1000px;
        max-height: 90vh;
        overflow-y: auto;
        background: white;
        border-radius: 14px;
        box-shadow: 0 20px 70px rgba(0,0,0,.25);
    }

    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px 24px;
        background: #0b3b78;
        color: white;
        position: sticky;
        top: 0;
        z-index: 2;
    }

    .modal-header h2 {
        margin: 0;
        font-size: 18px;
        font-weight: 800;
    }

    .modal-close {
        border: none;
        background: transparent;
        color: white;
        font-size: 26px;
        cursor: pointer;
        line-height: 1;
    }

    .modal-body {
        padding: 25px;
    }

    .application-reference {
        padding: 13px 15px;
        background: #f4f7fb;
        border: 1px solid #e3eaf2;
        border-radius: 8px;
        margin-bottom: 20px;
    }

    .application-reference strong {
        color: #0b3b78;
    }

    .details-section {
        margin-bottom: 23px;
    }

    .details-section-title {
        margin: 0 0 12px;
        padding-bottom: 8px;
        border-bottom: 1px solid #e7edf4;
        color: #102a43;
        font-size: 14px;
        font-weight: 800;
    }

    .details-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 12px 20px;
    }

    .detail-item {
        padding: 9px 0;
    }

    .detail-label {
        display: block;
        color: #7b8794;
        font-size: 10px;
        text-transform: uppercase;
        font-weight: 800;
        letter-spacing: .4px;
        margin-bottom: 4px;
    }

    .detail-value {
        color: #243b53;
        font-size: 13px;
        font-weight: 600;
        word-break: break-word;
    }

    .verification-panel {
        border: 1px solid #dfe7ef;
        border-radius: 10px;
        overflow: hidden;
        background: #ffffff;
    }

    .verification-header {
        padding: 16px 18px;
        background: #f4f7fb;
        border-bottom: 1px solid #dfe7ef;
    }

    .verification-header-title {
        color: #102a43;
        font-size: 15px;
        font-weight: 800;
    }

    .verification-header-description {
        margin-top: 4px;
        color: #7b8794;
        font-size: 11px;
        line-height: 1.5;
    }

    .verification-body {
        padding: 18px;
    }

    .verification-card-number {
        display: grid;
        grid-template-columns: 1fr auto;
        gap: 12px;
        align-items: end;
        margin-bottom: 20px;
    }

    .verification-field-label {
        display: block;
        margin-bottom: 6px;
        color: #52606d;
        font-size: 10px;
        font-weight: 800;
        text-transform: uppercase;
    }

    .verification-value {
        padding: 11px 12px;
        background: #f8fafc;
        border: 1px solid #dfe7ef;
        border-radius: 7px;
        color: #243b53;
        font-size: 13px;
        font-weight: 700;
    }

    .verify-button {
        padding: 11px 18px;
        border: none;
        border-radius: 7px;
        background: #0b3b78;
        color: white;
        font-size: 12px;
        font-weight: 800;
        cursor: pointer;
    }

    .verify-button:hover {
        opacity: .92;
    }

    .verification-result {
        border: 1px solid #e1e8f0;
        border-radius: 8px;
        overflow: hidden;
    }

    .verification-row {
        display: grid;
        grid-template-columns: 1.1fr 1fr 1fr 120px;
        border-bottom: 1px solid #edf1f5;
    }

    .verification-row:last-child {
        border-bottom: none;
    }

    .verification-cell {
        padding: 11px 12px;
        color: #334e68;
        font-size: 12px;
        border-right: 1px solid #edf1f5;
    }

    .verification-cell:last-child {
        border-right: none;
    }

    .verification-heading {
        background: #f7f9fc;
        color: #52606d;
        font-size: 10px;
        font-weight: 800;
        text-transform: uppercase;
    }

    .match-badge,
    .mismatch-badge,
    .unavailable-badge {
        display: inline-block;
        padding: 5px 8px;
        border-radius: 20px;
        font-size: 9px;
        font-weight: 800;
        white-space: nowrap;
    }

    .match-badge {
        background: #dce9f8;
        color: #19376d;
    }

    .mismatch-badge {
        background: #fff0f0;
        color: #b42318;
    }

    .unavailable-badge {
        background: #eaf1fb;
        color: #365f97;
    }

    .verification-overall {
        margin-top: 15px;
        padding: 15px;
        border-radius: 8px;
        border: 1px solid #dfe7ef;
        background: #f8fafc;
        text-align: center;
    }

    .verification-overall-label {
        color: #7b8794;
        font-size: 10px;
        text-transform: uppercase;
        font-weight: 800;
        letter-spacing: .5px;
    }

    .verification-overall-value {
        margin-top: 5px;
        color: #52606d;
        font-size: 18px;
        font-weight: 900;
    }

    .verification-overall-value.verified {
        color: #19376d;
    }

    .verification-overall-value.failed {
        color: #b42318;
    }

    .verification-overall-value.unavailable {
        color: #365f97;
    }

    .verification-message {
        margin-top: 10px;
        color: #52606d;
        font-size: 11px;
        line-height: 1.6;
        text-align: center;
    }

    .verification-time {
        margin-top: 7px;
        color: #9aa5b1;
        font-size: 10px;
        text-align: center;
    }


    /* REVIEW SECTION */

    .review-panel {
        border: 1px solid #dfe7ef;
        border-radius: 10px;
        background: #ffffff;
        overflow: hidden;
    }

    .review-header {
        padding: 16px 18px;
        background: #f4f7fb;
        border-bottom: 1px solid #dfe7ef;
    }

    .review-header-title {
        color: #102a43;
        font-size: 15px;
        font-weight: 800;
    }

    .review-header-description {
        margin-top: 4px;
        color: #7b8794;
        font-size: 11px;
        line-height: 1.5;
    }

    .review-body {
        padding: 18px;
    }

    .review-field {
        margin-bottom: 16px;
    }

    .review-field:last-child {
        margin-bottom: 0;
    }

    .review-field-label {
        display: block;
        margin-bottom: 6px;
        color: #52606d;
        font-size: 10px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: .4px;
    }

    .review-input,
    .review-select,
    .review-textarea {
        width: 100%;
        box-sizing: border-box;
        padding: 11px 12px;
        border: 1px solid #ccd6e0;
        border-radius: 7px;
        background: #f8fafc;
        color: #243b53;
        font-size: 13px;
        outline: none;
    }

    .review-input:focus,
    .review-select:focus,
    .review-textarea:focus {
        border-color: #0b3b78;
        background: white;
    }

    .review-textarea {
        min-height: 95px;
        resize: vertical;
        font-family: inherit;
    }

    .review-help {
        margin-top: 5px;
        color: #9aa5b1;
        font-size: 10px;
        line-height: 1.5;
    }

    .review-actions {
        display: flex;
        justify-content: flex-end;
        align-items: center;
        gap: 10px;
        margin-top: 18px;
        padding-top: 18px;
        border-top: 1px solid #e7edf4;
        flex-wrap: wrap;
    }

    .approve-button {
        padding: 11px 20px;
        border: none;
        border-radius: 7px;
        background: #19376d;
        color: white;
        font-size: 12px;
        font-weight: 800;
        cursor: pointer;
    }

    .approve-button:hover {
        opacity: .92;
    }

    .reject-button {
        padding: 11px 20px;
        border: none;
        border-radius: 7px;
        background: #b42318;
        color: white;
        font-size: 12px;
        font-weight: 800;
        cursor: pointer;
    }

    .reject-button:hover {
        opacity: .92;
    }

    .review-warning {
        padding: 11px 13px;
        border-radius: 7px;
        background: #eaf1fb;
        border: 1px solid #b8cae2;
        color: #365f97;
        font-size: 11px;
        line-height: 1.5;
        margin-top: 14px;
    }

    .review-success {
        padding: 11px 13px;
        border-radius: 7px;
        background: #dce9f8;
        border: 1px solid #b8cae2;
        color: #19376d;
        font-size: 11px;
        line-height: 1.5;
        margin-top: 14px;
    }

    .review-danger {
        padding: 11px 13px;
        border-radius: 7px;
        background: #fff0f0;
        border: 1px solid #f0c7c7;
        color: #b42318;
        font-size: 11px;
        line-height: 1.5;
        margin-top: 14px;
    }

    .review-record {
        margin-top: 18px;
        padding: 14px;
        border-radius: 8px;
        background: #f8fafc;
        border: 1px solid #e1e8f0;
    }

    .review-record-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 12px 20px;
    }

    .review-record-item {
        padding: 5px 0;
    }

    .review-record-label {
        display: block;
        color: #7b8794;
        font-size: 9px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: .4px;
        margin-bottom: 4px;
    }

    .review-record-value {
        color: #243b53;
        font-size: 12px;
        font-weight: 700;
        word-break: break-word;
    }

    .print-button {
        padding: 10px 17px;
        border: 1px solid #ccd6e0;
        border-radius: 7px;
        background: white;
        color: #52606d;
        font-size: 12px;
        font-weight: 800;
        cursor: pointer;
    }

    .print-button:hover {
        background: #f4f7fb;
    }


    .modal-footer {
        padding: 17px 25px;
        border-top: 1px solid #e7edf4;
        background: #fafbfd;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        flex-wrap: wrap;
    }

    .modal-close-button {
        padding: 10px 18px;
        border-radius: 7px;
        border: 1px solid #ccd6e0;
        background: white;
        color: #52606d;
        font-weight: 700;
        cursor: pointer;
    }

    .empty-data {
        padding: 35px;
        text-align: center;
        color: #7b8794;
        font-size: 13px;
    }

    .system-message {
        display: block;
        margin-top: 10px;
        color: #b42318;
        font-size: 11px;
        font-weight: 700;
    }


    @media screen and (max-width: 1000px) {

        .statistics {
            grid-template-columns: repeat(2, 1fr);
        }

        .filter-row {
            grid-template-columns: 1fr 1fr;
        }

        .verification-row {
            min-width: 700px;
        }

        .verification-result {
            overflow-x: auto;
        }

    }


    @media screen and (max-width: 650px) {

        .statistics {
            grid-template-columns: 1fr;
        }

        .filter-row {
            grid-template-columns: 1fr;
        }

        .dashboard-title-area h1 {
            font-size: 24px;
        }

        .details-grid {
            grid-template-columns: 1fr;
        }

        .review-record-grid {
            grid-template-columns: 1fr;
        }

        .verification-card-number {
            grid-template-columns: 1fr;
        }

    }


    /* PRINT VERIFICATION REPORT */

    @media print {

        body * {
            visibility: hidden !important;
        }

        #applicationModal,
        #applicationModal * {
            visibility: visible !important;
        }

        #applicationModal {
            position: absolute !important;
            left: 0 !important;
            top: 0 !important;
            width: 100% !important;
            height: auto !important;
            max-height: none !important;
            display: block !important;
            background: white !important;
            padding: 0 !important;
            overflow: visible !important;
        }

        .application-modal {
            width: 100% !important;
            max-width: none !important;
            max-height: none !important;
            overflow: visible !important;
            box-shadow: none !important;
            border-radius: 0 !important;
        }

        .modal-header {
            position: static !important;
        }

        .modal-footer,
        .review-actions,
        #btnVerifyIdentity {
            display: none !important;
        }

        .modal-body {
            padding: 20px !important;
        }

        .verification-panel,
        .review-panel {
            break-inside: avoid;
            page-break-inside: avoid;
        }

    }

    .document-link-list {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
        gap: 12px;
        margin: 0 0 18px;
    }
    .document-card-link {
        display: flex;
        align-items: center;
        min-height: 76px;
        padding: 18px 20px;
        border: 1px solid #b8cae2;
        border-left: 4px solid #19376d;
        border-radius: 10px;
        background: #f1f5fb;
        color: #0b2447;
        font-size: 14px;
        font-weight: 700;
        text-decoration: none;
    }
    .document-card-link::after { content: "Open file"; margin-left: auto; padding-left: 12px; font-size: 11px; color: #365f97; }
    .document-card-link:hover, .document-card-link:focus { background: #e2ebf8; border-color: #19376d; color: #0b2447; outline: 2px solid #365f97; outline-offset: 2px; }
    .document-review-hint { color: #53657f; font-size: 13px; line-height: 1.6; margin: 0 0 16px; }
    .review-summary-title { color: #0b2447; font-size: 18px; font-weight: 700; margin: 0 0 6px; }
    .review-body .review-field select { width: 100%; min-height: 44px; border: 1px solid #b8cae2; border-radius: 8px; padding: 10px 12px; background: #fff; color: #0b2447; }
    .document-review-history { margin-top: 22px; overflow-x: auto; }
    .document-review-history table { width: 100%; border-collapse: collapse; font-size: 13px; }
    .document-review-history th { background: #0b2447; color: #fff; padding: 12px; text-align: left; }
    .document-review-history td { padding: 12px; border-bottom: 1px solid #d9e3f0; vertical-align: top; }
    @media (max-width: 600px) { .document-link-list { grid-template-columns: 1fr; } }
</style>

</asp:Content>


<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="officer-dashboard">

    <div class="dashboard-header">

        <div class="dashboard-title-area">

            <h1>Officer Vetting Dashboard</h1>

            <p>
                Command center for reviewing and processing
                citizen background check applications.
            </p>

        </div>

        <div class="officer-session">

            <div class="officer-session-label">
                Active Officer Session
            </div>

            <div class="officer-session-name">

                <asp:Label
                    ID="lblOfficerName"
                    runat="server" />

            </div>

            <div class="officer-session-id">

                Officer account ID:

                <asp:Label
                    ID="lblOfficerStaffId"
                    runat="server" />

            </div>

        </div>

    </div>


    <div class="statistics">

        <div class="stat-card">

            <div class="stat-label">
                Total Applications
            </div>

            <div class="stat-number">

                <asp:Label
                    ID="lblTotal"
                    runat="server"
                    Text="0" />

            </div>

            <div class="stat-description">
                All submitted applications
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-label">
                Pending
            </div>

            <div class="stat-number">

                <asp:Label
                    ID="lblPending"
                    runat="server"
                    Text="0" />

            </div>

            <div class="stat-description">
                Awaiting officer review
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-label">
                Approved
            </div>

            <div class="stat-number">

                <asp:Label
                    ID="lblApproved"
                    runat="server"
                    Text="0" />

            </div>

            <div class="stat-description">
                Successfully approved
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-label">
                Rejected
            </div>

            <div class="stat-number">

                <asp:Label
                    ID="lblRejected"
                    runat="server"
                    Text="0" />

            </div>

            <div class="stat-description">
                Rejected applications
            </div>

        </div>

    </div>


    <div class="filter-panel">

        <div class="filter-title">
            Application Search &amp; Filters
        </div>

        <div class="filter-row">

            <div class="filter-field">

                <label>Status</label>

                <asp:DropDownList
                    ID="ddlStatus"
                    runat="server"
                    CssClass="filter-select">

                    <asp:ListItem
                        Text="All Applications"
                        Value="All" />

                    <asp:ListItem
                        Text="Pending"
                        Value="Pending" />

                    <asp:ListItem
                        Text="Approved"
                        Value="Approved" />

                    <asp:ListItem
                        Text="Rejected"
                        Value="Rejected" />

                </asp:DropDownList>

            </div>


            <div class="filter-field">

                <label>Applicant Name</label>

                <asp:TextBox
                    ID="txtSearchName"
                    runat="server"
                    CssClass="filter-input"
                    placeholder="Search by applicant name" />

            </div>


            <div class="filter-field">

                <label>Ghana Card / ID Number</label>

                <asp:TextBox
                    ID="txtSearchCard"
                    runat="server"
                    CssClass="filter-input"
                    placeholder="Search by ID number" />

            </div>


            <div class="filter-field">

                <asp:Button
                    ID="btnSearch"
                    runat="server"
                    Text="Search"
                    CssClass="filter-button"
                    OnClick="btnSearch_Click" />

            </div>

        </div>


        <div style="margin-top:12px;">

            <asp:LinkButton
                ID="btnClear"
                runat="server"
                CssClass="clear-button"
                OnClick="btnClear_Click">

                Clear Filters

            </asp:LinkButton>

        </div>

    </div>


    <div class="applications-panel">

        <div class="applications-header">

            <h2>
                Citizen Applications
            </h2>

            <span>
                Showing applications submitted through the Citizen Portal.
            </span>

        </div>


        <div class="table-wrapper">

            <asp:GridView
                ID="gvApplications"
                runat="server"
                AutoGenerateColumns="False"
                DataKeyNames="application_id"
                CssClass="applications-grid"
                AllowSorting="True"
                OnSorting="gvApplications_Sorting"
                OnRowCommand="gvApplications_RowCommand"
                OnRowDataBound="gvApplications_RowDataBound"
                GridLines="None"
                EmptyDataText="No citizen applications are currently available.">

                <Columns>

                    <asp:BoundField
                        DataField="application_id"
                        HeaderText="Application ID"
                        SortExpression="application_id" />

                    <asp:BoundField
                        DataField="FullName"
                        HeaderText="Applicant Name"
                        SortExpression="FullName" />

                    <asp:BoundField
                        DataField="GhanaCard"
                        HeaderText="Ghana Card / ID"
                        SortExpression="GhanaCard" />

                    <asp:BoundField
                        DataField="Purpose"
                        HeaderText="Purpose"
                        SortExpression="Purpose" />

                    <asp:BoundField
                        DataField="DateSubmitted"
                        HeaderText="Submitted"
                        SortExpression="DateSubmitted"
                        DataFormatString="{0:dd MMM yyyy HH:mm}" />

                    <asp:TemplateField
                        HeaderText="Status"
                        SortExpression="Status">

                        <ItemTemplate>

                            <asp:Label
                                ID="lblStatus"
                                runat="server"
                                Text='<%# Eval("Status") %>' />

                        </ItemTemplate>

                    </asp:TemplateField>

                    <asp:TemplateField
                        HeaderText="Action">

                        <ItemTemplate>

                            <asp:LinkButton
                                ID="btnView"
                                runat="server"
                                CssClass="view-button"
                                CommandName="ViewApplication"
                                CommandArgument='<%# Eval("application_id") %>'>

                                View Application

                            </asp:LinkButton>

                        </ItemTemplate>

                    </asp:TemplateField>

                </Columns>

                <EmptyDataRowStyle
                    CssClass="empty-data" />

            </asp:GridView>

        </div>

    </div>

</div>


<div id="applicationModal"
    class="modal-overlay">

    <div class="application-modal">

        <div class="modal-header">

            <h2>
                Application Review
            </h2>

            <button
                type="button"
                class="modal-close"
                onclick="closeApplicationModal();">

                &times;

            </button>

        </div>


        <div class="modal-body">

            <div class="application-reference">

                Application Reference:

                <strong>

                    <asp:Label
                        ID="lblModalApplicationId"
                        runat="server" />

                </strong>

            </div>


            <div class="details-section">

                <h3 class="details-section-title">
                    Applicant Information
                </h3>

                <div class="details-grid">

                    <div class="detail-item">

                        <span class="detail-label">
                            Full Name
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalName"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Gender
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalGender"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Date of Birth
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalDob"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Marital Status
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalMarital"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Place of Birth
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalBirthPlace"
                                runat="server" />

                        </span>

                    </div>

                </div>

            </div>


            <div class="details-section">

                <h3 class="details-section-title">
                    Identity Information
                </h3>

                <div class="details-grid">

                    <div class="detail-item">

                        <span class="detail-label">
                            Identity Type
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalIdType"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            ID Number
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalIdNumber"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            ID Issue Date
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalIdIssueDate"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Issue Location
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalIdIssueLocation"
                                runat="server" />

                        </span>

                    </div>

                </div>

            </div>


            <div class="details-section">

                <h3 class="details-section-title">
                    Contact Information
                </h3>

                <div class="details-grid">

                    <div class="detail-item">

                        <span class="detail-label">
                            Email
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalEmail"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Phone
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalPhone"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            GPS Address
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalGps"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Profession
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalProfession"
                                runat="server" />

                        </span>

                    </div>

                </div>

            </div>


            <div class="details-section">

                <h3 class="details-section-title">
                    Next of Kin
                </h3>

                <div class="details-grid">

                    <div class="detail-item">

                        <span class="detail-label">
                            Name
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalKinName"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Phone
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalKinPhone"
                                runat="server" />

                        </span>

                    </div>

                </div>

            </div>


            <div class="details-section">

                <h3 class="details-section-title">
                    Clearance Purpose
                </h3>

                <div class="details-grid">

                    <div class="detail-item">

                        <span class="detail-label">
                            Purpose
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalPurpose"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Status
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalStatus"
                                runat="server" />

                        </span>

                    </div>

                </div>

            </div>


            <asp:Panel
                ID="pnlEmployment"
                runat="server"
                Visible="false"
                CssClass="details-section">

                <h3 class="details-section-title">
                    Employment Information
                </h3>

                <div class="details-grid">

                    <div class="detail-item">

                        <span class="detail-label">
                            Employer
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalEmployer"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Position
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalEmploymentPosition"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Employer Address
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalEmployerAddress"
                                runat="server" />

                        </span>

                    </div>

                </div>

            </asp:Panel>


            <asp:Panel
                ID="pnlEducation"
                runat="server"
                Visible="false"
                CssClass="details-section">

                <h3 class="details-section-title">
                    Education Information
                </h3>

                <div class="details-grid">

                    <div class="detail-item">

                        <span class="detail-label">
                            Institution
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalInstitution"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Programme
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalProgramme"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Student ID
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalStudentId"
                                runat="server" />

                        </span>

                    </div>

                </div>

            </asp:Panel>


            <asp:Panel
                ID="pnlTravel"
                runat="server"
                Visible="false"
                CssClass="details-section">

                <h3 class="details-section-title">
                    Travel / Visa Information
                </h3>

                <div class="details-grid">

                    <div class="detail-item">

                        <span class="detail-label">
                            Destination Country
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalDestination"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Visa Type
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalVisaType"
                                runat="server" />

                        </span>

                    </div>


                    <div class="detail-item">

                        <span class="detail-label">
                            Travel Date
                        </span>

                        <span class="detail-value">

                            <asp:Label
                                ID="lblModalTravelDate"
                                runat="server" />

                        </span>

                    </div>

                </div>

            </asp:Panel>


            <asp:Panel
                ID="pnlOther"
                runat="server"
                Visible="false"
                CssClass="details-section">

                <h3 class="details-section-title">
                    Other Purpose
                </h3>

                <div class="detail-item">

                    <span class="detail-label">
                        Description
                    </span>

                    <span class="detail-value">

                        <asp:Label
                            ID="lblModalOtherPurpose"
                            runat="server" />

                    </span>

                </div>

            </asp:Panel>


            <div class="details-section">

                <h3 class="details-section-title">
                    Identity Review
                </h3>

                <div class="verification-panel">

                    <div class="verification-header">

                        <div class="verification-header-title">
                            Ghana Card Local Record Comparison
                        </div>

                        <div class="verification-header-description">
                            This compares entered fields with records held in this
                            application database only. It is not an official Ghana
                            Card or NIA identity verification.
                        </div>

                    </div>


                    <div class="verification-body">

                        <div class="verification-card-number">

                            <div>

                                <span class="verification-field-label">
                                    Ghana Card Number
                                </span>

                                <div class="verification-value">

                                    <asp:Label
                                        ID="lblVerificationCardNumber"
                                        runat="server" />

                                </div>

                            </div>


                            <asp:Button
                                ID="btnVerifyIdentity"
                                runat="server"
                                Text="Compare with Local Record"
                                CssClass="verify-button"
                                CausesValidation="false"
                                UseSubmitBehavior="false"
                                OnClick="btnVerifyIdentity_Click" />

                        </div>


                        <asp:Panel
                            ID="pnlVerificationResult"
                            runat="server"
                            Visible="false">

                            <div class="verification-result">

                                <div class="verification-row">

                                    <div class="verification-cell verification-heading">
                                        Field
                                    </div>

                                    <div class="verification-cell verification-heading">
                                        Applicant
                                    </div>

                                    <div class="verification-cell verification-heading">
                                        Local record
                                    </div>

                                    <div class="verification-cell verification-heading">
                                        Result
                                    </div>

                                </div>


                                <div class="verification-row">

                                    <div class="verification-cell">
                                        Full Name
                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationApplicantName"
                                            runat="server" />

                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationRegistryName"
                                            runat="server" />

                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationNameResult"
                                            runat="server" />

                                    </div>

                                </div>


                                <div class="verification-row">

                                    <div class="verification-cell">
                                        Date of Birth
                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationApplicantDob"
                                            runat="server" />

                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationRegistryDob"
                                            runat="server" />

                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationDobResult"
                                            runat="server" />

                                    </div>

                                </div>


                                <div class="verification-row">

                                    <div class="verification-cell">
                                        Gender
                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationApplicantGender"
                                            runat="server" />

                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationRegistryGender"
                                            runat="server" />

                                    </div>

                                    <div class="verification-cell">

                                        <asp:Label
                                            ID="lblVerificationGenderResult"
                                            runat="server" />

                                    </div>

                                </div>

                            </div>


                            <div class="verification-overall">

                                <div class="verification-overall-label">
                                    Local Record Comparison
                                </div>

                                <div
                                    id="verificationOverallValue"
                                    runat="server"
                                    class="verification-overall-value">

                                    <asp:Label
                                        ID="lblVerificationOverall"
                                        runat="server" />

                                </div>

                                <div class="verification-message">

                                    <asp:Label
                                        ID="lblVerificationMessage"
                                        runat="server" />

                                </div>

                                <div class="verification-time">

                                    <asp:Label
                                        ID="lblVerificationTime"
                                        runat="server" />

                                </div>

                            </div>

                        </asp:Panel>


                        <asp:Label
                            ID="lblVerificationSystemMessage"
                            runat="server"
                            CssClass="system-message"
                            Visible="false" />

                    </div>

                </div>

            </div>

            <div class="details-section">
                <h3 class="details-section-title">Manual document review</h3>
                <div class="review-panel">
                    <div class="review-header">
                        <div class="review-header-title">Supporting identity documents</div>
                        <div class="review-header-description">
                            Officers review the submitted files and record a reason for each decision.
                            This manual review is not NIA IVSP authentication or an official identity verification.
                        </div>
                    </div>
                    <div class="review-body">
                        <div class="document-link-list">
                            <asp:HyperLink ID="lnkPassportPhoto" runat="server"
                                CssClass="document-card-link" Visible="false" Target="_blank" />
                            <asp:HyperLink ID="lnkGhanaCardFront" runat="server"
                                CssClass="document-card-link" Visible="false" Target="_blank" />
                            <asp:HyperLink ID="lnkGhanaCardBack" runat="server"
                                CssClass="document-card-link" Visible="false" Target="_blank" />
                            <asp:HyperLink ID="lnkIdentityDocument" runat="server"
                                CssClass="document-card-link" Visible="false" Target="_blank" />
                            <asp:HyperLink ID="lnkIdentityDocumentBack" runat="server"
                                CssClass="document-card-link" Visible="false" Target="_blank" />
                        </div>
                        <p class="document-review-hint">Open each submitted file in a separate tab, then select that document below to record its review. The passport photograph is reviewed separately from the identity document.</p>
                        <asp:Label ID="lblDocumentApprovalStatus" runat="server"
                            CssClass="system-message" />
                        <div class="review-field">
                            <label class="review-field-label" for="ddlDocumentReviewType">
                                Document to review
                            </label>
                            <asp:DropDownList ID="ddlDocumentReviewType" runat="server"
                                CssClass="form-control" />
                        </div>
                        <div class="review-field">
                            <label class="review-field-label" for="ddlDocumentReviewDecision">
                                Review decision
                            </label>
                            <asp:DropDownList ID="ddlDocumentReviewDecision" runat="server"
                                CssClass="form-control">
                                <asp:ListItem Text="Select a decision" Value="" />
                                <asp:ListItem Text="Accept — document is legible and appears consistent" Value="ACCEPTED" />
                                <asp:ListItem Text="Reject — document is not acceptable" Value="REJECTED" />
                                <asp:ListItem Text="Further review required" Value="FURTHER_REVIEW" />
                            </asp:DropDownList>
                        </div>
                        <div class="review-field">
                            <label class="review-field-label" for="txtDocumentReviewReason">
                                Reason (required)
                            </label>
                            <asp:TextBox ID="txtDocumentReviewReason" runat="server"
                                CssClass="review-textarea" TextMode="MultiLine" Rows="3"
                                MaxLength="1000"
                                placeholder="Record the specific document observations supporting this decision." />
                        </div>
                        <asp:Button ID="btnSaveDocumentReview" runat="server"
                            Text="Record document decision" CssClass="approve-button"
                            CausesValidation="false"
                            OnClick="btnSaveDocumentReview_Click" />
                        <asp:Label ID="lblDocumentReviewMessage" runat="server"
                            CssClass="system-message" />
                        <div class="table-responsive document-review-history">
                            <asp:GridView ID="gvIdentityReviewHistory" runat="server"
                                AutoGenerateColumns="False" GridLines="None"
                                CssClass="table table-striped"
                                EmptyDataText="No document review decisions have been recorded.">
                                <Columns>
                                    <asp:BoundField DataField="DocumentTypeDisplay" HeaderText="Document" />
                                    <asp:BoundField DataField="DecisionDisplay" HeaderText="Decision" />
                                    <asp:BoundField DataField="ReviewReason" HeaderText="Reason" />
                                    <asp:BoundField DataField="ReviewerName" HeaderText="Reviewed by" />
                                    <asp:BoundField DataField="ReviewedAtDisplay" HeaderText="Date and time" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>


            <!-- REVIEW AND DECISION SECTION -->

            <div class="details-section">

                <h3 class="details-section-title">
                    Officer Review &amp; Decision
                </h3>


                <div class="review-panel">

                    <div class="review-header">

                        <div class="review-header-title">
                            Vetting Decision
                        </div>

                        <div class="review-header-description">
                            Record a reasoned decision after reviewing the application and
                            required identity documents. A local-record comparison does not
                            replace official identity verification.
                        </div>

                    </div>


                    <div class="review-body">


                        <asp:Panel
                            ID="pnlApproval"
                            runat="server"
                            Visible="false">


                            <div class="review-field">

                                <label class="review-field-label">
                                    Officer Review Notes
                                </label>

                                <asp:TextBox
                                    ID="txtReviewNotes"
                                    runat="server"
                                    CssClass="review-textarea"
                                    TextMode="MultiLine"
                                    Rows="4"
                                    placeholder="Enter your review notes before making a decision..." />

                                <div class="review-help">
                                    Record any relevant observations made during the vetting process.
                                </div>

                            </div>


                            <div class="review-field">

                                <label class="review-field-label">
                                    Additional Notes
                                </label>

                                <asp:TextBox
                                    ID="txtAdditionalNotes"
                                    runat="server"
                                    CssClass="review-textarea"
                                    TextMode="MultiLine"
                                    Rows="3"
                                    placeholder="Optional additional notes..." />

                            </div>


                            <div class="review-warning">

                                Approval is enabled only after the latest manual review of
                                every required identity document is marked acceptable.
                                This is not official NIA IVSP verification.

                            </div>


                            <div class="review-actions">

                                <asp:Button
                                    ID="btnApproveApplication"
                                    runat="server"
                                    Text="Approve Application"
                                    CssClass="approve-button"
                                    OnClick="btnApproveApplication_Click"
                                    OnClientClick="return confirm('Are you sure you want to approve this application?');" />

                                <asp:Button
                                    ID="btnRejectApplication"
                                    runat="server"
                                    Text="Reject Application"
                                    CssClass="reject-button"
                                    OnClick="btnRejectApplication_Click" />

                            </div>

                        </asp:Panel>


                        <asp:Panel
                            ID="pnlRejection"
                            runat="server"
                            Visible="false">


                            <div class="review-field">

                                <label class="review-field-label">
                                    Rejection Reason
                                </label>

                                <asp:DropDownList
                                    ID="ddlRejectionReason"
                                    runat="server"
                                    CssClass="review-select">

                                    <asp:ListItem
                                        Text="Select rejection reason"
                                        Value="" />

                                    <asp:ListItem
                                        Text="Mismatch date of birth"
                                        Value="Mismatch date of birth" />

                                    <asp:ListItem
                                        Text="Incomplete documents"
                                        Value="Incomplete documents" />

                                    <asp:ListItem
                                        Text="Blurred images"
                                        Value="Blurred images" />

                                    <asp:ListItem
                                        Text="Expired ID"
                                        Value="Expired ID" />

                                    <asp:ListItem
                                        Text="Name mismatch"
                                        Value="Name mismatch" />

                                    <asp:ListItem
                                        Text="Invalid/Incorrect address"
                                        Value="Invalid/Incorrect address" />

                                    <asp:ListItem
                                        Text="Custom reason"
                                        Value="Custom reason" />

                                </asp:DropDownList>

                            </div>


                            <div class="review-field">

                                <label class="review-field-label">
                                    Custom Rejection Reason
                                </label>

                                <asp:TextBox
                                    ID="txtRejectionReason"
                                    runat="server"
                                    CssClass="review-input"
                                    placeholder="Enter custom rejection reason..." />

                                <div class="review-help">
                                    Required when "Custom reason" is selected.
                                </div>

                            </div>


                            <div class="review-field">

                                <label class="review-field-label">
                                    Review Notes
                                </label>

                                <asp:TextBox
                                    ID="txtRejectionNotes"
                                    runat="server"
                                    CssClass="review-textarea"
                                    TextMode="MultiLine"
                                    Rows="4"
                                    placeholder="Enter notes explaining the rejection decision..." />

                            </div>


                            <div class="review-danger">

                                The selected rejection reason and review information
                                will be permanently recorded with this application.

                                A rejection notification will be sent to the citizen's
                                email address provided during application submission.

                            </div>


                            <div class="review-actions">

                                <asp:Button
                                    ID="btnRejectApplicationFinal"
                                    runat="server"
                                    Text="Reject Application"
                                    CssClass="reject-button"
                                    OnClick="btnRejectApplication_Click"
                                    OnClientClick="return confirm('Are you sure you want to reject this application?');" />

                            </div>

                        </asp:Panel>


                        <div class="review-record">
                            <h4 class="review-summary-title">Latest recorded review</h4>
                            <p class="document-review-hint">Author, time and notes are loaded from the saved application decision, document review or informational local comparison.</p>

                            <div class="review-record-grid">

                                <div class="review-record-item">

                                    <span class="review-record-label">
                                        Reviewed By
                                    </span>

                                    <span class="review-record-value">

                                        <asp:Label
                                            ID="lblReviewedBy"
                                            runat="server"
                                            Text="Not reviewed yet" />

                                    </span>

                                </div>


                                <div class="review-record-item">

                                    <span class="review-record-label">
                                        Reviewed At
                                    </span>

                                    <span class="review-record-value">

                                        <asp:Label
                                            ID="lblReviewedAt"
                                            runat="server"
                                            Text="Not reviewed yet" />

                                    </span>

                                </div>


                                <div class="review-record-item">

                                    <span class="review-record-label">
                                        Review Notes
                                    </span>

                                    <span class="review-record-value">

                                        <asp:Label
                                            ID="lblModalReviewNotes"
                                            runat="server"
                                            Text="No review notes recorded." />

                                    </span>

                                </div>


                                <div class="review-record-item">

                                    <span class="review-record-label">
                                        Rejection Reason
                                    </span>

                                    <span class="review-record-value">

                                        <asp:Label
                                            ID="lblModalRejectionReason"
                                            runat="server"
                                            Text="Not applicable" />

                                    </span>

                                </div>

                            </div>

                        </div>


                    </div>

                </div>

            </div>


        </div>


        <div class="modal-footer">

            <button
                type="button"
                class="print-button"
                onclick="printVerificationReport();">

                Print Verification Report

            </button>


            <button
                type="button"
                class="modal-close-button"
                onclick="closeApplicationModal();">

                Close

            </button>

        </div>

    </div>

</div>


<script type="text/javascript">

    function openApplicationModal() {

        var modal =
            document.getElementById("applicationModal");

        if (modal) {

            modal.classList.add("show");

            document.body.style.overflow = "hidden";

        }

    }


    function closeApplicationModal() {

        var modal =
            document.getElementById("applicationModal");

        if (modal) {

            modal.classList.remove("show");

            document.body.style.overflow = "";

        }

    }


    function printVerificationReport() {

        var modal =
            document.getElementById("applicationModal");

        if (modal) {

            modal.classList.add("show");

            window.print();

        }

    }


    window.addEventListener("click", function (event) {

        var modal =
            document.getElementById("applicationModal");

        if (modal &&
            event.target === modal) {

            closeApplicationModal();

        }

    });


    document.addEventListener("keydown", function (event) {

        if (event.key === "Escape") {

            closeApplicationModal();

        }

    });


    document.addEventListener("DOMContentLoaded", function () {

        var rejectionDropdown =
            document.getElementById("<%= ddlRejectionReason.ClientID %>");

        var customReason =
            document.getElementById("<%= txtRejectionReason.ClientID %>");

        function updateCustomReasonVisibility() {

            if (!(rejectionDropdown instanceof HTMLSelectElement) ||
                !(customReason instanceof HTMLInputElement ||
                  customReason instanceof HTMLTextAreaElement)) {
                return;
            }

            if (rejectionDropdown.value === "Custom reason") {

                customReason.style.display = "block";

            }
            else {

                customReason.style.display = "none";
                customReason.value = "";

            }

        }

        if (rejectionDropdown) {

            rejectionDropdown.addEventListener(
                "change",
                updateCustomReasonVisibility
            );

        }

        updateCustomReasonVisibility();

    });

</script>

</asp:Content>
