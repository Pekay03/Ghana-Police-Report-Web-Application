<%@ Page Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="PaymentMonitoring.aspx.cs"
    Inherits="PoliceBackgroundCheckSystem.PaymentMonitoring" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <style>
        .pm-page {
            max-width: 1400px;
            margin: 0 auto;
            padding: 30px 24px 50px;
            font-family: Segoe UI, Tahoma, sans-serif;
            color: #14213a;
        }

        .pm-hero {
            background: linear-gradient(135deg, #0b2447, #19376d);
            border-radius: 6px;
            padding: 30px;
            color: #ffffff;
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 24px;
            box-shadow: 0 16px 40px rgba(11,36,71,.18);
            margin-bottom: 24px;
        }

        .pm-eyebrow {
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.13em;
            text-transform: uppercase;
            color: #a9c1ea;
            margin-bottom: 9px;
        }

        .pm-hero h1 {
            margin: 0;
            font-size: 34px;
            line-height: 1.08;
            font-weight: 900;
        }

        .pm-hero p {
            margin: 10px 0 0;
            color: #d6e2f5;
            max-width: 680px;
            line-height: 1.6;
            font-size: 14px;
        }

        .pm-hero-meta {
            text-align: right;
            min-width: 180px;
        }

        .pm-hero-meta .label {
            font-size: 12px;
            color: #a9bde0;
        }

        .pm-hero-meta .value {
            font-size: 18px;
            font-weight: 800;
            margin-top: 4px;
        }

        .pm-error {
            display: block;
            margin-bottom: 15px;
            background: #e3ebf8;
            color: #0b2447;
            border: 1px solid #9fb3d3;
            padding: 12px 14px;
            border-radius: 12px;
        }

        .pm-kpis {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 14px;
            margin-bottom: 24px;
        }

        .pm-kpi {
            background: #ffffff;
            border: 1px solid #d9e1ee;
            border-radius: 18px;
            padding: 20px;
            box-shadow: 0 8px 24px rgba(11,36,71,.06);
        }

        .pm-kpi.primary {
            background: #eaf0f9;
            border-color: #c9d6ec;
        }

        .pm-kpi .label {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: #5b6b86;
            font-weight: 800;
        }

        .pm-kpi .value {
            font-size: 30px;
            font-weight: 900;
            margin-top: 8px;
        }

        .pm-kpi .sub {
            font-size: 12px;
            color: #5b6b86;
            margin-top: 5px;
        }

        .pm-toolbar {
            background: #ffffff;
            border: 1px solid #d9e1ee;
            border-radius: 18px;
            padding: 16px;
            display: grid;
            grid-template-columns: 1.4fr 1fr 1fr auto;
            gap: 12px;
            align-items: end;
            margin-bottom: 16px;
        }

        .pm-field label {
            display: block;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            color: #5b6b86;
            margin-bottom: 6px;
        }

        .pm-input,
        .pm-select {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #b8c6dd;
            border-radius: 11px;
            padding: 11px 12px;
            background: #f7f9fd;
            color: #14213a;
            font-family: inherit;
            font-size: 13px;
        }

        .pm-input:focus,
        .pm-select:focus {
            outline: none;
            border-color: #1d4f9c;
            box-shadow: 0 0 0 3px rgba(29,79,156,.14);
        }

        .pm-btn {
            border: 0;
            border-radius: 11px;
            padding: 11px 18px;
            background: #0b2447;
            color: #ffffff;
            font-weight: 800;
            cursor: pointer;
            font-family: inherit;
            white-space: nowrap;
        }

        .pm-btn:hover {
            background: #19376d;
        }

        .pm-table-wrap {
            background: #ffffff;
            border: 1px solid #d9e1ee;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 8px 24px rgba(11,36,71,.06);
        }

        .pm-table {
            width: 100%;
            border-collapse: collapse;
        }

        .pm-table th {
            background: #0b2447;
            color: #ffffff;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            text-align: left;
            padding: 14px 16px;
            border-bottom: 1px solid #d9e1ee;
            white-space: nowrap;
        }

        .pm-table td {
            padding: 15px 16px;
            border-bottom: 1px solid #dfe6f1;
            font-size: 13px;
            vertical-align: middle;
        }

        .pm-table tr:hover td {
            background: #eef3fa;
        }

        .pm-ref {
            font-weight: 850;
            color: #0b2447;
        }

        .pm-name {
            font-weight: 750;
        }

        .pm-pill {
            display: inline-flex;
            align-items: center;
            padding: 5px 9px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 850;
        }

        .pm-pill.verified {
            background: #0b2447;
            color: #ffffff;
        }

        .pm-pill.unverified {
            background: #fff;
            border: 1px solid #0b2447;
            color: #0b2447;
        }

        .pm-method {
            font-weight: 750;
        }

        .pm-amount {
            font-weight: 850;
        }

        .pm-action {
            display: inline-block;
            padding: 7px 11px;
            border: 1px solid #b8c6dd;
            border-radius: 9px;
            color: #0b2447;
            text-decoration: none;
            font-weight: 800;
            background: #ffffff;
            transition: all 0.15s ease;
        }

        .pm-action:hover {
            background: #e3ebf8;
            border-color: #7d99c6;
        }

        .pm-empty {
            padding: 45px;
            text-align: center;
            color: #5b6b86;
        }

        .pm-pager {
            padding: 15px 18px;
            text-align: center;
            background: #ffffff;
        }

        .pm-pager a,
        .pm-pager span {
            display: inline-block;
            margin: 0 3px;
            padding: 7px 11px;
            border: 1px solid #b8c6dd;
            border-radius: 9px;
            color: #0b2447;
            text-decoration: none;
            font-weight: 800;
            background: #ffffff;
        }

        .pm-pager span {
            background: #0b2447;
            color: #ffffff;
            border-color: #0b2447;
        }

        @media (max-width: 1050px) {
            .pm-kpis {
                grid-template-columns: 1fr 1fr;
            }

            .pm-toolbar {
                grid-template-columns: 1fr 1fr;
            }
        }

        @media (max-width: 700px) {
            .pm-page {
                padding: 20px 14px 35px;
            }

            .pm-hero {
                display: block;
            }

            .pm-hero-meta {
                text-align: left;
                margin-top: 20px;
            }

            .pm-kpis {
                grid-template-columns: 1fr;
            }

            .pm-toolbar {
                grid-template-columns: 1fr;
            }

            .pm-table-wrap {
                overflow-x: auto;
            }

            .pm-table {
                min-width: 900px;
            }
        }
    </style>

    <div class="pm-page">

        <section class="pm-hero">
            <div>
                <div class="pm-eyebrow">
                    Administrative Operations · Finance
                </div>

                <h1>Payment Monitoring</h1>

                <p>
                    Monitor application payments, transaction references,
                    payment methods and verification status from one
                    controlled administrative workspace.
                </p>
            </div>

            <div class="pm-hero-meta">
                <div class="label">
                    Administrative View
                </div>

                <div class="value">
                    Payment Operations
                </div>
            </div>
        </section>

        <asp:Label
            ID="lblError"
            runat="server"
            CssClass="pm-error"
            Visible="false">
        </asp:Label>

        <section class="pm-kpis">

            <div class="pm-kpi primary">
                <div class="label">
                    Total Payment Value
                </div>

                <div class="value">
                    GHS
                    <asp:Label
                        ID="lblTotalAmount"
                        runat="server"
                        Text="0.00">
                    </asp:Label>
                </div>

                <div class="sub">
                    Recorded payment transactions
                </div>
            </div>

            <div class="pm-kpi">
                <div class="label">
                    Transactions
                </div>

                <div class="value">
                    <asp:Label
                        ID="lblTotalPayments"
                        runat="server"
                        Text="0">
                    </asp:Label>
                </div>

                <div class="sub">
                    Payment records
                </div>
            </div>

            <div class="pm-kpi">
                <div class="label">
                    Verified
                </div>

                <div class="value">
                    <asp:Label
                        ID="lblVerifiedPayments"
                        runat="server"
                        Text="0">
                    </asp:Label>
                </div>

                <div class="sub">
                    Verified transactions
                </div>
            </div>

            <div class="pm-kpi">
                <div class="label">
                    Unverified
                </div>

                <div class="value">
                    <asp:Label
                        ID="lblUnverifiedPayments"
                        runat="server"
                        Text="0">
                    </asp:Label>
                </div>

                <div class="sub">
                    Requires attention
                </div>
            </div>

        </section>

        <section class="pm-toolbar">

            <div class="pm-field">
                <label>Search</label>

                <asp:TextBox
                    ID="txtSearch"
                    runat="server"
                    CssClass="pm-input"
                    placeholder="Application ID, transaction or applicant">
                </asp:TextBox>
            </div>

            <div class="pm-field">
                <label>Payment Method</label>

                <asp:DropDownList
                    ID="ddlMethod"
                    runat="server"
                    CssClass="pm-select">

                    <asp:ListItem
                        Text="All methods"
                        Value="">
                    </asp:ListItem>

                    <asp:ListItem
                        Text="MTN MoMo"
                        Value="MTN MoMo">
                    </asp:ListItem>

                    <asp:ListItem
                        Text="Telecel Cash"
                        Value="Telecel Cash">
                    </asp:ListItem>

                    <asp:ListItem
                        Text="AT Money"
                        Value="AT Money">
                    </asp:ListItem>

                </asp:DropDownList>
            </div>

            <div class="pm-field">
                <label>Verification</label>

                <asp:DropDownList
                    ID="ddlVerification"
                    runat="server"
                    CssClass="pm-select">

                    <asp:ListItem
                        Text="All statuses"
                        Value="">
                    </asp:ListItem>

                    <asp:ListItem
                        Text="Verified"
                        Value="1">
                    </asp:ListItem>

                    <asp:ListItem
                        Text="Unverified"
                        Value="0">
                    </asp:ListItem>

                </asp:DropDownList>
            </div>

            <asp:Button
                ID="btnFilter"
                runat="server"
                Text="Apply Filters"
                CssClass="pm-btn"
                OnClick="btnFilter_Click" />

        </section>

        <section class="pm-table-wrap">

            <asp:GridView
                ID="gvPayments"
                runat="server"
                AutoGenerateColumns="False"
                CssClass="pm-table"
                GridLines="None"
                AllowPaging="True"
                PageSize="10"
                OnPageIndexChanging="gvPayments_PageIndexChanging"
                EmptyDataText="No payment records match the current filters.">

                <Columns>

                    <asp:BoundField
                        DataField="application_id"
                        HeaderText="Application" />

                    <asp:BoundField
                        DataField="FullName"
                        HeaderText="Applicant" />

                    <asp:BoundField
                        DataField="PaymentMethod"
                        HeaderText="Method" />

                    <asp:BoundField
                        DataField="TransactionID"
                        HeaderText="Transaction" />

                    <asp:BoundField
                        DataField="AmountPaid"
                        HeaderText="Amount"
                        DataFormatString="GHS {0:N2}" />

                    <asp:BoundField
                        DataField="PaymentDate"
                        HeaderText="Payment Date"
                        DataFormatString="{0:dd MMM yyyy, HH:mm}" />

                    <asp:TemplateField HeaderText="Verification">
                        <ItemTemplate>
                            <span class='<%# (Convert.ToString(Eval("PaymentVerified")) == "1" || String.Equals(Convert.ToString(Eval("PaymentVerified")), "True", StringComparison.OrdinalIgnoreCase)) ? "pm-pill verified" : "pm-pill unverified" %>'>
                                <%# (Convert.ToString(Eval("PaymentVerified")) == "1" || String.Equals(Convert.ToString(Eval("PaymentVerified")), "True", StringComparison.OrdinalIgnoreCase)) ? "Verified" : "Unverified" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Inspect">
                        <ItemTemplate>
                            <a
                                class="pm-action"
                                href='<%# "VettingDetails.aspx?applicationId=" + Server.UrlEncode(Convert.ToString(Eval("application_id"))) %>'>
                                View
                            </a>
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>

                <EmptyDataRowStyle CssClass="pm-empty" />

                <PagerStyle CssClass="pm-pager" />

            </asp:GridView>

        </section>

    </div>

</asp:Content>