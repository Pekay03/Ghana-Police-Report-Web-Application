using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net.Mail;
using System.Text.RegularExpressions;
using MySql.Data.MySqlClient;
using PoliceBackgroundCheckSystem.Helpers;

namespace PoliceBackgroundCheckSystem
{
    public static class DatabaseHelper
    {
        public static string NormalizeGhanaPhone(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone))
                return string.Empty;

            phone = phone.Trim().Replace(" ", "").Replace("-", "");

            if (Regex.IsMatch(phone, @"^0(2[0-9]|5[0-9])[0-9]{7}$"))
                return phone;

            if (Regex.IsMatch(phone, @"^\+233(2[0-9]|5[0-9])[0-9]{7}$"))
                return "0" + phone.Substring(4);

            if (Regex.IsMatch(phone, @"^233(2[0-9]|5[0-9])[0-9]{7}$"))
                return "0" + phone.Substring(3);

            return string.Empty;
        }

        // ============================================================
        // DATABASE CONNECTION
        // ============================================================

        // Explicit opt-in, direct loopback requests only. A missing/false
        // setting or a remote request always leaves public signup citizen-only.
        public static bool IsLocalAssessmentRoleSignupEnabled()
        {
#if DEBUG
            bool enabled;
            if (!Boolean.TryParse(
                ConfigurationManager.AppSettings["EnableLocalAssessmentRoleSignup"],
                out enabled) || !enabled)
                return false;

            System.Web.HttpContext context = System.Web.HttpContext.Current;
            if (context == null || !context.Request.IsLocal ||
                context.Request.Url == null || !context.Request.Url.IsLoopback)
                return false;

            // Reject every X-Forwarded-* header, not just selected variants.
            // An ordinary direct IIS Express localhost request has none of these.
            foreach (string header in context.Request.Headers.AllKeys)
            {
                if (header != null &&
                    (header.Equals("Forwarded", StringComparison.OrdinalIgnoreCase) ||
                     header.StartsWith("X-Forwarded-", StringComparison.OrdinalIgnoreCase) ||
                     header.Equals("X-Real-IP", StringComparison.OrdinalIgnoreCase) ||
                     header.Equals("Via", StringComparison.OrdinalIgnoreCase)))
                    return false;
            }

            return true;
#else
            // Release builds never expose privileged self-registration.
            return false;
#endif
        }

        private static string ConnectionString
        {
            get
            {
                ConnectionStringSettings settings =
                    ConfigurationManager.ConnectionStrings["PoliceReportDB"];

                if (settings == null ||
                    string.IsNullOrWhiteSpace(settings.ConnectionString))
                    throw new ConfigurationErrorsException(
                        "PoliceReportDB is missing from connectionStrings.");

                MySqlConnectionStringBuilder builder =
                    new MySqlConnectionStringBuilder(settings.ConnectionString);

                if (string.IsNullOrWhiteSpace(builder.Server) ||
                    string.IsNullOrWhiteSpace(builder.Database) ||
                    string.IsNullOrWhiteSpace(builder.UserID) ||
                    IsDatabasePlaceholder(builder.Server) ||
                    IsDatabasePlaceholder(builder.Database) ||
                    IsDatabasePlaceholder(builder.UserID) ||
                    IsDatabasePlaceholder(builder.Password))
                    throw new ConfigurationErrorsException(
                        "PoliceReportDB contains incomplete database settings.");

                return settings.ConnectionString;
            }
        }

        private static bool IsDatabasePlaceholder(string value)
        {
            string normalized = (value ?? string.Empty).Trim();
            return normalized.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase) ||
                normalized.StartsWith("REPLACE_", StringComparison.OrdinalIgnoreCase) ||
                normalized.StartsWith("__REQUIRED_", StringComparison.OrdinalIgnoreCase) ||
                normalized.Equals("SET_LOCALLY", StringComparison.OrdinalIgnoreCase);
        }

        private static string AccountFailureMessage(Exception error, string operation)
        {
            MySqlException databaseError = error as MySqlException;
            System.Diagnostics.Trace.TraceError(
                "{0} failed ({1}; MySQL error {2}).",
                operation,
                error.GetType().Name,
                databaseError == null ? 0 : databaseError.Number);

            // Never send connection strings, exception messages, SQL or
            // credential values to a visitor. Local IIS Express development
            // gets safe setup categories and an error number, not raw details.
            System.Web.HttpContext context = System.Web.HttpContext.Current;
            if (context == null || !context.Request.IsLocal)
                return operation + " is temporarily unavailable. Contact the project administrator.";

            if (error is ConfigurationErrorsException || error is ArgumentException)
                return "Local database setup is incomplete or invalid. Enter your private MySQL " +
                    "username and password in Web.Local.config beside Web.config. " +
                    "The local server and pbcswa_db database are already specified. " +
                    "Do not share that file or change the SQL schema.";

            if (error is System.IO.FileNotFoundException ||
                error is System.IO.FileLoadException ||
                error is TypeLoadException ||
                error is TypeInitializationException)
                return "A required database/runtime component could not load (" +
                    error.GetType().Name + "). Restore NuGet packages and rebuild the solution. " +
                    "Keep the existing package versions.";

            if (databaseError != null)
            {
                switch (databaseError.Number)
                {
                    case 1044:
                    case 1045:
                        return "MySQL rejected the database account or its permissions. " +
                            "Check the private account values in Web.Local.config against the account used for pbcswa_db.";
                    case 1049:
                        return "The configured MySQL database was not found. " +
                            "Check that pbcswa_db exists on the local MySQL server configured in Web.Local.config.";
                    case 1054:
                    case 1146:
                        return "The connected database does not match the supplied users schema " +
                            "(MySQL error " + databaseError.Number + "). " +
                            "Check that PoliceReportDB points to the existing pbcswa_db database. " +
                            "Do not import or migrate data to test this correction.";
                    case 0:
                        return "MySQL could not complete the operation (client error 0). " +
                            "Check the server and PoliceReportDB settings, then check the " +
                            "exception type in Visual Studio's Output window.";
                    case 1042:
                    case 2002:
                    case 2003:
                        return "The MySQL server could not be reached (MySQL error " +
                            databaseError.Number + "). Start your MySQL/MariaDB service and " +
                            "check the host and port in PoliceReportDB.";
                    case 1048:
                    case 1364:
                    case 1406:
                        return "MySQL could not save the account fields (MySQL error " +
                            databaseError.Number + "). Check the users table's required fields, " +
                            "column lengths and UserID auto-increment against your existing schema.";
                    default:
                        return operation + " failed (MySQL error " + databaseError.Number +
                            "). Use this number when checking Visual Studio's Output window; " +
                            "do not share passwords or the connection string.";
                }
            }

            return operation + " failed (" + error.GetType().Name +
                "). Check this exception type in Visual Studio's Output window. " +
                "Do not share passwords or the connection string.";
        }


        // ============================================================
        // TEST DATABASE CONNECTION
        // ============================================================

        public static bool TestConnection(out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    connection.Open();

                    return true;
                }
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Database connection test failed (MySQL error {0}).",
                    ex.Number);
                errorMessage = "The database connection is unavailable.";

                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Database connection test failed ({0}).",
                    ex.GetType().Name);
                errorMessage = "The database connection is unavailable.";

                return false;
            }
        }


        // ============================================================
        // AUTHENTICATE USER
        // LOGIN USING EMAIL + PASSWORD
        // ============================================================

        public static UserAccount AuthenticateUser(
            string email,
            string password,
            out string errorMessage)
        {
            errorMessage = string.Empty;

            if (string.IsNullOrWhiteSpace(email))
            {
                errorMessage =
                    "Please enter your email address.";

                return null;
            }

            if (string.IsNullOrEmpty(password))
            {
                errorMessage =
                    "Please enter your password.";

                return null;
            }


            const string query = @"
                SELECT
                    UserID,
                    FirstName,
                    LastName,
                    Email,
                    Phone,
                    PhoneVerified,
                    Password,
                    Role,
                    IsActive,
                    FailedLoginAttempts,
                    LockedUntil,
                    MustChangePassword,
                    CASE WHEN LockedUntil > NOW() THEN 1 ELSE 0 END AS IsCurrentlyLocked
                FROM users
                WHERE LOWER(TRIM(Email)) =
                      LOWER(TRIM(@Email))
                LIMIT 1;";

            try
            {
                UserAccount user;
                string storedPassword;
                bool isCurrentlyLocked;

                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    connection.Open();

                    using (MySqlCommand command =
                        new MySqlCommand(
                            query,
                            connection))
                    {
                        command.Parameters.Add(
                            "@Email",
                            MySqlDbType.VarChar,
                            100
                        ).Value = email.Trim();


                        using (MySqlDataReader reader =
                            command.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                errorMessage = "Email or password is incorrect.";
                                return null;
                            }

                            user = ReadUser(reader);
                            user.IsActive =
                                Convert.ToBoolean(reader["IsActive"]);
                            user.FailedLoginAttempts =
                                Convert.ToInt32(reader["FailedLoginAttempts"]);
                            user.PasswordResetRequired =
                                Convert.ToBoolean(reader["MustChangePassword"]);
                            isCurrentlyLocked =
                                Convert.ToBoolean(reader["IsCurrentlyLocked"]);
                            user.LockedUntil =
                                reader["LockedUntil"] == DBNull.Value
                                    ? (DateTime?)null
                                    : Convert.ToDateTime(reader["LockedUntil"]);
                            storedPassword = Convert.ToString(reader["Password"]);
                        }
                    }
                }

                if (!user.IsActive)
                {
                    errorMessage = "This account is inactive. Contact an administrator.";
                    return null;
                }

                if (isCurrentlyLocked)
                {
                    errorMessage =
                        "This account is temporarily locked. Try again later or contact an administrator.";
                    return null;
                }

                if (!SecurityHelper.VerifyPassword(password, storedPassword))
                {
                    RecordFailedLogin(user.UserID);
                    errorMessage = "Email or password is incorrect.";
                    return null;
                }

                string upgradedPassword = SecurityHelper.NeedsRehash(storedPassword)
                    ? SecurityHelper.HashPassword(password)
                    : null;

                ResetLoginState(user.UserID, upgradedPassword);

                // Do not keep the credential material on the returned account object.
                user.Password = null;
                return user;
            }
            catch (Exception ex)
            {
                errorMessage = AccountFailureMessage(ex, "Sign-in");
                return null;
            }
        }


        // ============================================================
        // REGISTER USER
        // ============================================================

        public static bool RegisterUser(
            UserAccount user,
            out string errorMessage)
        {
            errorMessage = string.Empty;


            if (user == null)
            {
                errorMessage =
                    "User information is required.";

                return false;
            }


            if (string.IsNullOrWhiteSpace(user.FirstName))
            {
                errorMessage =
                    "First name is required.";

                return false;
            }


            if (string.IsNullOrWhiteSpace(user.Email))
            {
                errorMessage =
                    "Email address is required.";

                return false;
            }

            if (user.FirstName.Trim().Length > 50 ||
                (user.LastName ?? string.Empty).Trim().Length > 50 ||
                user.Email.Trim().Length > 100)
            {
                errorMessage =
                    "First and last names must each be at most 50 characters, " +
                    "and the email address at most 100 characters.";
                return false;
            }


            string normalizedPhone = NormalizeGhanaPhone(user.Phone);
            if (String.IsNullOrWhiteSpace(normalizedPhone))
            {
                errorMessage =
                    "A valid Ghana mobile number is required.";

                return false;
            }

            user.Phone = normalizedPhone;


            if (string.IsNullOrWhiteSpace(user.Password))
            {
                errorMessage =
                    "Password is required.";

                return false;
            }


            if (string.IsNullOrWhiteSpace(user.Role))
            {
                errorMessage =
                    "Account type is required.";

                return false;
            }

            string requestedRole = user.Role.Trim();
            bool citizen = requestedRole.Equals(
                "Citizen", StringComparison.OrdinalIgnoreCase);
            bool assessmentStaff =
                IsLocalAssessmentRoleSignupEnabled() &&
                (requestedRole.Equals("Police Officer", StringComparison.OrdinalIgnoreCase) ||
                 requestedRole.Equals("Administrator", StringComparison.OrdinalIgnoreCase));

            if (!citizen && !assessmentStaff)
            {
                errorMessage =
                    "Staff self-registration is available only in explicitly enabled " +
                    "local assessment mode. Otherwise an administrator must create the account.";

                return false;
            }

            // Store the canonical values expected by the dashboard checks.
            user.Role = citizen ? "Citizen" :
                (requestedRole.Equals("Police Officer", StringComparison.OrdinalIgnoreCase)
                    ? "Police Officer" : "Administrator");


            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    connection.Open();


                    // ====================================================
                    // CHECK EMAIL
                    // ====================================================

                    const string emailCheck = @"
                        SELECT COUNT(*)
                        FROM users
                        WHERE LOWER(TRIM(Email)) =
                              LOWER(TRIM(@Email));";


                    using (MySqlCommand emailCommand =
                        new MySqlCommand(
                            emailCheck,
                            connection))
                    {
                        emailCommand.Parameters.Add(
                            "@Email",
                            MySqlDbType.VarChar,
                            100
                        ).Value = user.Email.Trim();


                        int emailCount =
                            Convert.ToInt32(
                                emailCommand.ExecuteScalar());


                        if (emailCount > 0)
                        {
                            errorMessage =
                                "An account with this email address already exists.";

                            return false;
                        }
                    }


                    // ====================================================
                    // CHECK PHONE
                    // ====================================================

                    const string phoneCheck = @"
                        SELECT COUNT(*)
                        FROM users
                        WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                                  TRIM(COALESCE(Phone, '')), ' ', ''), '-', ''), '(', ''),
                                  ')', ''), '+', ''), '.', '') IN
                              (@LocalPhone, @InternationalPhone);";


                    using (MySqlCommand phoneCommand =
                        new MySqlCommand(
                            phoneCheck,
                            connection))
                    {
                        phoneCommand.Parameters.Add(
                            "@LocalPhone",
                            MySqlDbType.VarChar,
                            20
                        ).Value = user.Phone;

                        phoneCommand.Parameters.Add(
                            "@InternationalPhone",
                            MySqlDbType.VarChar,
                            20
                        ).Value = "233" + user.Phone.Substring(1);


                        int phoneCount =
                            Convert.ToInt32(
                                phoneCommand.ExecuteScalar());


                        if (phoneCount > 0)
                        {
                            errorMessage =
                                "An account with this phone number already exists.";

                            return false;
                        }
                    }


                    // ====================================================
                    // INSERT USER
                    // ====================================================

                    const string insertQuery = @"
                        INSERT INTO users
                        (
                            FirstName,
                            LastName,
                            Email,
                            Phone,
                            PhoneVerified,
                            Password,
                            Role,
                            IsActive,
                            FailedLoginAttempts,
                            LockedUntil,
                            MustChangePassword
                        )
                        VALUES
                        (
                            @FirstName,
                            @LastName,
                            @Email,
                            @Phone,
                            @PhoneVerified,
                            @Password,
                            @Role,
                            1,
                            0,
                            NULL,
                            0
                        );";


                    using (MySqlCommand insertCommand =
                        new MySqlCommand(
                            insertQuery,
                            connection))
                    {
                        insertCommand.Parameters.Add(
                            "@FirstName",
                            MySqlDbType.VarChar,
                            50
                        ).Value =
                            user.FirstName.Trim();


                        insertCommand.Parameters.Add(
                            "@LastName",
                            MySqlDbType.VarChar,
                            50
                        ).Value =
                            string.IsNullOrWhiteSpace(
                                user.LastName)
                                ? ""
                                : user.LastName.Trim();


                        insertCommand.Parameters.Add(
                            "@Email",
                            MySqlDbType.VarChar,
                            100
                        ).Value =
                            user.Email.Trim();


                        insertCommand.Parameters.Add(
                            "@Phone",
                            MySqlDbType.VarChar,
                            20
                        ).Value =
                            user.Phone.Trim();


                        // Match users.PhoneVerified (tinyint); registration
                        // does not claim that the phone has been verified.
                        insertCommand.Parameters.Add(
                            "@PhoneVerified",
                            MySqlDbType.Byte
                        ).Value = 0;


                        insertCommand.Parameters.Add(
                            "@Password",
                            MySqlDbType.VarChar,
                            255
                        ).Value =
                            SecurityHelper.HashPassword(user.Password);


                        insertCommand.Parameters.Add(
                            "@Role",
                            MySqlDbType.VarChar,
                            20
                        ).Value =
                            user.Role.Trim();


                        int rows =
                            insertCommand.ExecuteNonQuery();


                        if (rows == 1)
                        {
                            user.UserID = checked((int)insertCommand.LastInsertedId);
                            return true;
                        }


                        errorMessage =
                            "The account could not be created.";

                        return false;
                    }
                }
            }
            catch (MySqlException ex)
            {
                if (ex.Number == 1062)
                {
                    errorMessage =
                        "An account with this email or phone number already exists.";

                    return false;
                }


                errorMessage = AccountFailureMessage(ex, "Account registration");

                return false;
            }
            catch (Exception ex)
            {
                errorMessage = AccountFailureMessage(ex, "Account registration");

                return false;
            }
        }


        // ============================================================
        // GET USER BY EMAIL
        // ============================================================

        public static bool IsAccountActive(int userId)
        {
            if (userId <= 0)
                return false;

            const string query = @"
                SELECT IsActive
                FROM users
                WHERE UserID = @UserID
                LIMIT 1;";

            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                using (MySqlCommand command =
                    new MySqlCommand(query, connection))
                {
                    command.Parameters.Add(
                        "@UserID",
                        MySqlDbType.Int32).Value = userId;

                    connection.Open();
                    object result = command.ExecuteScalar();
                    return result != null &&
                        result != DBNull.Value &&
                        Convert.ToBoolean(result);
                }
            }
            catch
            {
                // Fail closed if account status cannot be verified.
                return false;
            }
        }

        private static void RecordFailedLogin(int userId)
        {
            const string query = @"
                UPDATE users
                SET LockedUntil =
                        CASE
                            WHEN COALESCE(FailedLoginAttempts, 0) >= 4
                            THEN DATE_ADD(NOW(), INTERVAL 15 MINUTE)
                            ELSE LockedUntil
                        END,
                    FailedLoginAttempts = COALESCE(FailedLoginAttempts, 0) + 1
                WHERE UserID = @UserID;";

            using (MySqlConnection connection =
                new MySqlConnection(ConnectionString))
            using (MySqlCommand command =
                new MySqlCommand(query, connection))
            {
                command.Parameters.Add(
                    "@UserID",
                    MySqlDbType.Int32).Value = userId;

                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        private static void ResetLoginState(int userId, string upgradedPassword)
        {
            string query = string.IsNullOrEmpty(upgradedPassword)
                ? @"UPDATE users
                    SET FailedLoginAttempts = 0, LockedUntil = NULL
                    WHERE UserID = @UserID;"
                : @"UPDATE users
                    SET Password = @Password,
                        FailedLoginAttempts = 0,
                        LockedUntil = NULL
                    WHERE UserID = @UserID;";

            using (MySqlConnection connection =
                new MySqlConnection(ConnectionString))
            using (MySqlCommand command =
                new MySqlCommand(query, connection))
            {
                command.Parameters.Add(
                    "@UserID",
                    MySqlDbType.Int32).Value = userId;

                if (!string.IsNullOrEmpty(upgradedPassword))
                {
                    command.Parameters.Add(
                        "@Password",
                        MySqlDbType.VarChar,
                        255).Value = upgradedPassword;
                }

                connection.Open();
                command.ExecuteNonQuery();
            }
        }

        public static UserAccount GetUser(
            string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return null;
            }


            const string query = @"
                SELECT
                    UserID,
                    FirstName,
                    LastName,
                    Email,
                    Phone,
                    PhoneVerified,
                    Password,
                    Role,
                    IsActive
                FROM users
                WHERE LOWER(TRIM(Email)) =
                      LOWER(TRIM(@Email))
                LIMIT 1;";


            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command =
                        new MySqlCommand(
                            query,
                            connection))
                    {
                        command.Parameters.Add(
                            "@Email",
                            MySqlDbType.VarChar,
                            100
                        ).Value =
                            email.Trim();


                        connection.Open();


                        using (MySqlDataReader reader =
                            command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                UserAccount user = ReadUser(reader);
                                user.IsActive = Convert.ToBoolean(reader["IsActive"]);
                                user.Password = null;
                                return user;
                            }
                        }
                    }
                }
            }
            catch
            {
                return null;
            }


            return null;
        }

        public static bool TryCreatePasswordResetRequest(
            int userId,
            out long requestId)
        {
            requestId = 0;
            if (userId <= 0)
                return false;

            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    connection.Open();
                    using (MySqlTransaction transaction = connection.BeginTransaction())
                    {
                        const string lockAccountSql = @"
                            SELECT IsActive
                            FROM users
                            WHERE UserID = @UserID
                            LIMIT 1
                            FOR UPDATE;";

                        object activeValue;
                        using (MySqlCommand command =
                            new MySqlCommand(lockAccountSql, connection, transaction))
                        {
                            command.Parameters.Add("@UserID", MySqlDbType.Int32).Value = userId;
                            activeValue = command.ExecuteScalar();
                        }

                        if (activeValue == null ||
                            activeValue == DBNull.Value ||
                            !Convert.ToBoolean(activeValue))
                        {
                            transaction.Rollback();
                            return false;
                        }

                        const string rateLimitSql = @"
                            SELECT
                                COUNT(*) AS RecentCount,
                                COALESCE(
                                    MAX(RequestedAt) > DATE_SUB(NOW(), INTERVAL 1 MINUTE),
                                    0
                                ) AS InCooldown
                            FROM password_reset_requests
                            WHERE UserID = @UserID
                              AND RequestedAt >= DATE_SUB(NOW(), INTERVAL 1 DAY);";

                        bool rateLimitReached;
                        using (MySqlCommand command =
                            new MySqlCommand(rateLimitSql, connection, transaction))
                        {
                            command.Parameters.Add("@UserID", MySqlDbType.Int32).Value = userId;
                            using (MySqlDataReader reader = command.ExecuteReader())
                            {
                                rateLimitReached =
                                    !reader.Read() ||
                                    Convert.ToInt32(reader["RecentCount"]) >= 5 ||
                                    Convert.ToBoolean(reader["InCooldown"]);
                            }
                        }

                        if (rateLimitReached)
                        {
                            transaction.Rollback();
                            return false;
                        }

                        const string insertSql = @"
                            INSERT INTO password_reset_requests
                                (UserID, RequestedAt, Status, RequestSource)
                            VALUES
                                (@UserID, NOW(), 'PENDING', 'HUBTEL_SMS');";

                        using (MySqlCommand command =
                            new MySqlCommand(insertSql, connection, transaction))
                        {
                            command.Parameters.Add("@UserID", MySqlDbType.Int32).Value = userId;
                            command.ExecuteNonQuery();
                            requestId = command.LastInsertedId;
                        }

                        transaction.Commit();
                        return requestId > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Password-reset request could not be recorded ({0}).",
                    ex.GetType().Name);
                return false;
            }
        }

        public static bool SetPasswordResetRequestDeliveryStatus(
            long requestId,
            bool sent)
        {
            if (requestId <= 0)
                return false;

            const string query = @"
                UPDATE password_reset_requests
                SET Status = @Status,
                    ProcessedAt = CASE WHEN @Sent = 1 THEN NULL ELSE NOW() END
                WHERE ResetRequestID = @RequestID;";

            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                using (MySqlCommand command =
                    new MySqlCommand(query, connection))
                {
                    command.Parameters.Add("@Status", MySqlDbType.VarChar, 20).Value =
                        sent ? "SENT" : "FAILED";
                    command.Parameters.Add("@Sent", MySqlDbType.Bit).Value = sent;
                    command.Parameters.Add("@RequestID", MySqlDbType.Int64).Value = requestId;
                    connection.Open();
                    return command.ExecuteNonQuery() == 1;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Password-reset delivery status could not be recorded ({0}).",
                    ex.GetType().Name);
                return false;
            }
        }

        public static bool CompletePasswordResetRequest(long requestId)
        {
            if (requestId <= 0)
                return false;

            const string query = @"
                UPDATE password_reset_requests
                SET Status = 'COMPLETED',
                    ProcessedAt = NOW()
                WHERE ResetRequestID = @RequestID
                  AND Status = 'SENT';";

            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                using (MySqlCommand command =
                    new MySqlCommand(query, connection))
                {
                    command.Parameters.Add("@RequestID", MySqlDbType.Int64).Value = requestId;
                    connection.Open();
                    return command.ExecuteNonQuery() == 1;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Password-reset completion could not be recorded ({0}).",
                    ex.GetType().Name);
                return false;
            }
        }


        // ============================================================
        // GET USER BY PHONE
        // USED BY FORGOT PASSWORD
        // ============================================================

        public static UserAccount GetUserByPhone(
            string phone)
        {
            if (string.IsNullOrWhiteSpace(phone))
            {
                return null;
            }


            const string query = @"
                SELECT
                    UserID,
                    FirstName,
                    LastName,
                    Email,
                    Phone,
                    Role,
                    IsActive
                FROM users
                WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                          TRIM(COALESCE(Phone, '')), ' ', ''), '-', ''), '(', ''),
                          ')', ''), '+', ''), '.', '') IN
                      (@LocalPhone, @InternationalPhone)
                LIMIT 1;";

            string normalizedPhone = NormalizeGhanaPhone(phone);
            if (String.IsNullOrEmpty(normalizedPhone))
                return null;


            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command =
                        new MySqlCommand(
                            query,
                            connection))
                    {
                        command.Parameters.Add(
                            "@LocalPhone",
                            MySqlDbType.VarChar,
                            20
                        ).Value = normalizedPhone;

                        command.Parameters.Add(
                            "@InternationalPhone",
                            MySqlDbType.VarChar,
                            20
                        ).Value = "233" + normalizedPhone.Substring(1);


                        connection.Open();


                        using (MySqlDataReader reader =
                            command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new UserAccount
                                {
                                    UserID = Convert.ToInt32(reader["UserID"]),
                                    FirstName = Convert.ToString(reader["FirstName"]),
                                    LastName = Convert.ToString(reader["LastName"]),
                                    Email = Convert.ToString(reader["Email"]),
                                    Phone = Convert.ToString(reader["Phone"]),
                                    Role = Convert.ToString(reader["Role"]),
                                    IsActive = Convert.ToBoolean(reader["IsActive"])
                                };
                            }
                        }
                    }
                }
            }
            catch
            {
                return null;
            }


            return null;
        }


        // ============================================================
        // UPDATE PASSWORD
        // USED BY RESET PASSWORD
        // ============================================================

        public static bool UpdatePassword(
            string email,
            string newPassword,
            out string errorMessage)
        {
            errorMessage = string.Empty;


            if (string.IsNullOrWhiteSpace(email))
            {
                errorMessage =
                    "Account information is missing.";

                return false;
            }


            if (string.IsNullOrEmpty(newPassword))
            {
                errorMessage =
                    "New password is required.";

                return false;
            }


            const string query = @"
                UPDATE users
                SET Password = @Password,
                    MustChangePassword = 0,
                    FailedLoginAttempts = 0,
                    LockedUntil = NULL
                WHERE LOWER(TRIM(Email)) =
                      LOWER(TRIM(@Email))
                  AND IsActive = 1
                LIMIT 1;";


            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    connection.Open();

                    using (MySqlTransaction transaction =
                        connection.BeginTransaction())
                    {
                        int rows;
                        using (MySqlCommand command =
                            new MySqlCommand(query, connection, transaction))
                        {
                            command.Parameters.Add(
                                "@Password",
                                MySqlDbType.VarChar,
                                255
                            ).Value = SecurityHelper.HashPassword(newPassword);

                            command.Parameters.Add(
                                "@Email",
                                MySqlDbType.VarChar,
                                100
                            ).Value = email.Trim();

                            rows = command.ExecuteNonQuery();
                        }

                        if (rows != 1)
                        {
                            transaction.Rollback();
                            errorMessage =
                                "No account was found for this password reset.";
                            return false;
                        }
                        int userId;
                        const string selectUserId = @"
                            SELECT UserID
                            FROM users
                            WHERE LOWER(TRIM(Email)) = LOWER(TRIM(@Email))
                            LIMIT 1;";

                        using (MySqlCommand command =
                            new MySqlCommand(selectUserId, connection, transaction))
                        {
                            command.Parameters.Add(
                                "@Email",
                                MySqlDbType.VarChar,
                                100
                            ).Value = email.Trim();

                            object result = command.ExecuteScalar();
                            if (result == null || result == DBNull.Value)
                            {
                                transaction.Rollback();
                                errorMessage = "The password reset could not be recorded.";
                                return false;
                            }

                            userId = Convert.ToInt32(result);
                        }

                        const string auditSql = @"
                            INSERT INTO account_audit_logs
                                (ActorUserID, TargetUserID, ActionType, Details)
                            VALUES
                                (@UserID, @UserID, 'PASSWORD_RESET_COMPLETED',
                                 'User completed phone verification and changed password.');";

                        using (MySqlCommand command =
                            new MySqlCommand(auditSql, connection, transaction))
                        {
                            command.Parameters.Add(
                                "@UserID",
                                MySqlDbType.Int32
                            ).Value = userId;
                            command.ExecuteNonQuery();
                        }

                        transaction.Commit();
                        return true;
                    }

                }
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Password update failed (MySQL error {0}).",
                    ex.Number);
                errorMessage =
                    "The password could not be updated. Please try again.";

                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Password update failed ({0}).",
                    ex.GetType().Name);
                errorMessage =
                    "The password could not be updated. Please try again.";

                return false;
            }
        }


        // ============================================================
        // CHECK EMAIL
        // ============================================================

        public static bool EmailExists(
            string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return false;
            }


            const string query = @"
                SELECT COUNT(*)
                FROM users
                WHERE LOWER(TRIM(Email)) =
                      LOWER(TRIM(@Email));";


            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command =
                        new MySqlCommand(
                            query,
                            connection))
                    {
                        command.Parameters.Add(
                            "@Email",
                            MySqlDbType.VarChar,
                            100
                        ).Value =
                            email.Trim();


                        connection.Open();


                        int count =
                            Convert.ToInt32(
                                command.ExecuteScalar());


                        return count > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }


        // ============================================================
        // CHECK PHONE
        // ============================================================

        public static bool PhoneExists(
            string phone)
        {
            if (string.IsNullOrWhiteSpace(phone))
            {
                return false;
            }


            string normalizedPhone = NormalizeGhanaPhone(phone);
            if (String.IsNullOrEmpty(normalizedPhone))
                return false;

            const string query = @"
                SELECT COUNT(*)
                FROM users
                WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                          TRIM(COALESCE(Phone, '')), ' ', ''), '-', ''), '(', ''),
                          ')', ''), '+', ''), '.', '') IN
                      (@LocalPhone, @InternationalPhone);";


            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command =
                        new MySqlCommand(
                            query,
                            connection))
                    {
                        command.Parameters.Add(
                            "@LocalPhone",
                            MySqlDbType.VarChar,
                            20
                        ).Value = normalizedPhone;

                        command.Parameters.Add(
                            "@InternationalPhone",
                            MySqlDbType.VarChar,
                            20
                        ).Value = "233" + normalizedPhone.Substring(1);


                        connection.Open();


                        int count =
                            Convert.ToInt32(
                                command.ExecuteScalar());


                        return count > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }


        // ============================================================
        // GET ALL USERS
        // ============================================================

        public static List<UserAccount> GetAllUsers()
        {
            List<UserAccount> users =
                new List<UserAccount>();


            const string query = @"
                SELECT
                    UserID,
                    FirstName,
                    LastName,
                    Email,
                    Phone,
                    PhoneVerified,
                    Password,
                    Role
                FROM users
                ORDER BY UserID DESC;";


            try
            {
                using (MySqlConnection connection =
                    new MySqlConnection(ConnectionString))
                {
                    using (MySqlCommand command =
                        new MySqlCommand(
                            query,
                            connection))
                    {
                        connection.Open();


                        using (MySqlDataReader reader =
                            command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                users.Add(
                                    ReadUser(reader));
                            }
                        }
                    }
                }
            }
            catch
            {
                return users;
            }


            return users;
        }


        // ============================================================
        // READ USER
        // ============================================================

        private static UserAccount ReadUser(
            MySqlDataReader reader)
        {
            UserAccount user =
                new UserAccount();


            user.UserID =
                Convert.ToInt32(
                    reader["UserID"]);


            user.FirstName =
                Convert.ToString(
                    reader["FirstName"]);


            user.LastName =
                Convert.ToString(
                    reader["LastName"]);


            user.Email =
                Convert.ToString(
                    reader["Email"]);


            user.Phone =
                Convert.ToString(
                    reader["Phone"]);


            user.PhoneVerified =
                Convert.ToBoolean(
                    reader["PhoneVerified"]);


            user.Password =
                Convert.ToString(
                    reader["Password"]);


            user.Role =
                Convert.ToString(
                    reader["Role"]);


            return user;
        }
    }


    // ================================================================
    // USER ACCOUNT MODEL
    // ================================================================

    public class UserAccount
    {
        public int UserID
        {
            get;
            set;
        }


        public string FirstName
        {
            get;
            set;
        }


        public string LastName
        {
            get;
            set;
        }


        public string Email
        {
            get;
            set;
        }


        public string Phone
        {
            get;
            set;
        }


        public bool PhoneVerified
        {
            get;
            set;
        }


        public string Password
        {
            get;
            set;
        }


        public string Role
        {
            get;
            set;
        }

        public bool IsActive
        {
            get;
            set;
        }

        public int FailedLoginAttempts
        {
            get;
            set;
        }

        public DateTime? LockedUntil
        {
            get;
            set;
        }

        public bool PasswordResetRequired
        {
            get;
            set;
        }
    }
}