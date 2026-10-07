<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.AdminDashboard" %>
<%@ Register Src="~/UserManagement.ascx" TagPrefix="uc" TagName="UserManagement" %>
<%@ Register Src="~/AdminOperations.ascx" TagPrefix="uc" TagName="AdminOperations" %>
<%@ Register Src="~/ApplicationManagement.ascx" TagPrefix="uc" TagName="ApplicationManagement" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Dashboard
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style type="text/css">

    /* =====================================================
       ADMIN DASHBOARD — INSTITUTIONAL OPERATIONS CONSOLE
       Navy navigation, clear workspaces, accountable
       account management and cool-neutral data surfaces.
       Existing ga- selectors are retained for compatibility.
       ===================================================== */

    .ga-root {
        --navy: #0b2447;
        --navy-light: #19376d;
        --ink: #14213a;
        --gold: #2f5fa8;
        --blue: #1d4f9c;
        --green: #1d4f9c;
        --green-bg: #dfe9f7;
        --red: #0b2447;
        --red-bg: #c9d6ec;
        --amber: #3c5a85;
        --amber-bg: #eaf0f8;
        --purple: #19376d;
        --purple-bg: #e3eaf6;
        --muted: #4d5d78;
        --faint: #7d8aa3;
        --line: #d9e1ee;
        --soft: #f3f6fb;
        --tint: #e3ebf8;
        --shadow: 0 1px 2px rgba(11,36,71,.08), 0 2px 6px rgba(11,36,71,.06);
        display: flex;
        min-height: calc(100vh - 64px);
        background: #e9eef6;
        color: var(--ink);
        margin: 0;
    }

    .ga-root *,
    .ga-root *::before,
    .ga-root *::after {
        box-sizing: border-box;
        font-family: inherit;
    }

    /* Hide only Site.Master's duplicate header link; preserve module navigation. */
    .site-header .navigation.logged-user > a[id$="DashboardLink"][href$="AdminDashboard.aspx"] { display: none !important; }

    /* ---------------- SIDEBAR ---------------- */

    .ga-sidebar {
        width: 256px;
        flex: 0 0 auto;
        background: #fff;
        border-right: 1px solid var(--line);
        padding: 18px 12px 20px;
        position: sticky;
        top: 0;
        align-self: flex-start;
        height: 100vh;
        overflow-y: auto;
    }

    .ga-brand {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 6px 10px 20px;
        margin-bottom: 6px;
        border-bottom: 1px solid var(--line);
    }

    .ga-brand-mark {
        width: 36px;
        height: 36px;
        border-radius: 10px;
        display: grid;
        place-items: center;
        background: var(--navy);
        color: #fff;
        flex: 0 0 auto;
    }

    .ga-brand-mark svg { width: 20px; height: 20px; }

    .ga-brand-text {
        line-height: 1.2;
    }

    .ga-brand-text strong {
        display: block;
        font-size: 13px;
        font-weight: 700;
        color: var(--ink);
    }

    .ga-brand-text span {
        font-size: 10px;
        color: var(--muted);
        font-weight: 600;
        letter-spacing: .2px;
    }

    .ga-nav-group {
        margin: 16px 0 6px;
        padding: 0 10px;
        font-size: 10px;
        font-weight: 700;
        letter-spacing: .6px;
        text-transform: uppercase;
        color: var(--faint);
    }

    .ga-nav-item {
        width: 100%;
        display: flex;
        align-items: center;
        gap: 11px;
        padding: 9px 11px;
        border: 0;
        background: none;
        border-radius: 20px;
        font-size: 13px;
        font-weight: 600;
        color: var(--muted);
        cursor: pointer;
        text-decoration: none;
        margin-bottom: 2px;
        transition: background .12s ease, color .12s ease;
    }

    .ga-nav-item svg { width: 18px; height: 18px; flex: 0 0 auto; }

    .ga-nav-item:hover {
        background: var(--soft);
        color: var(--ink);
        text-decoration: none;
    }

    .ga-nav-item.active {
        background: var(--tint);
        color: var(--navy);
        font-weight: 700;
    }

    .ga-nav-item .ga-ext {
        margin-left: auto;
        width: 13px;
        height: 13px;
        opacity: .5;
    }

    /* ---------------- MAIN COLUMN ---------------- */

    .ga-main {
        flex: 1 1 auto;
        min-width: 0;
        display: flex;
        flex-direction: column;
    }

    /* ---------------- TOP BAR ---------------- */

    .ga-topbar {
        position: sticky;
        top: 0;
        z-index: 5;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        padding: 14px 26px;
        background: rgba(255,255,255,.96);
        -webkit-backdrop-filter: blur(6px);
        backdrop-filter: blur(6px);
        border-bottom: 1px solid var(--line);
    }

    .ga-page-heading h1 {
        margin: 0;
        font-size: 19px;
        font-weight: 700;
        color: var(--ink);
    }

    .ga-page-heading p {
        margin: 2px 0 0;
        font-size: 12px;
        color: var(--muted);
    }

    .ga-topbar-right {
        display: flex;
        align-items: center;
        gap: 14px;
        flex: 0 0 auto;
    }

    .ga-search {
        position: relative;
        width: 280px;
    }

    .ga-search svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        width: 16px;
        height: 16px;
        color: var(--faint);
    }

    .ga-search input {
        width: 100%;
        height: 38px;
        padding: 0 12px 0 36px;
        border: 1px solid var(--line);
        border-radius: 10px;
        background: var(--soft);
        font-size: 13px;
        color: var(--ink);
        outline: none;
        transition: background .15s ease, border-color .15s ease;
    }

    .ga-search input:focus {
        background: #fff;
        border-color: var(--navy);
        box-shadow: 0 0 0 3px rgba(23,43,77,.10);
    }

    .ga-admin {
        display: flex;
        align-items: center;
        gap: 10px;
        padding-left: 14px;
        border-left: 1px solid var(--line);
    }

    .ga-avatar {
        width: 34px;
        height: 34px;
        border-radius: 50%;
        background: var(--navy);
        color: #fff;
        display: grid;
        place-items: center;
        font-size: 12px;
        font-weight: 700;
        flex: 0 0 auto;
    }

    .ga-admin-meta {
        line-height: 1.25;
    }

    .ga-admin-meta strong {
        display: block;
        font-size: 12px;
        font-weight: 700;
        color: var(--ink);
    }

    .ga-admin-meta span {
        font-size: 10px;
        color: var(--faint);
    }

    /* ---------------- CONTENT ---------------- */

    .ga-content {
        padding: 22px 26px 60px;
        max-width: 1320px;
        width: 100%;
    }

    .ga-message {
        margin: 0 0 18px;
        padding: 12px 15px;
        border-radius: 10px;
        background: var(--amber-bg);
        border: 1px solid #b9c9e3;
        color: var(--amber);
        font-size: 12px;
        font-weight: 600;
    }

    .ga-panel { display: none; }
    .ga-panel.active { display: block; animation: gaFade .25s ease; }

    .ga-section { margin-bottom: 24px; }

    .ga-section-title {
        margin: 0 0 12px;
        font-size: 14px;
        font-weight: 700;
        color: var(--ink);
    }

    /* ---------------- STAT CARDS ---------------- */

    .ga-stat-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 12px;
    }

    .ga-stat {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 12px;
        box-shadow: var(--shadow);
        padding: 16px;
        transition: box-shadow .15s ease;
    }

    .ga-stat:hover {
        box-shadow: 0 1px 2px rgba(60,64,67,.1), 0 4px 10px rgba(60,64,67,.12);
    }

    .ga-stat-icon {
        width: 34px;
        height: 34px;
        border-radius: 9px;
        display: grid;
        place-items: center;
        margin-bottom: 12px;
    }

    .ga-stat-icon svg { width: 17px; height: 17px; }

    .ga-stat.c-navy  .ga-stat-icon { background: var(--tint);    color: var(--navy); }
    .ga-stat.c-gold  .ga-stat-icon { background: var(--tint); color: var(--blue); }
    .ga-stat.c-green .ga-stat-icon { background: var(--green-bg);color: var(--green); }
    .ga-stat.c-red   .ga-stat-icon { background: var(--red-bg);  color: var(--red); }
    .ga-stat.c-amber .ga-stat-icon { background: var(--amber-bg);color: var(--amber); }
    .ga-stat.c-purple.ga-stat-icon { background: var(--purple-bg); color: var(--purple); }

    .ga-stat-value {
        font-size: 24px;
        font-weight: 700;
        color: var(--ink);
        letter-spacing: -.3px;
    }

    .ga-stat-label {
        margin-top: 2px;
        font-size: 12px;
        color: var(--muted);
    }

    /* ---------------- GENERIC CARD ---------------- */

    .ga-card {
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 12px;
        box-shadow: var(--shadow);
        overflow: hidden;
    }

    .ga-card-head {
        padding: 16px 18px 12px;
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: 12px;
    }

    .ga-card-title {
        margin: 0;
        font-size: 13px;
        font-weight: 700;
        color: var(--ink);
    }

    .ga-card-sub {
        margin-top: 3px;
        font-size: 11px;
        color: var(--faint);
    }

    .ga-tag {
        white-space: nowrap;
        padding: 4px 9px;
        border-radius: 999px;
        font-size: 10px;
        font-weight: 700;
        color: var(--navy);
        background: var(--tint);
    }

    .ga-card-body {
        padding: 0 18px 18px;
    }

    .ga-two-col {
        display: grid;
        grid-template-columns: 1.4fr 1fr;
        gap: 14px;
    }

    /* ---------------- DEMAND / HEALTH ROWS ---------------- */

    .ga-row-list { display: grid; gap: 13px; }

    .ga-row {
        display: grid;
        grid-template-columns: 100px 1fr 40px;
        align-items: center;
        gap: 10px;
    }

    .ga-row-name { font-size: 12px; font-weight: 600; color: var(--muted); }
    .ga-row-value { font-size: 12px; font-weight: 700; color: var(--ink); text-align: right; }

    .ga-track {
        height: 6px;
        border-radius: 999px;
        background: #edeef0;
        overflow: hidden;
    }

    .ga-fill {
        width: 0;
        height: 100%;
        border-radius: 999px;
        background: var(--navy);
    }

    .ga-fill.f-green { background: var(--green); }
    .ga-fill.f-red   { background: var(--red); }
    .ga-fill.f-amber { background: var(--amber); }

    .ga-purpose-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 10px;
    }

    .ga-purpose-item {
        padding: 13px;
        border: 1px solid var(--line);
        border-radius: 10px;
        background: var(--soft);
    }

    .ga-purpose-top {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
    }

    .ga-purpose-name { font-size: 11px; font-weight: 700; color: var(--muted); }
    .ga-purpose-value { font-size: 17px; font-weight: 700; color: var(--ink); }

    /* ---------------- RECENT LIST ---------------- */

    .ga-recent-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 11px 0;
        border-bottom: 1px solid #f1f3f4;
    }

    .ga-recent-row:last-child { border-bottom: 0; }

    .ga-recent-name { font-size: 12px; font-weight: 700; color: var(--ink); }
    .ga-recent-meta { font-size: 10px; color: var(--faint); margin-top: 2px; }

    .ga-pill {
        display: inline-flex;
        align-items: center;
        padding: 4px 10px;
        border-radius: 999px;
        font-size: 10px;
        font-weight: 700;
        white-space: nowrap;
    }

    .status-pending  { background: var(--amber-bg); color: var(--amber); }
    .status-approved { background: var(--green-bg); color: var(--green); }
    .status-rejected { background: var(--red-bg);   color: var(--red); }
    .status-neutral  { background: #eef1f4;         color: var(--muted); }

    /* ---------------- REGIONS ---------------- */

    .ga-region-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 9px;
    }

    .ga-region {
        padding: 11px;
        border: 1px solid var(--line);
        border-radius: 10px;
        background: var(--soft);
    }

    .ga-region-name {
        font-size: 9px;
        font-weight: 700;
        letter-spacing: .3px;
        text-transform: uppercase;
        color: var(--muted);
    }

    .ga-region-count { font-size: 17px; font-weight: 700; color: var(--ink); margin-top: 3px; }
    .ga-region-share { font-size: 9px; color: var(--faint); margin-top: 1px; }

    .ga-region-line {
        height: 3px;
        border-radius: 99px;
        background: #edeef0;
        margin-top: 7px;
        overflow: hidden;
    }

    .ga-region-line .ga-region-fill {
        display: block;
        height: 100%;
        border-radius: 99px;
        background: linear-gradient(90deg, var(--navy), #5b86c7);
    }

    /* ---------------- USERS TAB MINI STATS ---------------- */

    .ga-mini-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }

    .ga-mini {
        padding: 18px;
        background: #fff;
        border: 1px solid var(--line);
        border-radius: 12px;
        box-shadow: var(--shadow);
    }

    .ga-mini .num { font-size: 24px; font-weight: 700; color: var(--ink); }
    .ga-mini .name { font-size: 11px; color: var(--muted); margin-top: 3px; }

    /* ---------------- TOOLBAR / FILTERS ---------------- */

    .ga-toolbar {
        padding: 14px 18px;
        background: var(--soft);
        border-top: 1px solid var(--line);
        border-bottom: 1px solid var(--line);
    }

    .ga-filter-row {
        display: grid;
        grid-template-columns: 1.5fr 1fr 1fr 1fr auto auto;
        gap: 9px;
        align-items: end;
    }

    .ga-field label {
        display: block;
        margin-bottom: 5px;
        font-size: 9px;
        font-weight: 700;
        letter-spacing: .4px;
        text-transform: uppercase;
        color: var(--faint);
    }

    .ga-input, .ga-select {
        width: 100%;
        height: 36px;
        padding: 0 11px;
        border: 1px solid #d7d9db;
        border-radius: 8px;
        background: #fff;
        font-size: 12px;
        color: var(--ink);
        outline: none;
    }

    .ga-input:focus, .ga-select:focus {
        border-color: var(--navy);
        box-shadow: 0 0 0 3px rgba(23,43,77,.10);
    }

    .ga-btn {
        height: 36px;
        padding: 0 15px;
        border: 0;
        border-radius: 8px;
        font-size: 11px;
        font-weight: 700;
        cursor: pointer;
    }

    .ga-btn-primary { background: var(--navy); color: #fff; }
    .ga-btn-primary:hover { background: var(--navy-light); }
    .ga-btn-light { background: #fff; color: var(--muted); border: 1px solid #d7d9db; }
    .ga-btn-light:hover { background: var(--soft); }

    /* ---------------- TABLE ---------------- */

    .ga-table-wrap { overflow-x: auto; }

    .ga-table { width: 100%; border-collapse: collapse; font-size: 12px; }

    .ga-table th {
        padding: 11px 14px;
        text-align: left;
        white-space: nowrap;
        font-size: 10px;
        font-weight: 700;
        letter-spacing: .3px;
        text-transform: uppercase;
        color: var(--muted);
        background: var(--soft);
        border-bottom: 1px solid var(--line);
    }

    .ga-table td {
        padding: 12px 14px;
        border-bottom: 1px solid #f1f3f4;
        color: var(--muted);
        vertical-align: middle;
    }

    .ga-table tr:hover td { background: #fafbfc; }

    .ga-inspect {
        height: 28px;
        padding: 0 12px;
        border: 1px solid #c9d6ec;
        border-radius: 7px;
        font-size: 10px;
        font-weight: 700;
        cursor: pointer;
        color: var(--navy);
        background: var(--tint);
    }

    .ga-inspect:hover { color: #fff; background: var(--navy); }

    .ga-pager { padding: 11px 14px; text-align: center; background: #fff; }

    .ga-pager a, .ga-pager span {
        display: inline-block;
        margin: 0 2px;
        padding: 5px 9px;
        border: 1px solid var(--line);
        border-radius: 7px;
        text-decoration: none;
        color: var(--navy);
        font-size: 11px;
        font-weight: 700;
    }

    .ga-pager span { background: var(--navy); color: #fff; border-color: var(--navy); }

    /* ---------------- DRAWER ---------------- */

    .ga-drawer-overlay {
        position: fixed;
        inset: 0;
        background: rgba(32,33,36,.55);
        z-index: 9998;
    }

    .ga-drawer {
        position: absolute;
        right: 0;
        top: 0;
        height: 100%;
        width: min(600px, 100%);
        background: #fff;
        box-shadow: -16px 0 40px rgba(0,0,0,.2);
        overflow-y: auto;
    }

    .ga-drawer-head {
        position: sticky;
        top: 0;
        z-index: 2;
        padding: 18px 20px;
        background: var(--navy);
        color: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .ga-drawer-kicker {
        font-size: 9px;
        text-transform: uppercase;
        letter-spacing: 1px;
        font-weight: 700;
        color: #c3d0e8;
    }

    .ga-drawer-head h3 { margin: 4px 0 0; font-size: 16px; font-weight: 700; color: #fff; word-break: break-all; }

    .ga-close {
        width: 30px; height: 30px; border: 0; border-radius: 8px;
        background: rgba(255,255,255,.16); color: #fff;
        font-size: 17px; font-weight: 700; cursor: pointer;
    }

    .ga-close:hover { background: rgba(255,255,255,.28); }

    .ga-details {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 9px;
        padding: 18px 20px;
    }

    .ga-detail { border: 1px solid var(--line); border-radius: 10px; padding: 11px; background: var(--soft); }
    .ga-detail.full { grid-column: 1 / -1; }

    .ga-detail-label {
        font-size: 9px; text-transform: uppercase; letter-spacing: .4px;
        color: var(--faint); font-weight: 700;
    }

    .ga-detail-value {
        font-size: 12px; font-weight: 600; color: var(--ink);
        margin-top: 4px; line-height: 1.5; word-break: break-word;
    }

    .ga-timeline { padding: 0 20px 26px; }
    .ga-timeline h4 { font-size: 12px; font-weight: 700; color: var(--ink); margin: 0 0 13px; }

    .ga-timeline-item {
        position: relative;
        padding: 0 0 15px 18px;
        border-left: 2px solid var(--line);
        margin-left: 5px;
    }

    .ga-timeline-item::before {
        content: "";
        position: absolute; left: -5px; top: 1px;
        width: 8px; height: 8px; border-radius: 50%;
        background: var(--navy); border: 2px solid #fff;
        box-shadow: 0 0 0 1px #c9d6ec;
    }

    .ga-timeline-item strong { font-size: 10px; font-weight: 700; color: var(--navy); }
    .ga-timeline-item div { font-size: 10px; color: var(--muted); margin-top: 3px; line-height: 1.5; }

    @keyframes gaFade { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: none; } }

    /* ---------------- RESPONSIVE ---------------- */

    @media (max-width: 1150px) {
        .ga-stat-grid, .ga-tiles, .ga-mini-grid { grid-template-columns: repeat(2, 1fr); }
        .ga-region-grid { grid-template-columns: repeat(2, 1fr); }
        .ga-two-col { grid-template-columns: 1fr; }
        .ga-filter-row { grid-template-columns: 1fr 1fr 1fr; }
        .ga-search { width: 200px; }
    }

    @media (max-width: 900px) {
        .ga-root { flex-direction: column; }
        .ga-sidebar { width: 100%; height: auto; position: static; border-right: 0; border-bottom: 1px solid var(--line); display: flex; align-items: center; overflow-x: auto; padding: 10px 14px; }
        .ga-brand { border-bottom: 0; padding: 0 14px 0 0; margin: 0; }
        .ga-nav-group { display: none; }
        .ga-nav-item { white-space: nowrap; }
        .ga-topbar { flex-wrap: wrap; }
    }

    @media (max-width: 620px) {
        .ga-stat-grid, .ga-tiles, .ga-mini-grid, .ga-purpose-grid, .ga-region-grid { grid-template-columns: 1fr; }
        .ga-filter-row { grid-template-columns: 1fr; }
        .ga-details { grid-template-columns: 1fr; }
        .ga-detail.full { grid-column: auto; }
        .ga-search { display: none; }
        .ga-content { padding: 18px 14px 50px; }
        .ga-topbar { padding: 12px 14px; }
    }


    /* ===== INSTITUTIONAL NAVY REDESIGN LAYER ===== */
    .ga-sidebar { overflow-y: auto; overscroll-behavior: contain; }
    .ga-sidebar { background: linear-gradient(180deg, #0b2447 0%, #0e2d5a 100%); border-right: 0; width: 272px; padding: 0 0 20px; }
    .ga-brand { padding: 22px 20px 18px; margin: 0 0 8px; border-bottom: 1px solid rgba(255,255,255,.12); background: rgba(0,0,0,.14); }
    .ga-brand-mark { background: #fff; color: var(--navy); border-radius: 8px; }
    .ga-brand-text strong { color: #fff; font-size: 14px; letter-spacing: .3px; }
    .ga-brand-text span { color: #a9bde0; text-transform: uppercase; letter-spacing: 1.2px; }
    .ga-nav-group { color: #7f98c6; padding: 0 20px; margin: 20px 0 8px; letter-spacing: 1.2px; }
    .ga-nav-item { color: #cbd8ef; border-radius: 0; padding: 11px 20px; margin: 0; width: 100%; border-left: 3px solid transparent; }
    .ga-nav-item:hover { background: rgba(255,255,255,.08); color: #fff; }
    .ga-nav-item.active { background: rgba(255,255,255,.14); color: #fff; border-left-color: #fff; }
    .ga-topbar { background: #fff; border-bottom: 3px solid var(--navy); padding: 16px 28px; }
    .ga-page-heading h1 { font-size: 22px; color: var(--navy); letter-spacing: -.2px; }
    .ga-avatar { border-radius: 8px; }
    .ga-section-title { font-size: 11px; text-transform: uppercase; letter-spacing: 1.2px; color: var(--navy); padding-bottom: 8px; border-bottom: 1px solid var(--line); margin-bottom: 14px; }
    .ga-stat { border-radius: 4px; border-top: 3px solid var(--navy); padding: 18px; }
    .ga-stat-icon { border-radius: 4px; }
    .ga-stat-value { font-size: 30px; color: var(--navy); }
    .ga-stat-label { text-transform: uppercase; letter-spacing: .6px; font-size: 10.5px; font-weight: 700; }
    .ga-card, .ga-mini, .ga-tile { border-radius: 4px; }
    .ga-card-head { border-bottom: 1px solid var(--line); padding: 16px 20px; background: var(--soft); }
    .ga-card-body { padding: 18px 20px 20px; }
    .ga-card-title { font-size: 13px; text-transform: uppercase; letter-spacing: .8px; color: var(--navy); }
    .ga-tag { border-radius: 3px; background: var(--navy); color: #fff; letter-spacing: .5px; text-transform: uppercase; }
    .ga-mini { border-left: 4px solid var(--navy); }
    .ga-mini .num { color: var(--navy); }
    .ga-tile { border-top: 3px solid var(--navy); }
    .ga-tile-icon { border-radius: 4px; background: var(--navy) !important; }
    .ga-tile p { min-height: 48px; }
    .ga-chip, .ga-chip.green, .ga-chip.gold { background: var(--tint); color: var(--navy); border-radius: 3px; }
    .ga-pill { border-radius: 3px; text-transform: uppercase; letter-spacing: .4px; font-size: 9.5px; }
    .status-pending  { background: #fff; color: var(--amber); border: 1px solid #9fb3d3; }
    .status-approved { background: var(--navy); color: #fff; }
    .status-rejected { background: #e3ebf8; color: var(--navy); border: 1px solid var(--navy); }
    .status-neutral  { background: #eef1f6; color: var(--muted); }
    .ga-table th { background: var(--navy); color: #fff; border-bottom: 0; padding: 12px 16px; }
    .ga-table td { padding: 13px 16px; color: var(--ink); border-bottom: 1px solid var(--line); }
    .ga-table tr:nth-child(even) td { background: #f7f9fd; }
    .ga-table tr:hover td { background: var(--tint); }
    .ga-toolbar { background: #eef3fa; }
    .ga-input, .ga-select, .ga-btn, .ga-inspect, .ga-search input { border-radius: 3px; }
    .ga-input, .ga-select { border-color: #b8c6dd; }
    .ga-btn-primary { background: var(--navy); }
    .ga-inspect { background: #fff; border-color: var(--navy); }
    .ga-drawer { border-radius: 0; }
    .ga-drawer-overlay { background: rgba(11,36,71,.6); }
    .ga-drawer-head { background: var(--navy); }
    .ga-detail { border-radius: 3px; }
    @media (max-width: 900px) { .ga-sidebar { background: #0b2447; padding: 0; } .ga-nav-item { width: auto; } }
    /* Embedded account controls share the administrative navy palette. */
    .ga-main .um-active, .ga-main .um-success { background: #dfe9f7; color: #19376d; }
    .ga-main .um-inactive, .ga-main .um-error { background: #eaf0f8; color: #0b2447; }
    .ga-main .um-success, .ga-main .um-error { border-color: #b8cae2; }
    .ga-main .um-setup-warning { background: #eaf0f8; border-color: #b8cae2; color: #19376d; }
    .ga-main .um-table th { background: #0b2447; color: #fff; }
    .ga-main .um-table tbody tr:nth-child(even) { background: #f1f5fb; }
    body .site-main { max-width: none; margin: 0; padding: 0; }
    .ga-workspace-banner {
        display: flex; align-items: center; justify-content: space-between; gap: 24px;
        padding: 28px 30px; margin: 0 0 24px; border-radius: 10px;
        background: linear-gradient(115deg, #0b2447, #19376d); color: #fff;
        border-bottom: 4px solid #3b70ba;
    }
    .ga-workspace-banner .eyebrow { color: #bed0eb; font-size: 10px; letter-spacing: 1.5px; font-weight: 700; text-transform: uppercase; }
    .ga-workspace-banner h2 { margin: 8px 0; font-size: 27px; letter-spacing: -.5px; color: #fff; font-weight: 700; }
    .ga-workspace-banner p { margin: 0; max-width: 680px; color: #d9e5f6; font-size: 13px; line-height: 1.6; }
    .ga-workspace-banner .banner-note { padding: 10px 14px; border: 1px solid #6b8ebf; border-radius: 6px; color: #e8f0fc; font-size: 11px; white-space: nowrap; }
    @media (max-width: 900px) {
        .ga-sidebar { width: 100%; height: auto; padding: 0; }
        .ga-brand { flex-shrink: 0; padding: 14px; }
        .ga-nav-item { flex-shrink: 0; width: auto; }
        .ga-workspace-banner { padding: 22px; }
    }
    @media (max-width: 620px) {
        .ga-workspace-banner { flex-direction: column; align-items: flex-start; gap: 14px; }
        .ga-workspace-banner h2 { font-size: 23px; }
        .ga-workspace-banner .banner-note { white-space: normal; }
    }

    /* ===== READ-ONLY INSPECTION DIALOG ===== */
    .ga-drawer-overlay { display: flex; align-items: center; justify-content: center; padding: 20px; }
    .gd-dialog { width: 100%; max-width: 1000px; max-height: 90vh; display: flex; flex-direction: column; background: #fff; border-radius: 4px; box-shadow: 0 20px 70px rgba(11,36,71,.35); overflow: hidden; }
    .gd-head { display: flex; justify-content: space-between; align-items: center; gap: 16px; padding: 18px 24px; background: #0b2447; color: #fff; }
    .gd-kicker { font-size: 10px; text-transform: uppercase; letter-spacing: 1.2px; font-weight: 700; color: #c3d0e8; }
    .gd-head h3 { margin: 4px 0 0; font-size: 18px; font-weight: 700; color: #fff; word-break: break-word; }
    .gd-close { height: 36px; padding: 0 16px; border: 1px solid rgba(255,255,255,.5); border-radius: 3px; background: transparent; color: #fff; font-size: 12px; font-weight: 700; cursor: pointer; }
    .gd-close:hover { background: rgba(255,255,255,.16); }
    .gd-nav { display: flex; gap: 4px; padding: 8px 16px; overflow-x: auto; background: #eef3fa; border-bottom: 1px solid #d9e1ee; }
    .gd-nav button { flex: 0 0 auto; padding: 8px 12px; border: 0; border-radius: 3px; background: transparent; color: #19376d; font-size: 12px; font-weight: 700; cursor: pointer; }
    .gd-nav button:hover { background: #dfe9f7; }
    .gd-dialog button:focus-visible, .gd-dialog input:focus-visible, .gd-doc:focus-visible, .gd-section:focus-visible { outline: 2px solid #1d4f9c; outline-offset: 2px; }
    .gd-head, .gd-nav, .gd-foot { flex-shrink: 0; }
    .gd-body { padding: 22px 24px 8px; overflow-y: auto; flex: 1 1 auto; min-height: 0; scroll-behavior: smooth; }
    .gd-notice { margin: 0 0 20px; padding: 11px 13px; border: 1px solid #b8cae2; background: #eaf0f8; color: #19376d; font-size: 12px; line-height: 1.5; }
    .gd-section { margin-bottom: 24px; scroll-margin-top: 8px; }
    .gd-section h4 { margin: 0 0 12px; padding-bottom: 8px; border-bottom: 1px solid #d9e1ee; color: #0b2447; font-size: 13px; text-transform: uppercase; letter-spacing: .8px; }
    .gd-meta { margin: 0 0 12px; color: #4d5d78; font-size: 12px; line-height: 1.6; }
    .gd-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px 20px; margin: 0; }
    .gd-item { margin: 0; padding: 9px 11px; border: 1px solid #d9e1ee; background: #f3f6fb; border-radius: 3px; }
    .gd-item.full { grid-column: 1 / -1; }
    .gd-item dt { font-size: 10px; text-transform: uppercase; letter-spacing: .4px; font-weight: 700; color: #4d5d78; }
    .gd-item dd { margin: 4px 0 0; font-size: 13px; font-weight: 600; color: #14213a; line-height: 1.5; word-break: break-word; }
    .gd-doc-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; }
    .gd-doc { display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 16px 18px; border: 1px solid #b8cae2; border-left: 4px solid #19376d; background: #f1f5fb; color: #0b2447; font-size: 13px; font-weight: 700; text-decoration: none; border-radius: 3px; }
    .gd-doc em { font-style: normal; font-size: 11px; color: #365f97; }
    .gd-doc:hover { background: #e2ebf8; }
    .gd-table-wrap { overflow-x: auto; }
    .gd-table { width: 100%; border-collapse: collapse; font-size: 12px; min-width: 560px; }
    .gd-table th { background: #0b2447; color: #fff; padding: 11px 12px; text-align: left; font-size: 11px; text-transform: uppercase; letter-spacing: .3px; }
    .gd-table td { padding: 11px 12px; border-bottom: 1px solid #d9e1ee; vertical-align: top; color: #14213a; }
    .gd-foot { padding: 12px 24px; border-top: 1px solid #d9e1ee; background: #f3f6fb; color: #4d5d78; font-size: 11px; }
    @media (max-width: 650px) { .ga-drawer-overlay { padding: 0; } .gd-dialog { max-height: 100dvh; height: 100dvh; border-radius: 0; } .gd-grid { grid-template-columns: 1fr; } .gd-item.full { grid-column: auto; } .gd-head, .gd-body, .gd-foot { padding-left: 16px; padding-right: 16px; } }
</style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="ga-root">

    <!-- ================= SIDEBAR ================= -->

    <aside class="ga-sidebar">

        <div class="ga-brand">
            <div class="ga-brand-mark">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l8 3v6c0 5.2-3.4 9.5-8 11-4.6-1.5-8-5.8-8-11V5l8-3z"/><path d="M9 12l2 2 4-4"/></svg>
            </div>
            <div class="ga-brand-text">
                <strong>Ghana Police</strong>
                <span>Admin Console</span>
            </div>
        </div>

        <div class="ga-nav-group">Dashboard</div>

        <button type="button" class="ga-nav-item active" data-nav="overview" onclick="gaSwitchTab('overview')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>
            Overview
        </button>

        <button type="button" class="ga-nav-item" data-nav="users" onclick="gaSwitchTab('users')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2"/><circle cx="10" cy="7" r="4"/><path d="M19 8v6M22 11h-6"/></svg>
            User accounts (all roles)
        </button>

        <button type="button" class="ga-nav-item" data-nav="applications" onclick="gaSwitchTab('applications')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M8 13h8M8 17h5"/></svg>
            Applications
        </button>

        <button type="button" class="ga-nav-item" data-nav="activity" onclick="gaSwitchTab('activity')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>
            Activity log
        </button>

        <div class="ga-nav-group">Operations</div>
        <a class="ga-nav-item" data-nav="operations" data-module="applications" href="AdminDashboard.aspx?tab=operations&amp;module=applications">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16v16H4zM8 9h8M8 13h8"/></svg>
            Applications
        </a>
        <a class="ga-nav-item" data-nav="operations" data-module="identity" href="AdminDashboard.aspx?tab=operations&amp;module=identity">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            Identity verification
        </a>
        <a class="ga-nav-item" data-nav="operations" data-module="officers" href="AdminDashboard.aspx?tab=operations&amp;module=officers">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 11a4 4 0 1 0-8 0M4 21c0-4 4-6 8-6s8 2 8 6"/></svg>
            Officers
        </a>
        <a class="ga-nav-item" data-nav="operations" data-module="cases" href="AdminDashboard.aspx?tab=operations&amp;module=cases">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2h9l5 5v15H6zM14 2v6h6"/></svg>
            Police reports
        </a>
        <div class="ga-nav-group">Oversight</div>
        <a class="ga-nav-item" data-nav="operations" data-module="security" href="AdminDashboard.aspx?tab=operations&amp;module=security">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 11h14v10H5zM8 11V7a4 4 0 0 1 8 0v4"/></svg>
            Security
        </a>
        <a class="ga-nav-item" data-nav="operations" data-module="analytics" href="AdminDashboard.aspx?tab=operations&amp;module=analytics">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20V10M10 20V4M16 20v-8M22 20H2"/></svg>
            Analytics
        </a>
        <a class="ga-nav-item" data-nav="operations" data-module="notifications" href="AdminDashboard.aspx?tab=operations&amp;module=notifications">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 8 3 8H3s3-1 3-8M10 21h4"/></svg>
            Notifications
        </a>
        <a class="ga-nav-item" data-nav="operations" data-module="payments" href="AdminDashboard.aspx?tab=operations&amp;module=payments">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 6h20v12H2zM2 10h20"/></svg>
            Payments
        </a>
        <div class="ga-nav-group">Workspaces</div>

        <a class="ga-nav-item" href="VettingDashboard.aspx">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg>
            Document Review Queue
            <svg class="ga-ext" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7 17L17 7M7 7h10v10"/></svg>
        </a>

        <a class="ga-nav-item" href="PaymentMonitoring.aspx">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
            Payment Monitoring
            <svg class="ga-ext" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7 17L17 7M7 7h10v10"/></svg>
        </a>

        <a id="gaCertificateMonitoringLink" class="ga-nav-item" href="CertificateManagement.aspx">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="5"/><path d="M8.5 12.5L7 22l5-3 5 3-1.5-9.5"/></svg>
            Certificate Monitoring
            <svg class="ga-ext" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7 17L17 7M7 7h10v10"/></svg>
        </a>

    </aside>


    <!-- ================= MAIN COLUMN ================= -->

    <div class="ga-main">

        <!-- ---------------- TOP BAR ---------------- -->

        <div class="ga-topbar">

            <div class="ga-page-heading">
                <h1 id="gaPageTitle">Overview</h1>
                <p id="gaPageSubtitle">Platform summary and recent activity</p>
            </div>

            <div class="ga-topbar-right">

                <div class="ga-search">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
                    <input type="text" id="gaTopSearch" placeholder="Search applications..." autocomplete="off" />
                </div>

                <div class="ga-admin">
                    <div class="ga-avatar">AD</div>
                    <div class="ga-admin-meta">
                        <strong><asp:Label ID="lblAdminName" runat="server" Text="System Administrator" /></strong>
                        <span><asp:Label ID="lblDashboardDate" runat="server" /></span>
                    </div>
                </div>

            </div>
        </div>


        <!-- ---------------- CONTENT ---------------- -->

        <div class="ga-content">

            <asp:Panel ID="pnlDashboardMessage" runat="server" CssClass="ga-message" Visible="false">
                <asp:Literal ID="litDashboardMessage" runat="server" />
            </asp:Panel>


            <!-- ================= OVERVIEW PANEL ================= -->

            <div id="gaPanelOverview" class="ga-panel active">
                <div class="ga-workspace-banner">
                    <div>
                        <div class="eyebrow">Police background-check administration</div>
                        <h2>Operations overview</h2>
                        <p>Monitor application demand, officer review activity and account access. Use the dedicated workspaces for record-level decisions and audit history.</p>
                    </div>
                    <div class="banner-note">Administration &amp; oversight</div>
                </div>

                <div style="display:flex;flex-wrap:wrap;gap:8px;margin:0 0 18px;font-size:11px" aria-label="Operational attention indicators">
                    <asp:Repeater ID="rptOperationalIndicators" runat="server">
                        <ItemTemplate>
                            <a href='<%#: Eval("Url") %>' style="padding:7px 10px;border:1px solid #d9e1ee;color:#19376d;background:#fff;text-decoration:none;border-radius:3px">
                                <%#: Eval("Label") %>: <strong><%#: Eval("Value") %></strong>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="ga-section">
                    <h2 class="ga-section-title">User statistics</h2>
                    <div class="ga-stat-grid">

                        <div class="ga-stat c-navy">
                            <div class="ga-stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2"/><circle cx="10" cy="7" r="4"/><path d="M19 8v6M22 11h-6"/></svg></div>
                            <div class="ga-stat-value"><asp:Label ID="lblTotalUsers" runat="server" Text="0" /></div>
                            <div class="ga-stat-label">Total users</div>
                        </div>

                        <div class="ga-stat c-navy">
                            <div class="ga-stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2"/><circle cx="10" cy="7" r="4"/></svg></div>
                            <div class="ga-stat-value"><asp:Label ID="lblRegisteredCitizens" runat="server" Text="0" /></div>
                            <div class="ga-stat-label">Citizens</div>
                        </div>

                        <div class="ga-stat c-gold">
                            <div class="ga-stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l8 3v6c0 5.2-3.4 9.5-8 11-4.6-1.5-8-5.8-8-11V5l8-3z"/></svg></div>
                            <div class="ga-stat-value"><asp:Label ID="lblActiveOfficers" runat="server" Text="0" /></div>
                            <div class="ga-stat-label">Police officers</div>
                        </div>

                        <div class="ga-stat c-purple">
                            <div class="ga-stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="5"/><path d="M8.5 12.5L7 22l5-3 5 3-1.5-9.5"/></svg></div>
                            <div class="ga-stat-value"><asp:Label ID="lblAdmins" runat="server" Text="0" /></div>
                            <div class="ga-stat-label">Administrators</div>
                        </div>

                    </div>
                </div>

                <div class="ga-section">
                    <h2 class="ga-section-title">Application statistics</h2>
                    <div class="ga-stat-grid">

                        <div class="ga-stat c-navy">
                            <div class="ga-stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg></div>
                            <div class="ga-stat-value"><asp:Label ID="lblApplicationsSubmitted" runat="server" Text="0" /></div>
                            <div class="ga-stat-label">Total applications</div>
                        </div>

                        <div class="ga-stat c-amber">
                            <div class="ga-stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg></div>
                            <div class="ga-stat-value"><asp:Label ID="lblIncoming" runat="server" Text="0" /></div>
                            <div class="ga-stat-label">Pending</div>
                        </div>

                        <div class="ga-stat c-green">
                            <div class="ga-stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg></div>
                            <div class="ga-stat-value"><asp:Label ID="lblApprovedReview" runat="server" Text="0" /></div>
                            <div class="ga-stat-label">Approved</div>
                        </div>

                        <div class="ga-stat c-red">
                            <div class="ga-stat-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6L6 18M6 6l12 12"/></svg></div>
                            <div class="ga-stat-value"><asp:Label ID="lblRejectedReview" runat="server" Text="0" /></div>
                            <div class="ga-stat-label">Rejected</div>
                        </div>

                    </div>
                </div>

                <div class="ga-section">
                    <h2 class="ga-section-title">Manual document review</h2>
                    <div class="ga-stat-grid">
                        <div class="ga-stat c-purple">
                            <div class="ga-stat-value"><asp:Label ID="lblManualDocumentReviews" runat="server" Text="—" /></div>
                            <div class="ga-stat-label">Decisions recorded</div>
                        </div>
                        <div class="ga-stat c-navy">
                            <div class="ga-stat-value"><asp:Label ID="lblManualDocumentReviewsToday" runat="server" Text="—" /></div>
                            <div class="ga-stat-label">Decisions recorded today</div>
                        </div>
                    </div>
                    <div class="ga-card-sub">Officer document review only; these are not NIA IVSP verification results.</div>
                </div>

                <div class="ga-section">

                    <div class="ga-card">
                        <div class="ga-card-head">
                            <div>
                                <h2 class="ga-card-title">Application demand</h2>
                                <div class="ga-card-sub">By requested background-check purpose</div>
                            </div>
                            <span class="ga-tag">Live</span>
                        </div>
                        <div class="ga-card-body">
                            <div class="ga-purpose-grid">

                                <div class="ga-purpose-item">
                                    <div class="ga-purpose-top"><span class="ga-purpose-name">Employment</span><span class="ga-purpose-value"><asp:Label ID="lblEmployment" runat="server" Text="0" /></span></div>
                                    <div class="ga-track" style="margin-top:9px"><div id="barEmployment" runat="server" class="ga-fill"></div></div>
                                </div>

                                <div class="ga-purpose-item">
                                    <div class="ga-purpose-top"><span class="ga-purpose-name">Travel / Visa</span><span class="ga-purpose-value"><asp:Label ID="lblTravel" runat="server" Text="0" /></span></div>
                                    <div class="ga-track" style="margin-top:9px"><div id="barTravel" runat="server" class="ga-fill"></div></div>
                                </div>

                                <div class="ga-purpose-item">
                                    <div class="ga-purpose-top"><span class="ga-purpose-name">Education</span><span class="ga-purpose-value"><asp:Label ID="lblEducation" runat="server" Text="0" /></span></div>
                                    <div class="ga-track" style="margin-top:9px"><div id="barEducation" runat="server" class="ga-fill"></div></div>
                                </div>

                                <div class="ga-purpose-item">
                                    <div class="ga-purpose-top"><span class="ga-purpose-name">Other</span><span class="ga-purpose-value"><asp:Label ID="lblOther" runat="server" Text="0" /></span></div>
                                    <div class="ga-track" style="margin-top:9px"><div id="barOther" runat="server" class="ga-fill"></div></div>
                                </div>

                            </div>
                        </div>
                    </div>

                    <!--
                        Processing Health card removed from view per request.
                        The underlying controls are kept (hidden) below so the
                        existing code-behind (SetPercent calls) keeps working
                        without any changes to AdminDashboard.aspx.cs or
                        AdminDashboard.aspx.designer.cs.
                    -->
                    <div style="display:none" aria-hidden="true">
                        <div id="progressApproved" runat="server" class="ga-fill f-green"></div>
                        <asp:Label ID="lblApprovedPercent" runat="server" Text="0%" />
                        <div id="progressRejected" runat="server" class="ga-fill f-red"></div>
                        <asp:Label ID="lblRejectedPercent" runat="server" Text="0%" />
                        <div id="progressPending" runat="server" class="ga-fill f-amber"></div>
                        <asp:Label ID="lblPendingPercent" runat="server" Text="0%" />
                        <div id="progressPayment" runat="server" class="ga-fill"></div>
                        <asp:Label ID="lblPaymentPercent" runat="server" Text="0%" />
                    </div>

                </div>

                <div class="ga-section">
                    <div class="ga-card">
                        <div class="ga-card-head">
                            <div>
                                <h2 class="ga-card-title">Recent applications</h2>
                                <div class="ga-card-sub">Latest submissions</div>
                            </div>
                            <span class="ga-tag">Latest 5</span>
                        </div>
                        <div class="ga-card-body">
                            <asp:Repeater ID="rptRecentApplications" runat="server">
                                <ItemTemplate>
                                    <div class="ga-recent-row">
                                        <div>
                                            <div class="ga-recent-name"><%# Eval("FullName") %></div>
                                            <div class="ga-recent-meta"><%# Eval("DateSubmittedDisplay") %> &middot; <%# Eval("ApplicationDisplay") %></div>
                                        </div>
                                        <span class='ga-pill <%# GetStatusCss(Eval("Status")) %>'><%# Eval("StatusDisplay") %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>

                <div class="ga-section">
                    <div class="ga-card">
                        <div class="ga-card-head">
                            <div>
                                <h2 class="ga-card-title">National footprint</h2>
                                <div class="ga-card-sub">Applications by region from submitted GPS data</div>
                            </div>
                            <span class="ga-tag">16 regions</span>
                        </div>
                        <div class="ga-card-body">
                            <div class="ga-region-grid">
                                <asp:Repeater ID="rptRegions" runat="server">
                                    <ItemTemplate>
                                        <div class="ga-region">
                                            <div class="ga-region-name"><%# Eval("Region") %></div>
                                            <div class="ga-region-count"><%# Eval("Count") %></div>
                                            <div class="ga-region-share"><%# Eval("Share") %> of mapped</div>
                                            <div class="ga-region-line"><asp:Panel ID="pnlRegionFill" runat="server" CssClass="ga-region-fill" Width='<%# System.Web.UI.WebControls.Unit.Parse(System.Convert.ToString(Eval("HeatWidth")), System.Globalization.CultureInfo.InvariantCulture) %>' /></div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                    </div>
                </div>

            </div>


            <!-- ================= USERS PANEL ================= -->

            <div id="gaPanelUsers" class="ga-panel">
                <div class="ga-workspace-banner">
                    <div>
                        <div class="eyebrow">Account administration</div>
                        <h2>User accounts and access control</h2>
                        <p>Citizen, Officer and Admin accounts share one management and audit workspace. Select Officers in the role filter for the officer-only view.</p>
                    </div>
                    <div class="banner-note">All roles &middot; one audit trail</div>
                </div>
                <div class="ga-section">
                    <h2 class="ga-section-title">Unified user accounts</h2>
                    <div class="ga-card-sub" style="margin:-6px 0 12px">One workspace for the Citizen, Officer and Admin account lifecycle. Use the existing role filter to view officers only.</div>
                    <div class="ga-mini-grid">
                        <div class="ga-mini"><div class="num"><asp:Label ID="lblUsersTabTotal" runat="server" Text="0" /></div><div class="name">Total users</div></div>
                        <div class="ga-mini"><div class="num"><asp:Label ID="lblUsersTabCitizens" runat="server" Text="0" /></div><div class="name">Citizens</div></div>
                        <div class="ga-mini"><div class="num"><asp:Label ID="lblUsersTabOfficers" runat="server" Text="0" /></div><div class="name">Officers</div></div>
                        <div class="ga-mini"><div class="num"><asp:Label ID="lblUsersTabAdmins" runat="server" Text="0" /></div><div class="name">Administrators</div></div>
                    </div>
                </div>
                <uc:UserManagement ID="userManagement" runat="server" />
            </div>


            <!-- ================= APPLICATIONS PANEL ================= -->

            <div id="gaPanelApplications" class="ga-panel">

                <div class="ga-card">

                    <div class="ga-card-head">
                        <div>
                            <h2 class="ga-card-title">Application monitoring</h2>
                            <div class="ga-card-sub">Search, inspect and follow processing records</div>
                        </div>
                        <span class="ga-tag">Audit workspace</span>
                    </div>

                    <div class="ga-toolbar">
                        <div class="ga-filter-row">

                            <div class="ga-field">
                                <label>Applicant / reference / ID</label>
                                <asp:TextBox ID="txtAuditSearch" runat="server" CssClass="ga-input" />
                            </div>

                            <div class="ga-field">
                                <label>Status</label>
                                <asp:DropDownList ID="ddlAuditStatus" runat="server" CssClass="ga-select">
                                    <asp:ListItem Text="All statuses" Value="All" />
                                    <asp:ListItem Text="Pending review" Value="Pending" />
                                    <asp:ListItem Text="Approved" Value="Approved" />
                                    <asp:ListItem Text="Rejected" Value="Rejected" />
                                </asp:DropDownList>
                            </div>

                            <div class="ga-field">
                                <label>Purpose</label>
                                <asp:DropDownList ID="ddlAuditPurpose" runat="server" CssClass="ga-select">
                                    <asp:ListItem Text="All purposes" Value="All" />
                                    <asp:ListItem Text="Employment" Value="Employment" />
                                    <asp:ListItem Text="Travel / Visa" Value="Travel/Visa" />
                                    <asp:ListItem Text="Education" Value="Education Background" />
                                    <asp:ListItem Text="Other" Value="Other" />
                                </asp:DropDownList>
                            </div>

                            <div class="ga-field">
                                <label>Period</label>
                                <asp:DropDownList ID="ddlAuditPeriod" runat="server" CssClass="ga-select">
                                    <asp:ListItem Text="All time" Value="All" />
                                    <asp:ListItem Text="Today" Value="Today" />
                                    <asp:ListItem Text="Last 7 days" Value="7" />
                                    <asp:ListItem Text="Last 30 days" Value="30" />
                                    <asp:ListItem Text="Last 90 days" Value="90" />
                                </asp:DropDownList>
                            </div>

                            <asp:Button ID="btnAuditSearch" runat="server" Text="Search" CssClass="ga-btn ga-btn-primary" OnClick="btnAuditSearch_Click" />
                            <asp:Button ID="btnAuditClear" runat="server" Text="Clear" CssClass="ga-btn ga-btn-light" OnClick="btnAuditClear_Click" />

                        </div>
                    </div>

                    <div class="ga-table-wrap">
                        <asp:GridView ID="gvAudit" runat="server" AutoGenerateColumns="False" CssClass="ga-table" GridLines="None"
                            AllowPaging="True" PageSize="10"
                            OnPageIndexChanging="gvAudit_PageIndexChanging" OnRowCommand="gvAudit_RowCommand"
                            EmptyDataText="No application records match the selected filters.">
                            <Columns>
                                <asp:BoundField DataField="ApplicationDisplay" HeaderText="Application" />
                                <asp:BoundField DataField="FullName" HeaderText="Applicant" />
                                <asp:BoundField DataField="PurposeDisplay" HeaderText="Purpose" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate><span class='ga-pill <%# GetStatusCss(Eval("Status")) %>'><%# Eval("StatusDisplay") %></span></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="DateSubmittedDisplay" HeaderText="Submitted" />
                                <asp:BoundField DataField="ReviewedBy" HeaderText="Reviewed by" />
                                <asp:TemplateField HeaderText="">
                                    <ItemTemplate><asp:Button ID="btnInspect" runat="server" Text="Inspect" CssClass="ga-inspect" CommandName="Inspect" CommandArgument='<%# Eval("application_id") %>' /></ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataRowStyle CssClass="ga-pager" />
                            <PagerStyle CssClass="ga-pager" />
                        </asp:GridView>
                    </div>

                </div>

            </div>

            <div id="gaPanelActivity" class="ga-panel">
                <div class="ga-card">
                    <div class="ga-card-head">
                        <div>
                            <h2 class="ga-card-title">Account and application activity</h2>
                            <div class="ga-card-sub">Recorded actions, the staff account, affected item and timestamp</div>
                        </div>
                        <span class="ga-tag">Most recent 1,000</span>
                    </div>
                    <div class="ga-toolbar">
                        <div class="ga-filter-row">
                            <div class="ga-field">
                                <label>Search action, user or item</label>
                                <asp:TextBox ID="txtActivitySearch" runat="server" CssClass="ga-input" />
                            </div>
                            <div class="ga-field">
                                <label>Action</label>
                                <asp:DropDownList ID="ddlActivityAction" runat="server" CssClass="ga-select">
                                    <asp:ListItem Text="All actions" Value="All" />
                                    <asp:ListItem Text="Application submitted" Value="APPLICATION_SUBMITTED" />
                                    <asp:ListItem Text="Application approved" Value="APPLICATION_APPROVED" />
                                    <asp:ListItem Text="Application rejected" Value="APPLICATION_REJECTED" />
                                    <asp:ListItem Text="Document reviewed" Value="IDENTITY_DOCUMENT_REVIEWED" />
                                    <asp:ListItem Text="Document viewed" Value="APPLICATION_DOCUMENT_VIEWED" />
                                    <asp:ListItem Text="Password reset completed" Value="PASSWORD_RESET_COMPLETED" />
                                </asp:DropDownList>
                            </div>
                            <div class="ga-field">
                                <label>Period</label>
                                <asp:DropDownList ID="ddlActivityPeriod" runat="server" CssClass="ga-select">
                                    <asp:ListItem Text="All time" Value="All" />
                                    <asp:ListItem Text="Today" Value="Today" />
                                    <asp:ListItem Text="Last 7 days" Value="7" />
                                    <asp:ListItem Text="Last 30 days" Value="30" />
                                    <asp:ListItem Text="Last 90 days" Value="90" />
                                </asp:DropDownList>
                            </div>
                            <asp:Button ID="btnActivitySearch" runat="server" Text="Search"
                                CssClass="ga-btn ga-btn-primary" OnClick="btnActivitySearch_Click" />
                            <asp:Button ID="btnActivityClear" runat="server" Text="Clear"
                                CssClass="ga-btn ga-btn-light" OnClick="btnActivityClear_Click" />
                        </div>
                    </div>
                    <div class="ga-table-wrap">
                        <asp:GridView ID="gvActivityLog" runat="server"
                            AutoGenerateColumns="False" CssClass="ga-table" GridLines="None"
                            AllowPaging="True" PageSize="15"
                            OnPageIndexChanging="gvActivityLog_PageIndexChanging"
                            EmptyDataText="No activity matches these filters.">
                            <Columns>
                                <asp:BoundField DataField="ActionType" HeaderText="Action" />
                                <asp:BoundField DataField="ActorName" HeaderText="User" />
                                <asp:BoundField DataField="Details" HeaderText="Item / details" />
                                <asp:BoundField DataField="CreatedAtDisplay" HeaderText="Date and time" />
                            </Columns>
                            <EmptyDataRowStyle CssClass="ga-pager" />
                            <PagerStyle CssClass="ga-pager" />
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <div id="gaPanelOperations" class="ga-panel">
                <uc:AdminOperations ID="adminOperations" runat="server" />
            </div>
        </div>

    </div>

</div>

<!-- ================= INSPECTION DIALOG (read-only) ================= -->

<asp:Panel ID="pnlInspectModal" runat="server" Visible="false">
    <div class="ga-drawer-overlay">
        <div class="gd-dialog" role="dialog" aria-modal="true" aria-labelledby="gdTitle">

            <div class="gd-head">
                <div>
                    <div class="gd-kicker">Application inspection</div>
                    <h3 id="gdTitle"><asp:Label ID="lblInspectApplicationId" runat="server" /></h3>
                </div>
                <asp:Button ID="btnCloseModal" runat="server" Text="Close" CssClass="gd-close" OnClick="btnCloseModal_Click" CausesValidation="false" />
            </div>

            <nav class="gd-nav" aria-label="Inspection sections">
                <button type="button" data-gd-target="gdApplicant">Application profile</button>
                <button type="button" data-gd-target="gdManagement">Assignment</button>
                <button type="button" data-gd-target="gdDocuments">Documents</button>
                <button type="button" data-gd-target="gdReviews">Verification</button>
                <button type="button" data-gd-target="gdPayment">Payment</button>
                <button type="button" data-gd-target="gdHistory">Audit timeline</button>
                <button type="button" data-gd-target="gdIdentity">Identity details</button>
                <button type="button" data-gd-target="gdPurpose">Purpose</button>
                <button type="button" data-gd-target="gdComparison">Comparison</button>
                <button type="button" data-gd-target="gdDecision">Case outcome</button>
            </nav>

            <div class="gd-body" id="gdBody">
                <p class="gd-notice">Administrator view. Records are shown as stored; administrators can assign officers, set priority and request local review in the Management section. Final approval and rejection remain officer-only.</p>

                <section class="gd-section" id="gdApplicant" tabindex="-1" aria-labelledby="gdApplicant-h">
                    <h4 id="gdApplicant-h">Applicant and contact</h4>
                    <div class="gd-grid">
                        <dl class="gd-item"><dt>Applicant</dt><dd><asp:Label ID="lblInspectName" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Status</dt><dd><asp:Label ID="lblInspectStatus" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Gender</dt><dd><asp:Label ID="lblInspectGender" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Date of birth</dt><dd><asp:Label ID="lblInspectDob" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Marital status</dt><dd><asp:Label ID="lblInspectMaritalStatus" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Place of birth</dt><dd><asp:Label ID="lblInspectPlaceOfBirth" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Profession</dt><dd><asp:Label ID="lblInspectProfession" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Submitted</dt><dd><asp:Label ID="lblInspectSubmitted" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Email</dt><dd><asp:Label ID="lblInspectEmail" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Phone</dt><dd><asp:Label ID="lblInspectPhone" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Next of kin</dt><dd><asp:Label ID="lblInspectNextOfKinName" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Next of kin phone</dt><dd><asp:Label ID="lblInspectNextOfKinPhone" runat="server" /></dd></dl>
                        <dl class="gd-item full"><dt>GPS address</dt><dd><asp:Label ID="lblInspectGps" runat="server" /></dd></dl>
                    </div>
                </section>
                <section class="gd-section" id="gdIdentity" tabindex="-1" aria-labelledby="gdIdentity-h">
                    <h4 id="gdIdentity-h">Identity document</h4>
                    <div class="gd-grid">
                        <dl class="gd-item"><dt>ID type</dt><dd><asp:Label ID="lblInspectIdType" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>ID number</dt><dd><asp:Label ID="lblInspectId" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Issue date</dt><dd><asp:Label ID="lblInspectIdIssueDate" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Issue location</dt><dd><asp:Label ID="lblInspectIdIssueLocation" runat="server" /></dd></dl>
                    </div>
                </section>
                <section class="gd-section" id="gdPurpose" tabindex="-1" aria-labelledby="gdPurpose-h">
                    <h4 id="gdPurpose-h">Purpose of request</h4>
                    <div class="gd-grid">
                        <dl class="gd-item full"><dt>Purpose</dt><dd><asp:Label ID="lblInspectPurpose" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Employer</dt><dd><asp:Label ID="lblInspectEmployerName" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Position</dt><dd><asp:Label ID="lblInspectEmploymentPosition" runat="server" /></dd></dl>
                        <dl class="gd-item full"><dt>Employer address</dt><dd><asp:Label ID="lblInspectEmployerAddress" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Institution</dt><dd><asp:Label ID="lblInspectInstitutionName" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Programme</dt><dd><asp:Label ID="lblInspectProgrammeName" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Student ID</dt><dd><asp:Label ID="lblInspectStudentId" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Destination country</dt><dd><asp:Label ID="lblInspectDestinationCountry" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Visa type</dt><dd><asp:Label ID="lblInspectVisaType" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Travel date</dt><dd><asp:Label ID="lblInspectTravelDate" runat="server" /></dd></dl>
                        <dl class="gd-item full"><dt>Other purpose</dt><dd><asp:Label ID="lblInspectOtherPurpose" runat="server" /></dd></dl>
                    </div>
                </section>

                <section class="gd-section" id="gdDocuments" tabindex="-1" aria-labelledby="gdDocuments-h">
                    <h4 id="gdDocuments-h">Supporting documents</h4>
                    <p class="gd-meta">Status: <asp:Label ID="lblInspectDocumentsStatus" runat="server" /></p>
                    <div class="gd-doc-list">
                        <asp:Repeater ID="rptInspectDocuments" runat="server">
                            <ItemTemplate>
                                <a class="gd-doc" href='<%#: Eval("DocumentUrl") %>' target="_blank" rel="noopener noreferrer"><span><%#: Eval("DocumentName") %></span><em>Open file (new tab)</em></a>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </section>

                <section class="gd-section" id="gdReviews" tabindex="-1" aria-labelledby="gdReviews-h">
                    <h4 id="gdReviews-h">Officer review history by document</h4>
                    <div class="gd-table-wrap">
                        <asp:GridView ID="gvInspectDocumentReviews" runat="server" AutoGenerateColumns="false" CssClass="gd-table" GridLines="None"
                            EmptyDataText="No officer document reviews have been recorded for this application.">
                            <Columns>
                                <asp:BoundField DataField="DocumentType" HeaderText="Document" HtmlEncode="true" />
                                <asp:BoundField DataField="ReviewDecision" HeaderText="Decision" HtmlEncode="true" />
                                <asp:BoundField DataField="ReviewReason" HeaderText="Reason" HtmlEncode="true" />
                                <asp:BoundField DataField="ReviewerName" HeaderText="Reviewer" HtmlEncode="true" />
                                <asp:BoundField DataField="ReviewedAt" HeaderText="Reviewed at" HtmlEncode="true" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </section>

                <section class="gd-section" id="gdComparison" tabindex="-1" aria-labelledby="gdComparison-h">
                    <h4 id="gdComparison-h">Local record comparison</h4>
                    <p class="gd-meta">Compared against records held in this system only. This is not official NIA verification.</p>
                    <asp:HyperLink ID="hlInspectIdentityReview" runat="server" Text="Open local document review workspace" CssClass="po-link" />
                    <div class="gd-grid">
                        <dl class="gd-item full"><dt>Comparison result</dt><dd><asp:Label ID="lblInspectVerification" runat="server" /></dd></dl>
                    </div>
                </section>
                <section class="gd-section" id="gdDecision" tabindex="-1" aria-labelledby="gdDecision-h">
                    <h4 id="gdDecision-h">Final decision</h4>
                    <div class="gd-grid">
                        <dl class="gd-item"><dt>Reviewed by</dt><dd><asp:Label ID="lblInspectReviewedBy" runat="server" /></dd></dl>
                        <dl class="gd-item"><dt>Reviewed at</dt><dd><asp:Label ID="lblInspectReviewedAt" runat="server" /></dd></dl>
                        <dl class="gd-item full"><dt>Review notes</dt><dd><asp:Label ID="lblInspectReviewNotes" runat="server" /></dd></dl>
                        <dl class="gd-item full"><dt>Rejection reason</dt><dd><asp:Label ID="lblInspectRejectionReason" runat="server" /></dd></dl>
                    </div>
                </section>
                <section class="gd-section" id="gdManagement" tabindex="-1" aria-labelledby="gdManagement-h">
                    <h4 id="gdManagement-h">Assignment and priority management</h4>
                    <uc:ApplicationManagement ID="inspectManagement" runat="server" OnSaved="inspectManagement_Saved" />
                </section>
                <section class="gd-section" id="gdPayment" tabindex="-1" aria-labelledby="gdPayment-h">
                    <h4 id="gdPayment-h">Payment and certificate</h4>
                    <div class="gd-grid">
                        <dl class="gd-item full"><dt>Payment</dt><dd><asp:Label ID="lblInspectPayment" runat="server" /></dd></dl>
                        <dl class="gd-item full"><dt>Certificate</dt><dd><asp:Label ID="lblInspectCertificate" runat="server" /></dd></dl>
                    </div>
                </section>

                <section class="gd-section" id="gdHistory" tabindex="-1" aria-labelledby="gdHistory-h">
                    <h4 id="gdHistory-h">Audit timeline</h4>
                    <asp:Repeater ID="rptInspectTimeline" runat="server">
                        <ItemTemplate>
                            <div class="ga-timeline-item">
                                <strong><%#: Eval("EventType") %></strong>
                                <div><%#: Eval("EventText") %></div>
                                <div><%#: Eval("EventTimeDisplay") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </section>
            </div>

            <div class="gd-foot">Press Escape or Close to return to the list.</div>
        </div>
    </div>
</asp:Panel>


<script type="text/javascript">

    var gaPageInfo = {
        overview:     { title: 'Overview',     sub: 'Platform summary and recent activity' },
        users:        { title: 'User accounts',        sub: 'Citizen, Officer and Admin accounts in one workspace; filter by role to view officers only' },
        applications: { title: 'Applications', sub: 'Search and review all submitted applications' },
        activity:     { title: 'Activity log', sub: 'Recorded staff actions and affected records' },
        operations:   { title: 'Operations modules', sub: 'Existing-data administration and local document review' }
    };
    var gaModuleInfo = {
        applications:  { title: 'Application management', sub: 'Assign officers, set priority and track applications' },
        identity:      { title: 'Identity verification', sub: 'Local document review queue and identity outcomes' },
        officers:      { title: 'Officer management', sub: 'Officer records and staff profile details' },
        cases:         { title: 'Police reports and workflow', sub: 'Application outcomes, police reviews and recorded workflow history' },
        security:      { title: 'Security', sub: 'Security events, account locks and password resets' },
        analytics:     { title: 'Analytics and reporting', sub: 'Aggregated figures from database records' },
        notifications: { title: 'Notifications', sub: 'SMS submission and delivery tracking' },
        payments:      { title: 'Payments', sub: 'Payment statistics and records' }
    };

    function gaGetPageInfo(name = '') {
        switch (name) {
            case 'overview': return gaPageInfo.overview;
            case 'users': return gaPageInfo.users;
            case 'applications': return gaPageInfo.applications;
            case 'activity': return gaPageInfo.activity;
            case 'operations': return gaPageInfo.operations;
            default: return null;
        }
    }

    function gaGetModuleInfo(name = '') {
        switch (name) {
            case 'applications': return gaModuleInfo.applications;
            case 'identity': return gaModuleInfo.identity;
            case 'officers': return gaModuleInfo.officers;
            case 'cases': return gaModuleInfo.cases;
            case 'security': return gaModuleInfo.security;
            case 'analytics': return gaModuleInfo.analytics;
            case 'notifications': return gaModuleInfo.notifications;
            case 'payments': return gaModuleInfo.payments;
            default: return null;
        }
    }

    function gaCurrentModule() {
        try { var m = new URLSearchParams(window.location.search).get('module') || ''; return gaGetModuleInfo(m) ? m : 'applications'; } catch (ignore) { return 'applications'; }
    }

    function gaSwitchTab(name = 'overview', module = '') {
        if (name === 'operations' && !gaGetModuleInfo(module)) module = gaCurrentModule();

        var panels = document.querySelectorAll('.ga-panel');
        for (var i = 0; i < panels.length; i++) panels[i].classList.remove('active');

        var navItems = document.querySelectorAll('.ga-nav-item[data-nav]');
        for (var j = 0; j < navItems.length; j++) navItems[j].classList.remove('active');
        var modButtons = document.querySelectorAll('.ga-nav-item[data-module]');
        for (var k = 0; k < modButtons.length; k++) if (name === 'operations' && modButtons[k].getAttribute('data-module') === module) modButtons[k].classList.add('active');

        var panelId = 'gaPanel' + name.charAt(0).toUpperCase() + name.slice(1);
        var panel = document.getElementById(panelId);
        var button = name === 'operations' ? null : document.querySelector('.ga-nav-item[data-nav="' + name + '"]');
        if (panel) panel.classList.add('active');
        if (button) button.classList.add('active');

        var info = name === 'operations' ? gaGetModuleInfo(module) : gaGetPageInfo(name);
        if (info) {
            var pageTitle = document.getElementById('gaPageTitle');
            var pageSubtitle = document.getElementById('gaPageSubtitle');
            if (pageTitle) pageTitle.textContent = info.title;
            if (pageSubtitle) pageSubtitle.textContent = info.sub;
        }

        try {
            sessionStorage.setItem('gaActiveTab', name);
        } catch (ignore) { }

        if (window.history && window.history.replaceState) {
            var retained = '';
            var currentQuery = new URLSearchParams(window.location.search);
            if (name === 'operations' && module === 'applications' && currentQuery.get('module') === 'applications') {
                var keys = ['officer', 'assignment', 'priority', 'processing', 'assignTo'];
                for (var q = 0; q < keys.length; q++) {
                    var value = currentQuery.get(keys[q]);
                    if (value !== null) retained += '&' + keys[q] + '=' + encodeURIComponent(value);
                }
            } else if (name === 'operations' && module === 'identity' && currentQuery.get('module') === 'identity') {
                var reference = currentQuery.get('reference');
                if (reference !== null) retained += '&reference=' + encodeURIComponent(reference);
            } else if (name === 'users' && currentQuery.get('tab') === 'users') {
                var staff = currentQuery.get('staff');
                if (staff !== null) retained += '&staff=' + encodeURIComponent(staff);
            }
            window.history.replaceState(null, '', window.location.pathname + '?tab=' + encodeURIComponent(name) + (name === 'operations' ? '&module=' + encodeURIComponent(module) : '') + retained);
        }
    }

    function gaFitCertificateNavigation() {
        var sidebar = document.querySelector('.ga-sidebar');
        if (!(sidebar instanceof HTMLElement) || !document.getElementById('gaCertificateMonitoringLink')) return;
        // Keep the last workspace link reachable below the master header.
        // Preserve the existing horizontal navigation on smaller screens.
        sidebar.style.maxHeight = window.matchMedia('(max-width: 900px)').matches ? '' :
            Math.max(0, window.innerHeight - Math.max(0, sidebar.getBoundingClientRect().top)) + 'px';
    }

    (function () {

        const topSearch = document.getElementById('gaTopSearch');

        if (topSearch instanceof HTMLInputElement) {
            topSearch.addEventListener('keydown', function (event) {

                if (event.key !== 'Enter') return;

                event.preventDefault();

                var serverSearch = document.getElementById('<%= txtAuditSearch.ClientID %>');
                var searchButton = document.getElementById('<%= btnAuditSearch.ClientID %>');

                if (serverSearch instanceof HTMLInputElement)
                    serverSearch.value = topSearch.value;

                gaSwitchTab('applications');

                if (searchButton) searchButton.click();
            });
        }

        const overlay = document.querySelector('.ga-drawer-overlay');

        if (overlay instanceof HTMLElement) {

            const dlg = overlay.querySelector('.gd-dialog');
            var navBtns = overlay.querySelectorAll('[data-gd-target]');
            for (var n = 0; n < navBtns.length; n++) {
                navBtns[n].addEventListener('click', function (event) {
                    const navButton = event.currentTarget;
                    if (!(navButton instanceof HTMLElement)) return;
                    var target = document.getElementById(navButton.getAttribute('data-gd-target') || '');
                    if (target) { target.scrollIntoView({ block: 'start' }); target.focus({ preventScroll: true }); }
                });
            }
            var firstFocus = document.getElementById('<%= btnCloseModal.ClientID %>');
            if (firstFocus) firstFocus.focus();
            if (dlg instanceof HTMLElement) {
                dlg.addEventListener('keydown', function (event) {
                    if (event.key !== 'Tab') return;
                    var f = dlg.querySelectorAll('button, a[href], input, [tabindex="0"]');
                    if (!f.length) return;
                    var first = f[0], last = f[f.length - 1];
                    if (!(first instanceof HTMLElement) || !(last instanceof HTMLElement)) return;
                    if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
                    else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
                });
            }

            document.body.style.overflow = 'hidden';

            overlay.addEventListener('click', function (event) {
                if (event.target === overlay) {
                    var closeButton = document.getElementById('<%= btnCloseModal.ClientID %>');
                    if (closeButton) closeButton.click();
                }
            });

            document.addEventListener('keydown', function (event) {
                if (event.key === 'Escape') {
                    var closeButton = document.getElementById('<%= btnCloseModal.ClientID %>');
                    if (closeButton) closeButton.click();
                }
            });
        }

        var queryTab = '';
        try {
            queryTab = new URLSearchParams(window.location.search).get('tab') || '';
        } catch (ignore) { }

        var savedTab = '';
        try {
            savedTab = sessionStorage.getItem('gaActiveTab') || '';
        } catch (ignore) { }

        var initialTab = gaGetPageInfo(queryTab) ? queryTab :
            (savedTab !== 'operations' && gaGetPageInfo(savedTab) ? savedTab : 'overview');
        gaSwitchTab(initialTab);
        gaFitCertificateNavigation();
        window.addEventListener('resize', gaFitCertificateNavigation);
        window.addEventListener('scroll', gaFitCertificateNavigation, { passive: true });

    })();

</script>

</asp:Content>
