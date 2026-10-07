<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserManagement.ascx.cs" Inherits="PoliceBackgroundCheckSystem.UserManagement" %>

<div class="ga-card um-card">
    <div class="ga-card-head um-card-head">
        <div>
            <h2 class="ga-card-title">Account management</h2>
            <div class="ga-card-sub">Create and manage citizens, officers, and administrators in one directory.</div>
        </div>
        <asp:Button ID="btnAddAccount" runat="server" Text="Add account"
            CssClass="ga-btn ga-btn-primary" OnClick="btnAddAccount_Click" CausesValidation="false" />
    </div>

    <asp:Label ID="lblSetupWarning" runat="server" CssClass="um-setup-warning"
        Visible="false" />
    <asp:Label ID="lblMessage" runat="server" CssClass="um-message"
        Visible="false" />

    <asp:Panel ID="pnlEditor" runat="server" CssClass="um-editor" Visible="false">
        <div class="um-editor-heading">
            <div>
                <div class="um-kicker">Account details</div>
                <h3><asp:Literal ID="litFormTitle" runat="server" Text="Add account" /></h3>
            </div>
            <asp:HiddenField ID="hfUserId" runat="server" />
        </div>

        <div class="um-form-grid">
            <div class="ga-field">
                <label for="<%= txtFirstName.ClientID %>">First name</label>
                <asp:TextBox ID="txtFirstName" runat="server" CssClass="ga-input" MaxLength="50" />
            </div>
            <div class="ga-field">
                <label for="<%= txtLastName.ClientID %>">Last name</label>
                <asp:TextBox ID="txtLastName" runat="server" CssClass="ga-input" MaxLength="50" />
            </div>
            <div class="ga-field">
                <label for="<%= txtEmail.ClientID %>">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="ga-input"
                    TextMode="Email" MaxLength="100" />
            </div>
            <div class="ga-field">
                <label for="<%= txtPhone.ClientID %>">Phone</label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="ga-input"
                    TextMode="Phone" MaxLength="20" />
            </div>
            <div class="ga-field">
                <label for="<%= ddlAccountRole.ClientID %>">Role</label>
                <asp:DropDownList ID="ddlAccountRole" runat="server" CssClass="ga-select">
                    <asp:ListItem Text="Citizen" Value="Citizen" />
                    <asp:ListItem Text="Police officer" Value="Police Officer" />
                    <asp:ListItem Text="Administrator" Value="Administrator" />
                </asp:DropDownList>
            </div>
            <asp:Panel ID="pnlInitialPassword" runat="server" CssClass="ga-field um-password-field">
                <label for="<%= txtInitialPassword.ClientID %>">Temporary password</label>
                <asp:TextBox ID="txtInitialPassword" runat="server" CssClass="ga-input"
                    TextMode="Password" MaxLength="128" autocomplete="new-password" />
            </asp:Panel>
        </div>

        <asp:Label ID="lblFormNote" runat="server" CssClass="um-form-note" />
        <div class="um-editor-actions">
            <asp:Button ID="btnSaveAccount" runat="server" Text="Create account"
                CssClass="ga-btn ga-btn-primary" OnClick="btnSaveAccount_Click" />
            <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel"
                CssClass="ga-btn ga-btn-light" OnClick="btnCancelEdit_Click"
                CausesValidation="false" />
        </div>
    </asp:Panel>

    <div class="ga-toolbar um-toolbar">
        <div class="ga-filter-row">
            <div class="ga-field">
                <label for="<%= ddlRoleFilter.ClientID %>">Role</label>
                <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="ga-select">
                    <asp:ListItem Text="All roles" Value="All" />
                    <asp:ListItem Text="Citizens" Value="Citizens" />
                    <asp:ListItem Text="Officers" Value="Officers" />
                    <asp:ListItem Text="Administrators" Value="Admins" />
                </asp:DropDownList>
            </div>
            <div class="ga-field um-search-field">
                <label for="<%= txtSearch.ClientID %>">Search accounts</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="ga-input"
                    MaxLength="120" />
            </div>
            <asp:Button ID="btnSearch" runat="server" Text="Search"
                CssClass="ga-btn ga-btn-primary" OnClick="btnSearch_Click" />
            <asp:Button ID="btnClear" runat="server" Text="Clear"
                CssClass="ga-btn ga-btn-light" OnClick="btnClear_Click" CausesValidation="false" />
        </div>
        <asp:Label ID="lblUserCount" runat="server" CssClass="um-result-count" />
    </div>

    <div class="ga-table-wrap um-table-wrap">
        <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False"
            DataKeyNames="UserID" CssClass="ga-table um-table" GridLines="None"
            AllowPaging="True" PageSize="10"
            OnPageIndexChanging="gvUsers_PageIndexChanging"
            OnRowCommand="gvUsers_RowCommand"
            EmptyDataText="No accounts match these filters.">
            <Columns>
                <asp:BoundField DataField="UserID" HeaderText="ID" />
                <asp:TemplateField HeaderText="Account">
                    <ItemTemplate>
                        <strong><%# Server.HtmlEncode(Convert.ToString(Eval("FullName"))) %></strong>
                        <span class="um-account-email"><%# Server.HtmlEncode(Convert.ToString(Eval("Email"))) %></span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="Phone" HeaderText="Phone" HtmlEncode="true" />
                <asp:BoundField DataField="Role" HeaderText="Role" HtmlEncode="true" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <asp:Label ID="lblAccountStatus" runat="server"
                            CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "um-pill um-active" : "um-pill um-inactive" %>'
                            Text='<%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Deactivated" %>' />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="LockStatus" HeaderText="Sign-in" HtmlEncode="true" />
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <div class="um-row-actions">
                            <asp:Button ID="btnEditAccount" runat="server" Text="Edit"
                                CssClass="um-action" CommandName="EditAccount"
                                CommandArgument='<%# Eval("UserID") %>' CausesValidation="false" />
                            <asp:Button ID="btnToggleActive" runat="server"
                                Text='<%# Convert.ToBoolean(Eval("IsActive")) ? "Deactivate" : "Activate" %>'
                                CssClass="um-action" CommandName="ToggleActive"
                                CommandArgument='<%# Eval("UserID") %>' CausesValidation="false"
                                OnClientClick="return confirm('Change this account status?');" />
                            <asp:Button ID="btnRequireReset" runat="server" Text="Require reset"
                                CssClass="um-action" CommandName="RequirePasswordReset"
                                CommandArgument='<%# Eval("UserID") %>' CausesValidation="false"
                                OnClientClick="return confirm('Require this user to reset their password at next sign-in?');" />
                            <asp:Button ID="btnUnlock" runat="server" Text="Unlock"
                                CssClass="um-action" CommandName="UnlockAccount"
                                CommandArgument='<%# Eval("UserID") %>' CausesValidation="false"
                                Enabled='<%# Convert.ToBoolean(Eval("HasLock")) %>' />
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataRowStyle CssClass="ga-pager" />
            <PagerStyle CssClass="ga-pager" />
        </asp:GridView>
    </div>
</div>

<div class="ga-card um-audit-card">
    <div class="ga-card-head">
        <div>
            <h2 class="ga-card-title">Account activity</h2>
            <div class="ga-card-sub">One chronological audit trail for account changes across all roles.</div>
        </div>
        <span class="ga-tag">Latest 20 actions</span>
    </div>
    <div class="ga-table-wrap um-table-wrap">
        <asp:GridView ID="gvAccountAudit" runat="server" AutoGenerateColumns="False"
            CssClass="ga-table um-table" GridLines="None"
            EmptyDataText="No account changes have been recorded.">
            <Columns>
                <asp:BoundField DataField="CreatedAtDisplay" HeaderText="When" HtmlEncode="true" />
                <asp:BoundField DataField="ActionType" HeaderText="Action" HtmlEncode="true" />
                <asp:BoundField DataField="ActorUserID" HeaderText="Admin ID" />
                <asp:BoundField DataField="TargetUserID" HeaderText="Account ID" />
                <asp:BoundField DataField="Details" HeaderText="Details" HtmlEncode="true" />
            </Columns>
        </asp:GridView>
    </div>
</div>