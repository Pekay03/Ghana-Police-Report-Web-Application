using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Net.Mail;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using PoliceBackgroundCheckSystem.Helpers;

namespace PoliceBackgroundCheckSystem
{
    public partial class UserManagement : UserControl
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAdmin())
            {
                Response.Redirect("~/Login.aspx");
            }

            if (!IsPostBack)
            {
                BindUsers();
                BindAccountAudit();
            }
        }

        protected void btnAddAccount_Click(object sender, EventArgs e)
        {
            ClearEditor();
            pnlEditor.Visible = true;
            lblFormNote.Text =
                "The initial password is temporary. The new user must reset it through phone verification after sign-in.";
        }

        internal void InspectAccount(int userId)
        {
            // Open the existing guarded editor; GET navigation never toggles account state.
            if (IsAdmin() && userId > 0)
            {
                ViewState["FocusedStaffAccount"] = userId;
                txtSearch.Text = "";
                BindUsers();
                LoadEditor(userId);
            }
        }

        protected void btnSaveAccount_Click(object sender, EventArgs e)
        {
            int editingUserId;
            bool editing = Int32.TryParse(hfUserId.Value, out editingUserId) &&
                editingUserId > 0;

            string firstName = txtFirstName.Text.Trim();
            string lastName = txtLastName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string rawPhone = txtPhone.Text.Trim();
            string phone = NormalizeGhanaPhone(rawPhone);
            string password = txtInitialPassword.Text;
            string role = ddlAccountRole.SelectedValue;
            int actorId = GetActorUserId();

            if (actorId <= 0)
            {
                ShowMessage("Your administrator session has expired. Sign in again.", false);
                return;
            }

            if (firstName.Length == 0 || lastName.Length == 0 ||
                email.Length == 0 || rawPhone.Length == 0)
            {
                ShowMessage("Complete the first name, last name, email, and phone fields.", false);
                return;
            }

            if (firstName.Length > 50 || lastName.Length > 50 ||
                email.Length > 100 || phone.Length > 20)
            {
                ShowMessage("One or more account fields exceed the allowed length.", false);
                return;
            }

            if (!ValidEmail(email))
            {
                ShowMessage("Enter a valid email address.", false);
                return;
            }

            if (String.IsNullOrEmpty(phone))
            {
                ShowMessage("Enter a valid Ghana mobile number, such as 0241234567 or +233241234567.", false);
                return;
            }

            if (!editing &&
                role != "Citizen" &&
                role != "Police Officer" &&
                role != "Administrator")
            {
                ShowMessage("Choose a valid account role.", false);
                return;
            }

            if (!editing && !IsStrongPassword(password))
            {
                ShowMessage(
                    "The temporary password must be at least 8 characters and include uppercase, lowercase, number, and symbol characters.",
                    false);
                return;
            }

            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(connectionString))
                {
                    connection.Open();

                    using (MySqlTransaction transaction = connection.BeginTransaction())
                    {
                        if (ContactAlreadyExists(
                            connection,
                            transaction,
                            email,
                            phone,
                            editing ? editingUserId : 0))
                        {
                            transaction.Rollback();
                            ShowMessage("That email address or phone number is already assigned to an account.", false);
                            return;
                        }

                        int targetUserId;
                        if (editing)
                        {
                            const string updateSql = @"
                                UPDATE users
                                SET FirstName = @FirstName,
                                    LastName = @LastName,
                                    Email = @Email,
                                    Phone = @Phone
                                WHERE UserID = @UserID
                                LIMIT 1;";

                            using (MySqlCommand command =
                                new MySqlCommand(updateSql, connection, transaction))
                            {
                                AddProfileParameters(command, firstName, lastName, email, phone);
                                command.Parameters.Add("@UserID", MySqlDbType.Int32).Value =
                                    editingUserId;

                                if (command.ExecuteNonQuery() != 1)
                                {
                                    transaction.Rollback();
                                    ShowMessage("The account was not found or no details were changed.", false);
                                    return;
                                }
                            }

                            targetUserId = editingUserId;
                            WriteAccountAudit(
                                connection,
                                transaction,
                                actorId,
                                targetUserId,
                                "PROFILE_UPDATED",
                                "Account contact details updated.");
                        }
                        else
                        {
                            const string insertSql = @"
                                INSERT INTO users
                                    (FirstName, LastName, Email, Phone, PhoneVerified, Password, Role,
                                     IsActive, FailedLoginAttempts, LockedUntil, MustChangePassword)
                                VALUES
                                    (@FirstName, @LastName, @Email, @Phone, 0, @Password, @Role,
                                     1, 0, NULL, 1);";

                            using (MySqlCommand command =
                                new MySqlCommand(insertSql, connection, transaction))
                            {
                                AddProfileParameters(command, firstName, lastName, email, phone);
                                command.Parameters.Add("@Password", MySqlDbType.VarChar, 255).Value =
                                    SecurityHelper.HashPassword(password);
                                command.Parameters.Add("@Role", MySqlDbType.VarChar, 30).Value = role;

                                command.ExecuteNonQuery();
                                targetUserId = Convert.ToInt32(
                                    command.LastInsertedId,
                                    CultureInfo.InvariantCulture);
                            }

                            WriteAccountAudit(
                                connection,
                                transaction,
                                actorId,
                                targetUserId,
                                "ACCOUNT_CREATED",
                                "Created " + role + " account.");
                        }

                        transaction.Commit();
                    }
                }

                ClearEditor();
                BindUsers();
                BindAccountAudit();
                ShowMessage(editing ? "Account details updated." : "Account created. Give the temporary password to the user through a secure channel.", true);
            }
            catch (MySqlException ex)
            {
                if (ex.Number == 1062)
                {
                    ShowMessage("The email address or phone number is already in use.", false);
                    return;
                }

                ShowSetupMessage();
            }
            catch
            {
                ShowSetupMessage();
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ClearEditor();
            lblMessage.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState.Remove("FocusedStaffAccount");
            gvUsers.PageIndex = 0;
            BindUsers();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ViewState.Remove("FocusedStaffAccount");
            txtSearch.Text = String.Empty;
            ddlRoleFilter.SelectedIndex = 0;
            gvUsers.PageIndex = 0;
            BindUsers();
        }

        protected void gvUsers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvUsers.PageIndex = e.NewPageIndex;
            BindUsers();
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int targetUserId;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out targetUserId) ||
                targetUserId <= 0)
            {
                ShowMessage("Invalid account ID.", false);
                return;
            }

            if (e.CommandName == "EditAccount")
            {
                LoadEditor(targetUserId);
                return;
            }

            int actorId = GetActorUserId();
            if (actorId <= 0)
            {
                ShowMessage("Your administrator session has expired. Sign in again.", false);
                return;
            }

            try
            {
                if (e.CommandName == "ToggleActive")
                    ToggleAccountStatus(actorId, targetUserId);
                else if (e.CommandName == "RequirePasswordReset")
                    RequirePasswordReset(actorId, targetUserId);
                else if (e.CommandName == "UnlockAccount")
                    UnlockAccount(actorId, targetUserId);
                else
                    return;

                BindUsers();
                BindAccountAudit();
            }
            catch
            {
                ShowSetupMessage();
            }
        }

        private void BindUsers()
        {
            const string sql = @"
                SELECT
                    UserID,
                    FirstName,
                    LastName,
                    Email,
                    Phone,
                    Role,
                    IsActive,
                    FailedLoginAttempts,
                    LockedUntil,
                    MustChangePassword,
                    CASE WHEN LockedUntil > NOW() THEN 1 ELSE 0 END AS IsCurrentlyLocked
                FROM users
                WHERE (@FocusedUser IS NULL OR UserID=@FocusedUser) AND
                    (@Search = '' OR
                     CAST(UserID AS CHAR) LIKE @LikeSearch OR
                     FirstName LIKE @LikeSearch OR
                     LastName LIKE @LikeSearch OR
                     Email LIKE @LikeSearch OR
                     Phone LIKE @LikeSearch)
                    AND
                    (
                        @Role = 'All'
                        OR (@Role = 'Citizens' AND LOWER(TRIM(COALESCE(Role,''))) = 'citizen')
                        OR (@Role = 'Officers' AND LOWER(REPLACE(REPLACE(REPLACE(TRIM(COALESCE(Role,'')), ' ', ''), '-', ''), '_', '')) IN
                            ('officer','policeofficer','vettingofficer','policeofficer/admin'))
                        OR (@Role = 'Admins' AND LOWER(REPLACE(REPLACE(REPLACE(TRIM(COALESCE(Role,'')), ' ', ''), '-', ''), '_', '')) IN
                            ('admin','administrator','systemadmin'))
                    )
                ORDER BY UserID DESC;";

            try
            {
                DataTable table = new DataTable();
                using (MySqlConnection connection =
                    new MySqlConnection(connectionString))
                using (MySqlCommand command = new MySqlCommand(sql, connection))
                {
                    string search = txtSearch.Text.Trim();
                    command.Parameters.Add("@Search", MySqlDbType.VarChar, 120).Value = search;
                    command.Parameters.Add("@FocusedUser", MySqlDbType.Int32).Value =
                        ViewState["FocusedStaffAccount"] ?? DBNull.Value;
                    command.Parameters.Add("@LikeSearch", MySqlDbType.VarChar, 250).Value =
                        "%" + search + "%";
                    command.Parameters.Add("@Role", MySqlDbType.VarChar, 20).Value =
                        ddlRoleFilter.SelectedValue;

                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(command))
                        adapter.Fill(table);
                }

                table.Columns.Add("FullName", typeof(string));
                table.Columns.Add("LockStatus", typeof(string));
                table.Columns.Add("HasLock", typeof(bool));

                foreach (DataRow row in table.Rows)
                {
                    row["FullName"] =
                        (Convert.ToString(row["FirstName"]) + " " +
                         Convert.ToString(row["LastName"])).Trim();

                    int failedAttempts = Convert.ToInt32(row["FailedLoginAttempts"]);
                    bool isLocked = Convert.ToBoolean(row["IsCurrentlyLocked"]);

                    row["HasLock"] = isLocked || failedAttempts > 0;
                    row["LockStatus"] = isLocked
                        ? "Temporarily locked"
                        : failedAttempts > 0
                            ? failedAttempts.ToString(CultureInfo.InvariantCulture) + " failed attempts"
                                : Convert.ToBoolean(row["MustChangePassword"])
                                ? "Reset required"
                                : "Normal";
                }

                lblUserCount.Text = table.Rows.Count.ToString("N0") + " account(s)";
                lblSetupWarning.Visible = false;
                gvUsers.DataSource = table;
                gvUsers.DataBind();
            }
            catch
            {
                gvUsers.DataSource = null;
                gvUsers.DataBind();
                ShowSetupMessage();
            }
        }

        private void BindAccountAudit()
        {
            const string sql = @"
                SELECT AuditID, ActorUserID, TargetUserID, ActionType, Details, CreatedAt
                FROM account_audit_logs
                ORDER BY AuditID DESC
                LIMIT 20;";

            try
            {
                DataTable table = new DataTable();
                using (MySqlConnection connection =
                    new MySqlConnection(connectionString))
                using (MySqlCommand command = new MySqlCommand(sql, connection))
                using (MySqlDataAdapter adapter = new MySqlDataAdapter(command))
                    adapter.Fill(table);

                table.Columns.Add("CreatedAtDisplay", typeof(string));
                foreach (DataRow row in table.Rows)
                {
                    row["CreatedAtDisplay"] =
                        Convert.ToDateTime(row["CreatedAt"])
                            .ToString("dd MMM yyyy, HH:mm", CultureInfo.CurrentCulture);
                }

                gvAccountAudit.DataSource = table;
                gvAccountAudit.DataBind();
            }
            catch
            {
                gvAccountAudit.DataSource = null;
                gvAccountAudit.DataBind();
                ShowSetupMessage();
            }
        }

        private void LoadEditor(int userId)
        {
            const string sql = @"
                SELECT UserID, FirstName, LastName, Email, Phone, Role
                FROM users
                WHERE UserID = @UserID
                LIMIT 1;";

            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(connectionString))
                using (MySqlCommand command = new MySqlCommand(sql, connection))
                {
                    command.Parameters.Add("@UserID", MySqlDbType.Int32).Value = userId;
                    connection.Open();

                    using (MySqlDataReader reader = command.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            ShowMessage("Account was not found.", false);
                            return;
                        }

                        hfUserId.Value = Convert.ToString(reader["UserID"]);
                        txtFirstName.Text = Convert.ToString(reader["FirstName"]);
                        txtLastName.Text = Convert.ToString(reader["LastName"]);
                        txtEmail.Text = Convert.ToString(reader["Email"]);
                        txtPhone.Text = Convert.ToString(reader["Phone"]);

                        string currentRole = Convert.ToString(reader["Role"]);
                        ListItem roleItem =
                            ddlAccountRole.Items.FindByValue(currentRole);

                        if (roleItem == null)
                        {
                            roleItem = new ListItem(currentRole, currentRole);
                            ddlAccountRole.Items.Add(roleItem);
                        }

                        ddlAccountRole.ClearSelection();
                        roleItem.Selected = true;
                    }
                }

                pnlEditor.Visible = true;
                pnlInitialPassword.Visible = false;
                ddlAccountRole.Enabled = false;
                litFormTitle.Text = "Edit account";
                btnSaveAccount.Text = "Save changes";
                lblFormNote.Text = "Role and password cannot be changed here. Use the account actions to require a secure password reset.";
                ShowMessage("Editing account #" + userId.ToString(CultureInfo.InvariantCulture) + ".", true);
            }
            catch
            {
                ShowSetupMessage();
            }
        }

        private void ToggleAccountStatus(int actorId, int targetUserId)
        {
            using (MySqlConnection connection =
                new MySqlConnection(connectionString))
            {
                connection.Open();
                using (MySqlTransaction transaction = connection.BeginTransaction())
                {
                    bool currentlyActive;
                    string role;

                    const string selectSql = @"
                        SELECT IsActive, Role
                        FROM users
                        WHERE UserID = @UserID
                        LIMIT 1
                        FOR UPDATE;";

                    using (MySqlCommand select = new MySqlCommand(selectSql, connection, transaction))
                    {
                        select.Parameters.Add("@UserID", MySqlDbType.Int32).Value = targetUserId;
                        using (MySqlDataReader reader = select.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                transaction.Rollback();
                                ShowMessage("Account was not found.", false);
                                return;
                            }

                            currentlyActive = Convert.ToBoolean(reader["IsActive"]);
                            role = Convert.ToString(reader["Role"]);
                        }
                    }

                    bool activate = !currentlyActive;
                    if (!activate && actorId == targetUserId)
                    {
                        transaction.Rollback();
                        ShowMessage("You cannot deactivate your own administrator account.", false);
                        return;
                    }

                    if (!activate && IsAdministratorRole(role) &&
                        CountOtherActiveAdministrators(connection, transaction, targetUserId) == 0)
                    {
                        transaction.Rollback();
                        ShowMessage("The last active administrator cannot be deactivated.", false);
                        return;
                    }

                    const string updateSql = @"
                        UPDATE users
                        SET IsActive = @IsActive,
                            FailedLoginAttempts = 0,
                            LockedUntil = NULL
                        WHERE UserID = @UserID;";

                    using (MySqlCommand update = new MySqlCommand(updateSql, connection, transaction))
                    {
                        update.Parameters.Add("@IsActive", MySqlDbType.Bit).Value = activate;
                        update.Parameters.Add("@UserID", MySqlDbType.Int32).Value = targetUserId;
                        if (update.ExecuteNonQuery() != 1)
                        {
                            transaction.Rollback();
                            ShowMessage("Account status could not be changed.", false);
                            return;
                        }
                    }

                    WriteAccountAudit(
                        connection,
                        transaction,
                        actorId,
                        targetUserId,
                        activate ? "ACCOUNT_ACTIVATED" : "ACCOUNT_DEACTIVATED",
                        activate ? "Account activated." : "Account deactivated.");

                    transaction.Commit();
                    ShowMessage(activate ? "Account activated." : "Account deactivated.", true);
                }
            }
        }

        private void RequirePasswordReset(int actorId, int targetUserId)
        {
            using (MySqlConnection connection =
                new MySqlConnection(connectionString))
            {
                connection.Open();
                using (MySqlTransaction transaction = connection.BeginTransaction())
                {
                    const string sql = @"
                        UPDATE users
                        SET MustChangePassword = 1
                        WHERE UserID = @UserID;";

                    using (MySqlCommand command = new MySqlCommand(sql, connection, transaction))
                    {
                        command.Parameters.Add("@UserID", MySqlDbType.Int32).Value = targetUserId;
                        if (command.ExecuteNonQuery() != 1)
                        {
                            transaction.Rollback();
                            ShowMessage("Account was not found.", false);
                            return;
                        }
                    }

                    WriteAccountAudit(
                        connection,
                        transaction,
                        actorId,
                        targetUserId,
                        "PASSWORD_RESET_REQUIRED",
                        "User must complete phone verification and choose a new password.");

                    transaction.Commit();
                    ShowMessage("Password reset required at the user's next sign-in.", true);
                }
            }
        }

        private void UnlockAccount(int actorId, int targetUserId)
        {
            using (MySqlConnection connection =
                new MySqlConnection(connectionString))
            {
                connection.Open();
                using (MySqlTransaction transaction = connection.BeginTransaction())
                {
                    const string sql = @"
                        UPDATE users
                        SET FailedLoginAttempts = 0,
                            LockedUntil = NULL
                        WHERE UserID = @UserID;";

                    using (MySqlCommand command = new MySqlCommand(sql, connection, transaction))
                    {
                        command.Parameters.Add("@UserID", MySqlDbType.Int32).Value = targetUserId;
                        if (command.ExecuteNonQuery() != 1)
                        {
                            transaction.Rollback();
                            ShowMessage("Account was not found.", false);
                            return;
                        }
                    }

                    WriteAccountAudit(
                        connection,
                        transaction,
                        actorId,
                        targetUserId,
                        "ACCOUNT_UNLOCKED",
                        "Failed sign-in counter and temporary lock were cleared.");

                    transaction.Commit();
                    ShowMessage("Account unlocked.", true);
                }
            }
        }

        private int CountOtherActiveAdministrators(
            MySqlConnection connection,
            MySqlTransaction transaction,
            int targetUserId)
        {
            const string sql = @"
                SELECT COUNT(*)
                FROM users
                WHERE IsActive = 1
                  AND UserID <> @UserID
                  AND LOWER(REPLACE(REPLACE(REPLACE(TRIM(COALESCE(Role,'')), ' ', ''), '-', ''), '_', '')) IN
                      ('admin','administrator','systemadmin');";

            using (MySqlCommand command = new MySqlCommand(sql, connection, transaction))
            {
                command.Parameters.Add("@UserID", MySqlDbType.Int32).Value = targetUserId;
                return Convert.ToInt32(command.ExecuteScalar());
            }
        }

        private void WriteAccountAudit(
            MySqlConnection connection,
            MySqlTransaction transaction,
            int actorUserId,
            int targetUserId,
            string actionType,
            string details)
        {
            const string sql = @"
                INSERT INTO account_audit_logs
                    (ActorUserID, TargetUserID, ActionType, Details)
                VALUES
                    (@ActorUserID, @TargetUserID, @ActionType, @Details);";

            using (MySqlCommand command = new MySqlCommand(sql, connection, transaction))
            {
                command.Parameters.Add("@ActorUserID", MySqlDbType.Int32).Value = actorUserId;
                command.Parameters.Add("@TargetUserID", MySqlDbType.Int32).Value = targetUserId;
                command.Parameters.Add("@ActionType", MySqlDbType.VarChar, 40).Value = actionType;
                command.Parameters.Add("@Details", MySqlDbType.VarChar, 300).Value =
                    String.IsNullOrWhiteSpace(details) ? (object)DBNull.Value : details;
                command.ExecuteNonQuery();
            }
        }

        private bool ContactAlreadyExists(
            MySqlConnection connection,
            MySqlTransaction transaction,
            string email,
            string phone,
            int excludedUserId)
        {
            const string sql = @"
                SELECT COUNT(*)
                FROM users
                WHERE (
                        LOWER(TRIM(Email)) = LOWER(TRIM(@Email))
                        OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                               TRIM(COALESCE(Phone, '')), ' ', ''), '-', ''), '(', ''),
                               ')', ''), '+', ''), '.', '') IN
                           (@LocalPhone, @InternationalPhone)
                      )
                  AND (@ExcludedUserID = 0 OR UserID <> @ExcludedUserID);";

            using (MySqlCommand command = new MySqlCommand(sql, connection, transaction))
            {
                command.Parameters.Add("@Email", MySqlDbType.VarChar, 100).Value = email;
                string normalizedPhone = NormalizeGhanaPhone(phone);
                command.Parameters.Add("@LocalPhone", MySqlDbType.VarChar, 20).Value =
                    normalizedPhone;
                command.Parameters.Add("@InternationalPhone", MySqlDbType.VarChar, 20).Value =
                    "233" + normalizedPhone.Substring(1);
                command.Parameters.Add("@ExcludedUserID", MySqlDbType.Int32).Value = excludedUserId;
                return Convert.ToInt32(command.ExecuteScalar()) > 0;
            }
        }

        private static void AddProfileParameters(
            MySqlCommand command,
            string firstName,
            string lastName,
            string email,
            string phone)
        {
            command.Parameters.Add("@FirstName", MySqlDbType.VarChar, 50).Value = firstName;
            command.Parameters.Add("@LastName", MySqlDbType.VarChar, 50).Value = lastName;
            command.Parameters.Add("@Email", MySqlDbType.VarChar, 100).Value = email;
            command.Parameters.Add("@Phone", MySqlDbType.VarChar, 20).Value = phone;
        }

        private void ClearEditor()
        {
            hfUserId.Value = String.Empty;
            txtFirstName.Text = String.Empty;
            txtLastName.Text = String.Empty;
            txtEmail.Text = String.Empty;
            txtPhone.Text = String.Empty;
            txtInitialPassword.Text = String.Empty;
            ddlAccountRole.Enabled = true;
            ddlAccountRole.ClearSelection();
            ddlAccountRole.SelectedIndex = 0;
            pnlInitialPassword.Visible = true;
            pnlEditor.Visible = false;
            litFormTitle.Text = "Add account";
            btnSaveAccount.Text = "Create account";
            lblFormNote.Text = String.Empty;
        }

        private void ShowSetupMessage()
        {
            lblSetupWarning.Text =
                "Account management is not ready. Back up the database, then run DatabaseMigration.sql against PoliceReportDB.";
            lblSetupWarning.Visible = true;
            ShowMessage("The account operation could not be completed.", false);
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = success
                ? "um-message um-success"
                : "um-message um-error";
            lblMessage.Visible = true;
        }

        private bool IsAdmin()
        {
            int actor;
            string name;
            return StaffAccess.TryUser(Context, true, out actor, out name);
        }

        private static bool IsAdministratorRole(string role)
        {
            role = NormalizeRole(role);
            return role.Equals("Admin", StringComparison.OrdinalIgnoreCase) ||
                role.Equals("Administrator", StringComparison.OrdinalIgnoreCase) ||
                role.Equals("SystemAdmin", StringComparison.OrdinalIgnoreCase);
        }

        private static string NormalizeRole(string role)
        {
            return (role ?? String.Empty)
                .Trim()
                .Replace(" ", String.Empty)
                .Replace("-", String.Empty)
                .Replace("_", String.Empty);
        }

        private int GetActorUserId()
        {
            int userId;
            string name;
            return StaffAccess.TryUser(Context, true, out userId, out name) ? userId : 0;
        }

        private static bool ValidEmail(string email)
        {
            try
            {
                return new MailAddress(email).Address.Equals(
                    email,
                    StringComparison.OrdinalIgnoreCase);
            }
            catch
            {
                return false;
            }
        }

        private static string NormalizeGhanaPhone(string phone)
        {
            if (String.IsNullOrWhiteSpace(phone))
                return String.Empty;

            phone = phone.Trim()
                .Replace(" ", String.Empty)
                .Replace("-", String.Empty)
                .Replace("(", String.Empty)
                .Replace(")", String.Empty);

            if (Regex.IsMatch(phone, @"^0(2[0-9]|5[0-9])[0-9]{7}$"))
                return phone;

            if (Regex.IsMatch(phone, @"^\+233(2[0-9]|5[0-9])[0-9]{7}$"))
                return "0" + phone.Substring(4);

            if (Regex.IsMatch(phone, @"^233(2[0-9]|5[0-9])[0-9]{7}$"))
                return "0" + phone.Substring(3);

            return String.Empty;
        }

        private static bool IsStrongPassword(string password)
        {
            return !String.IsNullOrEmpty(password) &&
                password.Length >= 8 &&
                Regex.IsMatch(password, "[A-Z]") &&
                Regex.IsMatch(password, "[a-z]") &&
                Regex.IsMatch(password, "[0-9]") &&
                Regex.IsMatch(password, "[^A-Za-z0-9]");
        }
    }
}