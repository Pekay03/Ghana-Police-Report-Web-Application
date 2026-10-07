<%@ Page Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="SubmitApplication.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.SubmitApplication" %>

<asp:Content ID="TitleContent"
    ContentPlaceHolderID="TitleContent"
    runat="server">

    Submit Background Check Application

</asp:Content>


<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">

<style type="text/css">

    :root {
        --gps-navy: #0f3073;
        --gps-navy-dark: #091f4a;
        --gps-blue: #1b4f91;
        --gps-gold: #c9a84c;

        --success: #10b981;
        --success-light: #ecfdf5;

        --danger: #dc3545;
        --danger-light: #fff1f2;

        --warning: #f59e0b;
        --warning-light: #fffbeb;

        --gray-900: #172033;
        --gray-700: #334155;
        --gray-600: #475569;
        --gray-500: #64748b;
        --gray-400: #94a3b8;
        --gray-300: #cbd5e1;
        --gray-200: #e2e8f0;
        --gray-100: #f1f5f9;
        --gray-50: #f8fafc;
    }

    * {
        box-sizing: border-box;
    }

    .application-page {
        width: 100%;
        min-height: 100vh;
        padding: 40px 18px 60px;

        background:
            radial-gradient(
                circle at 10% 10%,
                rgba(201,168,76,.13),
                transparent 35%
            ),
            radial-gradient(
                circle at 90% 90%,
                rgba(27,79,145,.12),
                transparent 35%
            ),
            #f5f7fb;
    }

    .application-container {
        width: 100%;
        max-width: 1100px;
        margin: auto;
    }

    .page-header {
        background:
            linear-gradient(
                135deg,
                var(--gps-navy),
                var(--gps-navy-dark)
            );

        color: white;
        border-radius: 18px;
        padding: 26px 30px;
        margin-bottom: 22px;

        box-shadow:
            0 15px 40px rgba(15,48,115,.18);
    }

    .header-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
    }

    .brand-area {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .gps-shield {
        width: 58px;
        height: 65px;

        background:
            linear-gradient(
                135deg,
                var(--gps-gold),
                #e1c878
            );

        color: var(--gps-navy);

        display: flex;
        align-items: center;
        justify-content: center;

        font-size: 17px;
        font-weight: 900;

        clip-path: polygon(
            50% 0%,
            91% 14%,
            91% 57%,
            76% 80%,
            50% 100%,
            24% 80%,
            9% 57%,
            9% 14%
        );
    }

    .header-title {
        margin: 0;
        font-size: 24px;
        font-weight: 800;
    }

    .header-subtitle {
        margin-top: 5px;
        color: rgba(255,255,255,.78);
        font-size: 13px;
    }

    .application-status {
        background: rgba(255,255,255,.10);
        border: 1px solid rgba(255,255,255,.18);
        border-radius: 12px;
        padding: 10px 15px;
        font-size: 12px;
        white-space: nowrap;
    }

    .status-dot {
        display: inline-block;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #22c55e;
        margin-right: 7px;
    }

    .application-card {
        background: #ffffff;
        border: 1px solid var(--gray-200);
        border-radius: 18px;

        box-shadow:
            0 12px 35px rgba(15,23,42,.07);

        overflow: hidden;
    }

    .card-introduction {
        padding: 25px 30px;

        border-bottom: 1px solid var(--gray-200);

        background:
            linear-gradient(
                180deg,
                #ffffff,
                #fbfcfe
            );
    }

    .card-introduction h2 {
        margin: 0 0 7px;
        color: var(--gps-navy);
        font-size: 20px;
        font-weight: 800;
    }

    .card-introduction p {
        margin: 0;
        color: var(--gray-500);
        font-size: 13px;
        line-height: 1.6;
    }

    .progress-area {
        padding: 22px 30px;
        border-bottom: 1px solid var(--gray-200);
    }

    .progress-line {
        display: flex;
        align-items: center;
    }

    .progress-step {
        display: flex;
        align-items: center;
        flex: 1;
    }

    .progress-circle {
        width: 34px;
        height: 34px;
        min-width: 34px;

        border-radius: 50%;

        display: flex;
        align-items: center;
        justify-content: center;

        background: var(--gray-100);
        border: 2px solid var(--gray-300);

        color: var(--gray-500);

        font-size: 12px;
        font-weight: 800;
    }

    .progress-step.active .progress-circle {
        background: var(--gps-navy);
        border-color: var(--gps-navy);
        color: white;
    }

    .progress-label {
        margin-left: 8px;
        font-size: 11px;
        color: var(--gray-500);
        font-weight: 700;
    }

    .progress-step.active .progress-label {
        color: var(--gps-navy);
    }

    .progress-connector {
        flex: 1;
        height: 2px;
        background: var(--gray-200);
        margin: 0 10px;
    }

    .form-body {
        padding: 30px;
    }

    .form-section {
        margin-bottom: 30px;
    }

    .section-heading {
        display: flex;
        align-items: center;
        gap: 12px;

        padding-bottom: 12px;
        margin-bottom: 20px;

        border-bottom: 1px solid var(--gray-200);
    }

    .section-number {
        width: 31px;
        height: 31px;

        border-radius: 9px;

        background: var(--gps-navy);
        color: white;

        display: flex;
        align-items: center;
        justify-content: center;

        font-size: 12px;
        font-weight: 800;
    }

    .section-heading h3 {
        margin: 0;
        color: var(--gray-900);
        font-size: 16px;
        font-weight: 800;
    }

    .section-heading span {
        display: block;
        color: var(--gray-500);
        font-size: 11px;
        margin-top: 2px;
    }

    .form-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 17px;
    }

    .form-group {
        margin-bottom: 3px;
    }

    .form-group.full {
        grid-column: 1 / -1;
    }

    .form-label {
        display: block;
        color: var(--gray-700);
        font-size: 12px;
        font-weight: 700;
        margin-bottom: 7px;
    }

    .required {
        color: var(--danger);
    }

    .form-control {
        width: 100%;

        padding: 12px 13px;

        border: 1.5px solid var(--gray-300);
        border-radius: 9px;

        background: #fff;
        color: var(--gray-900);

        font-size: 13px;

        outline: none;

        transition: .2s ease;
    }

    .form-control:focus {
        border-color: var(--gps-navy);

        box-shadow:
            0 0 0 4px rgba(15,48,115,.08);
    }

    textarea.form-control {
        min-height: 95px;
        resize: vertical;
    }

    select.form-control {
        cursor: pointer;
    }

    .field-hint {
        margin-top: 5px;
        color: var(--gray-400);
        font-size: 10px;
    }

    .purpose-box {
        background:
            linear-gradient(
                135deg,
                #f7faff,
                #eef3fb
            );

        border: 1px solid #d8e3f3;
        border-radius: 13px;

        padding: 18px;
    }

    .purpose-label {
        display: block;
        color: var(--gps-navy);
        font-weight: 800;
        font-size: 13px;
        margin-bottom: 9px;
    }

    .purpose-select {
        width: 100%;

        padding: 13px;

        border: 1.5px solid #c5d4e8;
        border-radius: 9px;

        background: white;
        color: var(--gray-900);

        font-size: 13px;
        outline: none;

        cursor: pointer;
    }

    .purpose-select:focus {
        border-color: var(--gps-navy);

        box-shadow:
            0 0 0 4px rgba(15,48,115,.08);
    }

    .purpose-description {
        margin-top: 8px;
        color: var(--gray-500);
        font-size: 11px;
    }

    .purpose-details {
        display: none;

        margin-top: 18px;
        padding: 18px;

        background: var(--gray-50);

        border: 1px dashed var(--gray-300);
        border-radius: 12px;
    }

    .purpose-details.active {
        display: block;
        animation: fadeIn .25s ease;
    }

    .purpose-details-title {
        color: var(--gps-navy);
        font-size: 13px;
        font-weight: 800;
        margin-bottom: 14px;
    }

    .upload-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 14px;
    }

    .upload-card {
        border: 1.5px dashed var(--gray-300);
        border-radius: 12px;

        padding: 18px 14px;

        text-align: center;

        background: var(--gray-50);

        transition: .2s ease;
    }

    .upload-card:hover {
        border-color: var(--gps-navy);
        background: #f8fbff;
    }

    .upload-icon {
        font-size: 25px;
        margin-bottom: 8px;
    }

    .upload-title {
        color: var(--gray-700);
        font-size: 12px;
        font-weight: 800;
        margin-bottom: 4px;
    }

    .upload-description {
        color: var(--gray-400);
        font-size: 10px;
        margin-bottom: 12px;
        line-height: 1.4;
    }

    .file-input {
        width: 100%;
        font-size: 10px;
    }

    .file-name {
        margin-top: 7px;
        color: var(--success);
        font-size: 10px;
        word-break: break-word;
    }

    .declaration {
        background: #fffdf5;

        border: 1px solid #eadcae;
        border-radius: 12px;

        padding: 18px;
    }

    .declaration label {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        cursor: pointer;
    }

    .declaration input {
        margin-top: 3px;
        width: 16px;
        height: 16px;
    }

    .declaration-text {
        color: var(--gray-600);
        font-size: 11px;
        line-height: 1.7;
    }

    .submit-area {
        margin-top: 30px;
        padding-top: 25px;

        border-top: 1px solid var(--gray-200);

        display: flex;
        justify-content: space-between;
        align-items: center;

        gap: 20px;
    }

    .submit-note {
        color: var(--gray-500);
        font-size: 11px;
        line-height: 1.5;
    }

    .submit-note strong {
        color: var(--gps-navy);
    }

    .submit-button {
        min-width: 220px;

        padding: 14px 22px;

        border: none;
        border-radius: 10px;

        background:
            linear-gradient(
                135deg,
                var(--gps-navy),
                var(--gps-blue)
            );

        color: white;

        font-size: 13px;
        font-weight: 800;

        cursor: pointer;

        box-shadow:
            0 6px 18px rgba(15,48,115,.22);

        transition: .2s ease;
    }

    .submit-button:hover {
        transform: translateY(-2px);

        box-shadow:
            0 10px 25px rgba(15,48,115,.28);
    }

    .submit-button:disabled {
        opacity: .65;
        cursor: not-allowed;
        transform: none;
    }

    .message-box {
        display: none;

        margin-bottom: 22px;

        padding: 15px 17px;

        border-radius: 10px;

        font-size: 12px;
        line-height: 1.6;
    }

    .message-box.show {
        display: block;
    }

    .message-success {
        background: var(--success-light);
        border: 1px solid #a7f3d0;
        color: #047857;
    }

    .message-error {
        background: var(--danger-light);
        border: 1px solid #fecdd3;
        color: #b42318;
    }

    .success-panel {
        display: none;

        text-align: center;

        padding: 50px 30px;
    }

    .success-panel.show {
        display: block;
    }

    .success-circle {
        width: 75px;
        height: 75px;

        margin: 0 auto 20px;

        border-radius: 50%;

        background: var(--success-light);
        color: var(--success);

        display: flex;
        align-items: center;
        justify-content: center;

        font-size: 35px;
    }

    .success-panel h2 {
        color: var(--gps-navy);
        font-size: 24px;
        margin: 0 0 10px;
    }

    .success-panel p {
        color: var(--gray-500);
        font-size: 13px;
        line-height: 1.7;

        max-width: 600px;

        margin: 0 auto 18px;
    }

    .application-number {
        display: inline-block;

        background: var(--gray-50);

        border: 1px dashed var(--gps-blue);

        color: var(--gps-navy);

        border-radius: 10px;

        padding: 11px 20px;

        font-size: 18px;
        font-weight: 900;

        letter-spacing: 1px;

        margin-bottom: 20px;
    }

    .pending-badge {
        display: inline-block;

        padding: 7px 13px;

        background: var(--warning-light);
        color: #a16207;

        border: 1px solid #fde68a;
        border-radius: 999px;

        font-size: 11px;
        font-weight: 800;
    }

    .success-actions {
        margin-top: 25px;

        display: flex;
        justify-content: center;

        gap: 10px;
    }

    .secondary-button {
        padding: 11px 18px;

        border-radius: 9px;

        background: white;
        color: var(--gps-navy);

        border: 1px solid var(--gray-300);

        text-decoration: none;

        font-size: 12px;
        font-weight: 700;

        cursor: pointer;
    }

    .secondary-button:hover {
        background: var(--gray-50);
    }

    @keyframes fadeIn {

        from {
            opacity: 0;
            transform: translateY(-5px);
        }

        to {
            opacity: 1;
            transform: translateY(0);
        }

    }

    @media(max-width:800px) {

        .form-grid {
            grid-template-columns: 1fr;
        }

        .form-group.full {
            grid-column: auto;
        }

        .upload-grid {
            grid-template-columns: 1fr;
        }

        .header-content {
            align-items: flex-start;
            flex-direction: column;
        }

        .progress-label {
            display: none;
        }

        .submit-area {
            flex-direction: column;
            align-items: stretch;
        }

        .submit-button {
            width: 100%;
        }

    }

    @media(max-width:560px) {

        .application-page {
            padding: 20px 10px 40px;
        }

        .page-header {
            padding: 20px;
        }

        .form-body,
        .card-introduction,
        .progress-area {
            padding: 20px;
        }

        .header-title {
            font-size: 20px;
        }

    }


    /* Citizen payment and certificate services */
    .citizen-services { margin-top:22px; }
    .services-header { padding:25px 30px 18px; border-bottom:1px solid var(--gray-200); background:linear-gradient(180deg,#fff,#fbfcfe); }
    .services-header h2 { margin:0 0 7px; color:var(--gps-navy); font-size:20px; font-weight:800; }
    .services-header p { margin:0; color:var(--gray-500); font-size:13px; line-height:1.6; }
    .service-reference { margin-top:13px; display:inline-flex; gap:7px; padding:7px 11px; border-radius:999px; background:var(--gray-50); border:1px solid var(--gray-200); color:var(--gray-600); font-size:11px; font-weight:700; }
    .service-status { margin:20px 30px 0; padding:13px 15px; border-radius:10px; background:var(--gray-50); border:1px solid var(--gray-200); color:var(--gray-600); font-size:12px; line-height:1.6; }
    .service-grid { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:18px; padding:24px 30px 30px; }
    .service-card { position:relative; min-height:300px; padding:25px; border:1px solid var(--gray-200); border-radius:16px; background:#fff; box-shadow:0 8px 24px rgba(15,23,42,.06); transition:.2s ease; }
    .service-card:hover { transform:translateY(-2px); box-shadow:0 12px 30px rgba(15,23,42,.09); }
    .service-card.locked { background:linear-gradient(180deg,#fff,#f8fafc); }
    .service-card.unlocked { border-color:#c7d7ef; background:linear-gradient(180deg,#fff,#f5f9ff); }
    .service-card.paid { border-color:#a7f3d0; background:linear-gradient(180deg,#fff,#f0fdf7); }
    .service-icon { width:52px; height:52px; border-radius:14px; display:flex; align-items:center; justify-content:center; margin-bottom:17px; background:#eef3fb; color:var(--gps-navy); font-size:25px; }
    .service-card.locked .service-icon { background:var(--gray-100); color:var(--gray-500); }
    .service-card.paid .service-icon { background:var(--success-light); color:var(--success); }
    .service-card h3 { margin:0 0 8px; color:var(--gray-900); font-size:18px; font-weight:800; }
    .service-price { margin:0 0 12px; color:var(--gps-navy); font-size:25px; font-weight:900; }
    .service-description { margin:0 0 16px; color:var(--gray-500); font-size:12px; line-height:1.7; }
    .service-badge { display:inline-flex; margin-bottom:17px; padding:7px 10px; border-radius:999px; background:var(--warning-light); border:1px solid #fde68a; color:#a16207; font-size:10px; font-weight:800; }
    .service-action-area { margin-top:auto; padding-top:8px; }
    .payment-method-label { display:block; margin-bottom:7px; color:var(--gray-700); font-size:11px; font-weight:800; }
    .service-select { width:100%; padding:11px 12px; margin-bottom:11px; border:1.5px solid var(--gray-300); border-radius:9px; background:#fff; color:var(--gray-900); font-size:12px; outline:none; }
    .service-button { width:100%; padding:12px 16px; border:none; border-radius:9px; background:linear-gradient(135deg,var(--gps-navy),var(--gps-blue)); color:#fff; font-size:12px; font-weight:800; cursor:pointer; box-shadow:0 6px 16px rgba(15,48,115,.18); }
    .service-button:hover { transform:translateY(-1px); }
    .service-button:disabled { opacity:.55; cursor:not-allowed; transform:none; box-shadow:none; }
    .service-status-text { min-height:18px; margin-top:11px; color:var(--gray-600); font-size:11px; line-height:1.5; }
    .service-details { margin-top:13px; padding:12px; border-radius:9px; background:var(--gray-50); border:1px solid var(--gray-200); color:var(--gray-600); font-size:10px; line-height:1.6; word-break:break-word; }
    .demo-notice { margin-top:13px; padding:10px 11px; border-radius:8px; background:#fffdf5; border:1px solid #eadcae; color:#80651a; font-size:10px; line-height:1.5; }
    .certificate-link { display:inline-flex; align-items:center; justify-content:center; width:100%; min-height:42px; padding:11px 16px; border-radius:9px; background:linear-gradient(135deg,var(--gps-navy),var(--gps-blue)); color:#fff !important; text-decoration:none; font-size:12px; font-weight:800; }
    .certificate-link[aria-disabled="true"] { opacity:.55; pointer-events:none; }
    .service-note { padding:0 30px 25px; color:var(--gray-400); font-size:10px; line-height:1.6; }
    @media(max-width:800px) { .service-grid { grid-template-columns:1fr; } }
    @media(max-width:560px) { .services-header,.service-grid { padding-left:20px; padding-right:20px; } .service-status { margin-left:20px; margin-right:20px; } .service-note { padding-left:20px; padding-right:20px; } .service-card { padding:20px; } }

</style>

</asp:Content>


<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

<div class="application-page">

    <div class="application-container">

        <div class="page-header">

            <div class="header-content">

                <div class="brand-area">

                    <div class="gps-shield">
                        GPS
                    </div>

                    <div>

                        <h1 class="header-title">
                            Background Check Application
                        </h1>

                        <div class="header-subtitle">
                            Ghana Police Service Background Verification System
                        </div>

                    </div>

                </div>

                <div class="application-status">

                    <span class="status-dot"></span>

                    Secure Application Portal

                </div>

            </div>

        </div>


        <div class="application-card">

            <div class="card-introduction">

                <h2>
                    Submit Background Check Application
                </h2>

                <p>
                    Complete the form below with accurate information.
                    Your application will be reviewed by the appropriate
                    Ghana Police Service personnel.
                </p>

            </div>


            <div class="progress-area">

                <div class="progress-line">

                    <div class="progress-step active">

                        <div class="progress-circle">
                            1
                        </div>

                        <div class="progress-label">
                            Personal Details
                        </div>

                    </div>

                    <div class="progress-connector"></div>

                    <div class="progress-step active">

                        <div class="progress-circle">
                            2
                        </div>

                        <div class="progress-label">
                            Application Details
                        </div>

                    </div>

                    <div class="progress-connector"></div>

                    <div class="progress-step active">

                        <div class="progress-circle">
                            3
                        </div>

                        <div class="progress-label">
                            Documents
                        </div>

                    </div>

                    <div class="progress-connector"></div>

                    <div class="progress-step active">

                        <div class="progress-circle">
                            4
                        </div>

                        <div class="progress-label">
                            Submit
                        </div>

                    </div>

                </div>

            </div>


            <div id="applicationFormContainer"
                 runat="server">

                <div class="form-body">

                    <div id="errorMessage"
                         runat="server"
                         class="message-box message-error">
                    </div>


                    <!-- SECTION 1 -->

                    <div class="form-section">

                        <div class="section-heading">

                            <div class="section-number">
                                1
                            </div>

                            <div>

                                <h3>
                                    Personal Information
                                </h3>

                                <span>
                                    Provide the applicant's personal details.
                                </span>

                            </div>

                        </div>


                        <div class="form-grid">

                            <div class="form-group full">

                                <label class="form-label"
                                       for="fullName">

                                    Full Name
                                    <span class="required">*</span>

                                </label>

                                <input type="text"
                                       id="fullName"
                                       name="fullName"
                                       class="form-control"
                                       maxlength="255"
                                       placeholder="Enter your full name"
                                       autocomplete="on"
                                       required="required" />

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="gender">

                                    Gender
                                    <span class="required">*</span>

                                </label>

                                <select id="gender"
                                        name="gender"
                                        class="form-control"
                                        required="required">

                                    <option value="">
                                        Select gender
                                    </option>

                                    <option value="Male">
                                        Male
                                    </option>

                                    <option value="Female">
                                        Female
                                    </option>

                                </select>

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="dateOfBirth">

                                    Date of Birth
                                    <span class="required">*</span>

                                </label>

                                <input type="date"
                                       id="dateOfBirth"
                                       name="dateOfBirth"
                                       class="form-control"
                                       required="required" />

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="maritalStatus">

                                    Marital Status
                                    <span class="required">*</span>

                                </label>

                                <select id="maritalStatus"
                                        name="maritalStatus"
                                        class="form-control"
                                        required="required">

                                    <option value="">
                                        Select marital status
                                    </option>

                                    <option value="Single">
                                        Single
                                    </option>

                                    <option value="Married">
                                        Married
                                    </option>

                                    <option value="Divorced">
                                        Divorced
                                    </option>

                                    <option value="Widowed">
                                        Widowed
                                    </option>

                                </select>

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="placeOfBirth">

                                    Place of Birth
                                    <span class="required">*</span>

                                </label>

                                <input type="text"
                                       id="placeOfBirth"
                                       name="placeOfBirth"
                                       class="form-control"
                                       maxlength="255"
                                       placeholder="Town / city of birth"
                                       required="required" />

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="gpsAddress">

                                    GhanaPost GPS Address
                                    <span class="required">*</span>

                                </label>

                                <input type="text"
                                       id="gpsAddress"
                                       name="gpsAddress"
                                       class="form-control"
                                       maxlength="100"
                                       placeholder="Example: AK-123-4567"
                                       required="required" />

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="email">

                                    Email Address
                                    <span class="required">*</span>

                                </label>

                                <input type="email"
                                       id="email"
                                       name="email"
                                       runat="server"
                                       readonly="readonly"
                                       class="form-control"
                                       maxlength="255"
                                       placeholder="example@email.com"
                                       autocomplete="on"
                                       required="required" />

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="phone">

                                    Mobile Number
                                    <span class="required">*</span>

                                </label>

                                <input type="tel"
                                       id="phone"
                                       name="phone"
                                       class="form-control"
                                       maxlength="15"
                                       placeholder="0241234567"
                                       autocomplete="on"
                                       required="required" />

                                <div class="field-hint">
                                    Enter a valid Ghana mobile number.
                                </div>

                            </div>


                            <div class="form-group full">

                                <label class="form-label"
                                       for="profession">

                                    Profession / Occupation
                                    <span class="required">*</span>

                                </label>

                                <input type="text"
                                       id="profession"
                                       name="profession"
                                       class="form-control"
                                       maxlength="255"
                                       placeholder="Enter your profession or occupation"
                                       required="required" />

                            </div>

                        </div>

                    </div>


                    <!-- SECTION 2 -->

                    <div class="form-section">

                        <div class="section-heading">

                            <div class="section-number">
                                2
                            </div>

                            <div>

                                <h3>
                                    Next of Kin
                                </h3>

                                <span>
                                    Provide contact details for your next of kin.
                                </span>

                            </div>

                        </div>


                        <div class="form-grid">

                            <div class="form-group">

                                <label class="form-label"
                                       for="nextOfKinName">

                                    Next of Kin Name
                                    <span class="required">*</span>

                                </label>

                                <input type="text"
                                       id="nextOfKinName"
                                       name="nextOfKinName"
                                       class="form-control"
                                       maxlength="255"
                                       placeholder="Full name"
                                       required="required" />

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="nextOfKinPhone">

                                    Next of Kin Phone
                                    <span class="required">*</span>

                                </label>

                                <input type="tel"
                                       id="nextOfKinPhone"
                                       name="nextOfKinPhone"
                                       class="form-control"
                                       maxlength="15"
                                       placeholder="0241234567"
                                       required="required" />

                            </div>

                        </div>

                    </div>


                    <!-- SECTION 3 -->

                    <div class="form-section">

                        <div class="section-heading">

                            <div class="section-number">
                                3
                            </div>

                            <div>

                                <h3>
                                    National Identification
                                </h3>

                                <span>
                                    Provide your identification information.
                                </span>

                            </div>

                        </div>


                        <div class="form-grid">

                            <div class="form-group">

                                <label class="form-label"
                                       for="nationalIdType">

                                    National ID Type
                                    <span class="required">*</span>

                                </label>

                                <select id="nationalIdType"
                                        name="nationalIdType"
                                        class="form-control"
                                        required="required">

                                    <option value="">
                                        Select ID type
                                    </option>

                                    <option value="Ghana Card">
                                        Ghana Card
                                    </option>

                                    <option value="Passport">
                                        Passport
                                    </option>

                                    <option value="Voter ID">
                                        Voter ID
                                    </option>

                                    <option value="Driver's Licence">
                                        Driver's Licence
                                    </option>

                                </select>

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="nationalIdNumber">

                                    National ID / Passport Number
                                    <span class="required">*</span>

                                </label>

                                <input type="text"
                                       id="nationalIdNumber"
                                       name="nationalIdNumber"
                                       class="form-control"
                                       maxlength="100"
                                       placeholder="Enter ID number"
                                       required="required" />

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="idIssueDate">

                                    ID Issue Date

                                </label>

                                <input type="date"
                                       id="idIssueDate"
                                       name="idIssueDate"
                                       class="form-control" />

                            </div>


                            <div class="form-group">

                                <label class="form-label"
                                       for="idIssueLocation">

                                    ID Issue Location

                                </label>

                                <input type="text"
                                       id="idIssueLocation"
                                       name="idIssueLocation"
                                       class="form-control"
                                       maxlength="255"
                                       placeholder="Place where the ID was issued" />

                            </div>

                        </div>

                    </div>


                    <!-- SECTION 4 -->

                    <div class="form-section">

                        <div class="section-heading">

                            <div class="section-number">
                                4
                            </div>

                            <div>

                                <h3>
                                    Application Purpose
                                </h3>

                                <span>
                                    Select the reason for requesting the background check.
                                </span>

                            </div>

                        </div>


                        <div class="purpose-box">

                            <label class="purpose-label"
                                   for="applicationPurpose">

                                Clearance Purpose
                                <span class="required">*</span>

                            </label>


                            <select id="applicationPurpose"
                                    name="applicationPurpose"
                                    class="purpose-select"
                                    required="required">

                                <option value="">
                                    Select application purpose
                                </option>

                                <option value="Employment">
                                    Employment
                                </option>

                                <option value="Education Background">
                                    Education Background
                                </option>

                                <option value="Travel/Visa">
                                    Travel / Visa
                                </option>

                                <option value="Other">
                                    Other
                                </option>

                            </select>


                            <div class="purpose-description"
                                 id="purposeDescription">

                                Select one purpose to display the relevant additional information.

                            </div>


                            <!-- EMPLOYMENT -->

                            <div id="employmentDetails"
                                 class="purpose-details">

                                <div class="purpose-details-title">
                                    Employment Information
                                </div>


                                <div class="form-grid">

                                    <div class="form-group">

                                        <label class="form-label"
                                               for="employerName">

                                            Employer / Organisation
                                            <span class="required">*</span>

                                        </label>

                                        <input type="text"
                                               id="employerName"
                                               name="employerName"
                                               class="form-control"
                                               maxlength="255"
                                               placeholder="Company or organisation name" />

                                    </div>


                                    <div class="form-group">

                                        <label class="form-label"
                                               for="employmentPosition">

                                            Employment Position
                                            <span class="required">*</span>

                                        </label>

                                        <input type="text"
                                               id="employmentPosition"
                                               name="employmentPosition"
                                               class="form-control"
                                               maxlength="255"
                                               placeholder="Job title / position" />

                                    </div>


                                    <div class="form-group full">

                                        <label class="form-label"
                                               for="employerAddress">

                                            Employer Address

                                        </label>

                                        <textarea id="employerAddress"
                                                  name="employerAddress"
                                                  class="form-control"
                                                  maxlength="500"
                                                  placeholder="Employer's address"></textarea>

                                    </div>

                                </div>

                            </div>


                            <!-- EDUCATION -->

                            <div id="educationDetails"
                                 class="purpose-details">

                                <div class="purpose-details-title">
                                    Education Information
                                </div>


                                <div class="form-grid">

                                    <div class="form-group">

                                        <label class="form-label"
                                               for="institutionName">

                                            Educational Institution
                                            <span class="required">*</span>

                                        </label>

                                        <input type="text"
                                               id="institutionName"
                                               name="institutionName"
                                               class="form-control"
                                               maxlength="255"
                                               placeholder="Institution name" />

                                    </div>


                                    <div class="form-group">

                                        <label class="form-label"
                                               for="programmeName">

                                            Programme
                                            <span class="required">*</span>

                                        </label>

                                        <input type="text"
                                               id="programmeName"
                                               name="programmeName"
                                               class="form-control"
                                               maxlength="255"
                                               placeholder="Programme of study" />

                                    </div>


                                    <div class="form-group full">

                                        <label class="form-label"
                                               for="studentId">

                                            Student ID

                                        </label>

                                        <input type="text"
                                               id="studentId"
                                               name="studentId"
                                               class="form-control"
                                               maxlength="100"
                                               placeholder="Student identification number" />

                                    </div>

                                </div>

                            </div>


                            <!-- TRAVEL -->

                            <div id="travelDetails"
                                 class="purpose-details">

                                <div class="purpose-details-title">
                                    Travel / Visa Information
                                </div>


                                <div class="form-grid">

                                    <div class="form-group">

                                        <label class="form-label"
                                               for="destinationCountry">

                                            Destination Country
                                            <span class="required">*</span>

                                        </label>

                                        <input type="text"
                                               id="destinationCountry"
                                               name="destinationCountry"
                                               class="form-control"
                                               maxlength="255"
                                               placeholder="Country you intend to travel to" />

                                    </div>


                                    <div class="form-group">

                                        <label class="form-label"
                                               for="visaType">

                                            Visa Type

                                        </label>

                                        <select id="visaType"
                                                name="visaType"
                                                class="form-control">

                                            <option value="">
                                                Select visa type
                                            </option>

                                            <option value="Tourist">
                                                Tourist
                                            </option>

                                            <option value="Student">
                                                Student
                                            </option>

                                            <option value="Work">
                                                Work
                                            </option>

                                            <option value="Business">
                                                Business
                                            </option>

                                            <option value="Immigrant">
                                                Immigrant
                                            </option>

                                            <option value="Other">
                                                Other
                                            </option>

                                        </select>

                                    </div>


                                    <div class="form-group full">

                                        <label class="form-label"
                                               for="travelDate">

                                            Intended Travel Date

                                        </label>

                                        <input type="date"
                                               id="travelDate"
                                               name="travelDate"
                                               class="form-control" />

                                    </div>

                                </div>

                            </div>


                            <!-- OTHER -->

                            <div id="otherDetails"
                                 class="purpose-details">

                                <div class="purpose-details-title">
                                    Other Application Purpose
                                </div>


                                <div class="form-grid">

                                    <div class="form-group full">

                                        <label class="form-label"
                                               for="otherPurpose">

                                            Explain Purpose
                                            <span class="required">*</span>

                                        </label>

                                        <textarea id="otherPurpose"
                                                  name="otherPurpose"
                                                  class="form-control"
                                                  maxlength="2000"
                                                  placeholder="Please explain why you require the background check"></textarea>

                                    </div>

                                </div>

                            </div>

                        </div>

                    </div>


                    <!-- SECTION 5 -->

                    <div class="form-section">

                        <div class="section-heading">

                            <div class="section-number">
                                5
                            </div>

                            <div>

                                <h3>
                                    Supporting Documents
                                </h3>

                                <span>
                                    Upload the required identification documents.
                                </span>

                            </div>

                        </div>


                        <div class="upload-grid">

                            <div class="upload-card" id="passportPhotoCard">

                                <div class="upload-icon">
                                    📷
                                </div>

                                <div class="upload-title">
                                    Passport Photograph
                                </div>

                                <div class="upload-description">
                                    JPG, JPEG or PNG. Maximum 5 MB.
                                </div>

                                <input type="file"
                                       id="passportPhoto"
                                       name="passportPhoto"
                                       class="file-input"
                                       accept=".jpg,.jpeg,.png,image/jpeg,image/png"
                                       required="required" />

                                <div id="passportPhotoName"
                                     class="file-name">
                                </div>

                            </div>


                            <div class="upload-card" id="ghanaCardFrontCard">

                                <div class="upload-icon">
                                    🪪
                                </div>

                                <div class="upload-title">
                                    Ghana Card Front
                                </div>

                                <div class="upload-description">
                                    Required when Ghana Card is selected. Maximum 5 MB.
                                </div>

                                <input type="file"
                                       id="ghanaCardFront"
                                       name="ghanaCardFront"
                                       class="file-input"
                                       accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf" />

                                <div id="ghanaCardFrontName"
                                     class="file-name">
                                </div>

                            </div>


                            <div class="upload-card" id="ghanaCardBackCard">

                                <div class="upload-icon">
                                    🪪
                                </div>

                                <div class="upload-title">
                                    Ghana Card Back
                                </div>

                                <div class="upload-description">
                                    Required when Ghana Card is selected. Maximum 5 MB.
                                </div>

                                <input type="file"
                                       id="ghanaCardBack"
                                       name="ghanaCardBack"
                                       class="file-input"
                                       accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf" />

                                <div id="ghanaCardBackName"
                                     class="file-name">
                                </div>

                            </div>

                            <div class="upload-card" id="identityDocumentCard">
                                <div class="upload-icon">🛂</div>
                                <div class="upload-title" id="identityDocumentTitle">Identity document</div>
                                <div class="upload-description" id="identityDocumentDescription">
                                    Required for the selected non-Ghana Card ID type. JPG, JPEG, PNG or PDF. Maximum 5 MB.
                                </div>
                                <input type="file"
                                       id="identityDocument"
                                       name="identityDocument"
                                       class="file-input"
                                       accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf" />
                                <div id="identityDocumentName" class="file-name"></div>
                            </div>
                            <div class="upload-card" id="identityDocumentBackCard" style="display:none">
                                <div class="upload-title" id="identityDocumentBackTitle">Identity document — back</div>
                                <div class="upload-description">Upload a clear back view. JPG, JPEG, PNG or PDF. Maximum 5 MB.</div>
                                <input type="file" id="identityDocumentBack" name="identityDocumentBack"
                                       class="file-input" accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf" />
                                <div id="identityDocumentBackName" class="file-name"></div>
                            </div>

                        </div>

                    </div>


                    <!-- SECTION 6 -->

                    <div class="form-section">

                        <div class="section-heading">

                            <div class="section-number">
                                6
                            </div>

                            <div>

                                <h3>
                                    Declaration
                                </h3>

                                <span>
                                    Confirm that the information supplied is accurate.
                                </span>

                            </div>

                        </div>


                        <div class="declaration">

                            <label for="declarationAccepted">

                                <input type="checkbox"
                                       id="declarationAccepted"
                                       name="declarationAccepted"
                                       value="1"
                                       required="required" />

                                <span class="declaration-text">

                                    I declare that the information provided in this application
                                    is true, complete and accurate to the best of my knowledge.
                                    I understand that providing false information may result in
                                    rejection of the application or other action in accordance
                                    with applicable Ghana Police Service procedures.

                                </span>

                            </label>

                        </div>

                    </div>


                    <!-- SUBMIT -->

                    <div class="submit-area">

                        <div class="submit-note">

                            <strong>Before submitting:</strong>

                            Please review all information and make sure
                            your uploaded documents are correct.

                            <br />

                            Your application will be submitted as
                            <strong>Pending Approval</strong>.

                        </div>


                        <button type="submit"
                                id="btnSubmitApplication"
                                runat="server"
                                onserverclick="btnSubmitApplication_ServerClick"
                                class="submit-button">

                            Submit Background Check Application

                        </button>

                    </div>

                </div>

            </div>


            <!-- SUCCESS PANEL -->

            <div id="successPanel"
                 runat="server"
                 class="success-panel">

                <div class="success-circle">
                    ✓
                </div>


                <h2>
                    Application Submitted Successfully
                </h2>


                <p>
                    Your Ghana Police Service background check application
                    has been submitted successfully and is now waiting for
                    review and approval.
                </p>


                <div id="generatedApplicationId"
                     runat="server"
                     class="application-number">
                </div>


                <br />


                <span class="pending-badge">
                    Pending Approval
                </span>


                <div class="success-actions">

                    <a href="SubmitApplication.aspx"
                       class="secondary-button">

                        Submit Another Application

                    </a>

                    <a href="Default.aspx"
                       class="secondary-button">

                        Return Home

                    </a>

                </div>

            </div>

        </div>

    </div>

</div>



<section id="pnlCitizenServices"
         runat="server"
         class="application-card citizen-services">

    <div class="services-header">
        <h2>Application Services</h2>
        <p>Complete the next service step when your background check application has been approved.</p>
        <span class="service-reference">
            Application:
            <span id="lblServiceApplicationId" runat="server"></span>
        </span>
    </div>

    <div id="lblApplicationServiceStatus"
         runat="server"
         class="service-status">
    </div>

    <div class="service-grid">

        <section id="pnlPaymentService"
                 runat="server"
                 class="service-card locked">

            <div class="service-icon">💳</div>
            <h3>Payment</h3>
            <div class="service-price">GHS <span id="lblPaymentFee" runat="server">150.00</span></div>

            <p class="service-description">
                Pay the background check service fee using MTN MoMo,
                Telecel Cash or AT Money.
            </p>

            <div class="service-badge">
                🔒 Available after application approval
            </div>

            <div class="service-action-area">

                <label class="payment-method-label"
                       for="ddlPaymentMethod">
                    Payment Method
                </label>

                <select id="ddlPaymentMethod"
                        runat="server"
                        class="service-select">
                    <option value="MTN MoMo">MTN MoMo</option>
                    <option value="Telecel Cash">Telecel Cash</option>
                    <option value="AT Money">AT Money</option>
                </select>

                <button type="submit"
                        formnovalidate="formnovalidate"
                        id="btnPayNow"
                        runat="server"
                        onserverclick="btnPayNow_Click"
                        class="service-button">
                    Proceed to Payment
                </button>

                <div id="lblPaymentStatus"
                     runat="server"
                     class="service-status-text">
                </div>

                <div id="lblPaymentDetails"
                     runat="server"
                     class="service-details">
                </div>

                <div class="demo-notice">
                    <strong>Hubtel mobile-money payment:</strong>
                    An authorised request sends a real payment prompt to your registered wallet.
                    Confirm the amount and any provider fees in your wallet prompt; never enter your PIN here.
                    Certificates unlock only after Hubtel confirms payment.
                </div>

            </div>
        </section>


        <section id="pnlCertificateService"
                 runat="server"
                 class="service-card locked">

            <div class="service-icon">📄</div>
            <h3>Certificate</h3>

            <div class="service-price">
                Background Check Certificate
            </div>

            <p class="service-description">
                View and generate your background check certificate
                after approval and payment verification.
            </p>

            <div class="service-badge">
                🔒 Locked until payment is verified
            </div>

            <div class="service-action-area">

                <button type="submit"
                        formnovalidate="formnovalidate"
                        id="btnCertificate"
                        runat="server"
                        onserverclick="btnCertificate_Click"
                        class="service-button">
                    View / Generate Certificate
                </button>

                <div id="lblCertificateStatus"
                     runat="server"
                     class="service-status-text">
                </div>

                <a id="lblCertificateLink"
                   runat="server"
                   class="certificate-link"
                   href="#"
                   aria-disabled="true">
                    View / Generate Certificate
                </a>

            </div>
        </section>

    </div>

    <div class="service-note">
        Service access follows the workflow:
        <strong>Pending → Approved → Payment Verified → Certificate Available.</strong>
    </div>

</section>


<script type="text/javascript">

    (function () {

        "use strict";


        function getElement(id = "") {

            return document.getElementById(id);

        }


        function getFormField(id = "") {
            var element = getElement(id);
            return element instanceof HTMLInputElement ||
                element instanceof HTMLSelectElement ||
                element instanceof HTMLTextAreaElement
                ? element
                : null;
        }

        function getInput(id = "") {
            var element = getElement(id);
            return element instanceof HTMLInputElement ? element : null;
        }

        function getValue(id = "") {

            var element = getFormField(id);

            if (!element) {
                return "";
            }

            return element.value.trim();

        }


        /* =====================================================
           PURPOSE
        ====================================================== */

        function updatePurposeDetails() {

            var purposeElement =
                getFormField("applicationPurpose");

            if (!purposeElement) {
                return;
            }

            var purpose =
                purposeElement.value;


            var employment =
                getElement("employmentDetails");

            var education =
                getElement("educationDetails");

            var travel =
                getElement("travelDetails");

            var other =
                getElement("otherDetails");

            var description =
                getElement("purposeDescription");


            if (employment) {
                employment.classList.remove("active");
            }

            if (education) {
                education.classList.remove("active");
            }

            if (travel) {
                travel.classList.remove("active");
            }

            if (other) {
                other.classList.remove("active");
            }


            if (purpose === "Employment") {

                if (employment) {
                    employment.classList.add("active");
                }

                if (description) {
                    description.textContent =
                        "Provide information about the employment for which the clearance is required.";
                }

            }

            else if (purpose === "Education Background") {

                if (education) {
                    education.classList.add("active");
                }

                if (description) {
                    description.textContent =
                        "Provide information about the educational institution or programme.";
                }

            }

            else if (purpose === "Travel/Visa") {

                if (travel) {
                    travel.classList.add("active");
                }

                if (description) {
                    description.textContent =
                        "Provide information about your intended international travel or visa application.";
                }

            }

            else if (purpose === "Other") {

                if (other) {
                    other.classList.add("active");
                }

                if (description) {
                    description.textContent =
                        "Explain the reason for requesting the background check.";
                }

            }

            else {

                if (description) {
                    description.textContent =
                        "Select one purpose to display the relevant additional information.";
                }

            }


            updateConditionalRequiredFields();

        }


        /* =====================================================
           CONDITIONAL REQUIRED FIELDS
        ====================================================== */

        function updateConditionalRequiredFields() {

            var purpose =
                getValue("applicationPurpose");


            var employerName =
                getFormField("employerName");

            var employmentPosition =
                getFormField("employmentPosition");

            var institutionName =
                getFormField("institutionName");

            var programmeName =
                getFormField("programmeName");

            var destinationCountry =
                getFormField("destinationCountry");

            var otherPurpose =
                getFormField("otherPurpose");


            if (employerName) {

                employerName.required =
                    purpose === "Employment";

            }


            if (employmentPosition) {

                employmentPosition.required =
                    purpose === "Employment";

            }


            if (institutionName) {

                institutionName.required =
                    purpose === "Education Background";

            }


            if (programmeName) {

                programmeName.required =
                    purpose === "Education Background";

            }


            if (destinationCountry) {

                destinationCountry.required =
                    purpose === "Travel/Visa";

            }


            if (otherPurpose) {

                otherPurpose.required =
                    purpose === "Other";

            }

        }


        /* =====================================================
           FILE DISPLAY
        ====================================================== */

        function displayFileName(inputId = "", outputId = "") {

            const input =
                getInput(inputId);

            const output =
                getElement(outputId);


            if (!input || !output) {
                return;
            }


            input.addEventListener(
                "change",
                function () {

                    if (
                        input.files &&
                        input.files.length > 0
                    ) {

                        output.textContent =
                            "✓ " +
                            input.files[0].name;

                    }

                    else {

                        output.textContent = "";

                    }

                }
            );

        }

        var lastIdentityType = "";
        var identityTypeInitialized = false;
        function syncIdentityUploads() {
            var idType = getFormField("nationalIdType");
            if (!idType) return;

            var value = idType.value || "";
            if (identityTypeInitialized && lastIdentityType !== value) {
                ["ghanaCardFront", "ghanaCardBack", "identityDocument", "identityDocumentBack"].forEach(function (name) {
                    var file = getInput(name);
                    if (file) file.value = "";
                    var output = document.getElementById(name + "Name");
                    if (output) output.textContent = "";
                });
            }
            lastIdentityType = value;
            identityTypeInitialized = true;
            var isGhanaCard = value.toLowerCase() === "ghana card";
            var needsOtherDocument =
                value.toLowerCase() === "passport" ||
                value.toLowerCase() === "voter id" ||
                value.toLowerCase() === "driver's licence";
            var needsOtherBack = value.toLowerCase() === "voter id" ||
                value.toLowerCase() === "driver's licence";

            var frontCard = document.getElementById("ghanaCardFrontCard");
            var backCard = document.getElementById("ghanaCardBackCard");
            var otherCard = document.getElementById("identityDocumentCard");
            var front = getInput("ghanaCardFront");
            var back = getInput("ghanaCardBack");
            var other = getInput("identityDocument");
            var title = document.getElementById("identityDocumentTitle");
            var description = document.getElementById("identityDocumentDescription");

            if (frontCard) frontCard.style.display = isGhanaCard ? "" : "none";
            if (backCard) backCard.style.display = isGhanaCard ? "" : "none";
            if (otherCard) otherCard.style.display = needsOtherDocument ? "" : "none";
            if (front) front.required = isGhanaCard;
            if (back) back.required = isGhanaCard;
            if (other) other.required = needsOtherDocument;
            if (front) front.disabled = !isGhanaCard;
            if (back) back.disabled = !isGhanaCard;
            if (other) other.disabled = !needsOtherDocument;
            var otherBackCard = document.getElementById("identityDocumentBackCard");
            var otherBack = getInput("identityDocumentBack");
            if (otherBackCard) otherBackCard.style.display = needsOtherBack ? "" : "none";
            if (otherBack) otherBack.required = needsOtherBack;
            if (otherBack) otherBack.disabled = !needsOtherBack;
            var backTitle = document.getElementById("identityDocumentBackTitle");
            if (backTitle) backTitle.textContent = value + " — back";
            if (!needsOtherBack && otherBack) {
                otherBack.value = "";
                var backName = document.getElementById("identityDocumentBackName");
                if (backName) backName.textContent = "";
            }

            if (!needsOtherDocument && other) {
                other.value = "";
                var otherName = document.getElementById("identityDocumentName");
                if (otherName) otherName.textContent = "";
            }

            if (value.toLowerCase() === "passport") {
                if (title) title.textContent = "Passport bio-data page";
                if (description) description.textContent =
                    "Required when Passport is selected. JPG, JPEG, PNG or PDF. Maximum 5 MB.";
            } else if (needsOtherBack) {
                if (title) title.textContent = value + " — front";
                if (description) description.textContent =
                    "Upload a clear front view. JPG, JPEG, PNG or PDF. Maximum 5 MB.";
            }
        }


        /* =====================================================
           DATE LIMITS
        ====================================================== */

        function configureDateFields() {

            var today =
                new Date();


            var year =
                today.getFullYear();

            var month =
                String(
                    today.getMonth() + 1
                ).padStart(2, "0");

            var day =
                String(
                    today.getDate()
                ).padStart(2, "0");


            var todayString =
                year + "-" +
                month + "-" +
                day;


            var dateOfBirth =
                getInput("dateOfBirth");

            if (dateOfBirth) {

                dateOfBirth.max =
                    todayString;

            }


            var idIssueDate =
                getInput("idIssueDate");

            if (idIssueDate) {

                idIssueDate.max =
                    todayString;

            }

        }


        /* =====================================================
           CLIENT VALIDATION
        ====================================================== */

        function validateApplication() {

            var purpose =
                getValue("applicationPurpose");


            var errors = [];


            if (!purpose) {

                errors.push(
                    "Please select an application purpose."
                );

            }


            if (!getValue("fullName")) {

                errors.push(
                    "Full name is required."
                );

            }


            if (!getValue("gender")) {

                errors.push(
                    "Please select your gender."
                );

            }


            if (!getValue("dateOfBirth")) {

                errors.push(
                    "Date of birth is required."
                );

            }


            if (!getValue("maritalStatus")) {

                errors.push(
                    "Please select your marital status."
                );

            }


            if (!getValue("placeOfBirth")) {

                errors.push(
                    "Place of birth is required."
                );

            }


            if (!getValue("gpsAddress")) {

                errors.push(
                    "GhanaPost GPS address is required."
                );

            }


            var email =
                getValue("email");


            if (!email) {

                errors.push(
                    "Email address is required."
                );

            }

            else if (
                !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
            ) {

                errors.push(
                    "Please enter a valid email address."
                );

            }


            var phone =
                getValue("phone")
                    .replace(/\s|-/g, "");


            if (
                !/^0(2[0-9]|5[0-9])[0-9]{7}$/.test(phone)
            ) {

                errors.push(
                    "Please enter a valid Ghana mobile number."
                );

            }


            if (!getValue("profession")) {

                errors.push(
                    "Profession / occupation is required."
                );

            }


            if (!getValue("nextOfKinName")) {

                errors.push(
                    "Next of kin name is required."
                );

            }


            var kinPhone =
                getValue("nextOfKinPhone")
                    .replace(/\s|-/g, "");


            if (
                !/^0(2[0-9]|5[0-9])[0-9]{7}$/.test(kinPhone)
            ) {

                errors.push(
                    "Please enter a valid next of kin Ghana mobile number."
                );

            }


            if (!getValue("nationalIdType")) {

                errors.push(
                    "Please select a national ID type."
                );

            }


            if (!getValue("nationalIdNumber")) {

                errors.push(
                    "National ID / Passport number is required."
                );

            }


            if (purpose === "Employment") {

                if (!getValue("employerName")) {

                    errors.push(
                        "Employer / organisation is required."
                    );

                }


                if (!getValue("employmentPosition")) {

                    errors.push(
                        "Employment position is required."
                    );

                }

            }


            if (purpose === "Education Background") {

                if (!getValue("institutionName")) {

                    errors.push(
                        "Educational institution is required."
                    );

                }


                if (!getValue("programmeName")) {

                    errors.push(
                        "Programme is required."
                    );

                }

            }


            if (purpose === "Travel/Visa") {

                if (!getValue("destinationCountry")) {

                    errors.push(
                        "Destination country is required."
                    );

                }

            }


            if (purpose === "Other") {

                if (!getValue("otherPurpose")) {

                    errors.push(
                        "Please explain the application purpose."
                    );

                }

            }


            var passportPhoto =
                getInput("passportPhoto");


            if (
                !passportPhoto ||
                !passportPhoto.files ||
                passportPhoto.files.length === 0
            ) {

                errors.push(
                    "Passport photograph is required."
                );

            }


            var declaration =
                getInput("declarationAccepted");


            if (
                !declaration ||
                !declaration.checked
            ) {

                errors.push(
                    "You must accept the declaration."
                );

            }


            if (errors.length > 0) {

                var errorBox =
                    getElement("errorMessage");


                if (errorBox) {

                    errorBox.innerHTML =
                        "<strong>Please correct the following:</strong><br />" +
                        errors.join("<br />");

                    errorBox.classList.add("show");

                }


                window.scrollTo({
                    top: 0,
                    behavior: "smooth"
                });


                return false;

            }


            return true;

        }


        /* =====================================================
           FORM SUBMISSION
        ====================================================== */

        function configureFormSubmission() {

            var form =
                document.querySelector("form");


            const submitButton =
                getElement("btnSubmitApplication");

            if (!form ||
                !(submitButton instanceof HTMLButtonElement ||
                  submitButton instanceof HTMLInputElement)) {
                return;
            }


            form.addEventListener(
                "submit",
                function (event) {

                    if (!validateApplication()) {

                        event.preventDefault();

                        return;

                    }


                    if (submitButton.disabled) {

                        event.preventDefault();

                        return;

                    }


                    submitButton.disabled =
                        true;

                    submitButton.innerText =
                        "Submitting Application...";

                }
            );

        }


        /* =====================================================
           INITIALIZE
        ====================================================== */

        function initializePage() {
            var identitySelector = getFormField("nationalIdType");
            if (identitySelector) identitySelector.addEventListener("change", syncIdentityUploads);

            var purposeElement =
                getElement("applicationPurpose");


            if (purposeElement) {

                purposeElement.addEventListener(
                    "change",
                    updatePurposeDetails
                );

            }


            displayFileName(
                "passportPhoto",
                "passportPhotoName"
            );


            displayFileName(
                "ghanaCardFront",
                "ghanaCardFrontName"
            );


            displayFileName(
                "ghanaCardBack",
                "ghanaCardBackName"
            );

            displayFileName(
                "identityDocument",
                "identityDocumentName"
            );
            displayFileName("identityDocumentBack", "identityDocumentBackName");

            syncIdentityUploads();


            configureDateFields();

            updatePurposeDetails();

            configureFormSubmission();

        }


        if (
            document.readyState === "loading"
        ) {

            document.addEventListener(
                "DOMContentLoaded",
                initializePage
            );

        }

        else {

            initializePage();

        }

    })();

</script>

</asp:Content>