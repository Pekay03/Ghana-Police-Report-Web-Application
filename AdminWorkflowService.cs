using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Web;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;

namespace PoliceBackgroundCheckSystem
{
    internal static class AdminWorkflowService
    {
        internal static string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString; }
        }

        internal static MySqlCommand Command(MySqlConnection c, MySqlTransaction t, string sql, params object[] args)
        {
            var command = new MySqlCommand(sql, c, t);
            for (int i = 0; i < args.Length; i += 2)
                command.Parameters.AddWithValue(Convert.ToString(args[i]), args[i + 1] ?? DBNull.Value);
            return command;
        }

        internal static DataTable Table(MySqlConnection c, MySqlTransaction t, string sql, params object[] args)
        {
            using (var command = Command(c, t, sql, args))
            using (var adapter = new MySqlDataAdapter(command))
            {
                var table = new DataTable();
                adapter.Fill(table);
                return table;
            }
        }

        internal static int SessionActor(HttpContext context)
        {
            int actor;
            bool authenticated;
            if (context.Session == null ||
                !Boolean.TryParse(Convert.ToString(context.Session["IsAuthenticated"]), out authenticated) ||
                !authenticated || !Int32.TryParse(Convert.ToString(context.Session["UserID"]), out actor) || actor <= 0)
                throw new InvalidOperationException("Sign in again before changing a record.");
            return actor;
        }

        private static string TokenKey(HttpContext context)
        {
            return "AdminWorkflowCsrf:" + SessionActor(context).ToString(CultureInfo.InvariantCulture);
        }

        internal static string FormToken(HttpContext context)
        {
            string key = TokenKey(context);
            if (context.Session[key] == null) context.Session[key] = Guid.NewGuid().ToString("N");
            return Convert.ToString(context.Session[key]);
        }

        internal static void ValidatePost(HttpContext context, string token)
        {
            if (context.Request.HttpMethod != "POST" ||
                !IdentityReview.TokensEqual(token, Convert.ToString(context.Session[TokenKey(context)])))
                throw new InvalidOperationException("The form expired or could not be validated. Reload it.");
        }

        internal static bool IsPending(string status)
        {
            string value = (status ?? "").Trim().ToLowerInvariant();
            return value == "pending" || value == "pending approval";
        }

        internal static bool ValidPriority(string priority)
        {
            return priority == "Normal" || priority == "High" || priority == "Urgent";
        }

        internal static void RequireReference(string reference)
        {
            if (!System.Text.RegularExpressions.Regex.IsMatch(reference ?? "", @"\A[A-Za-z0-9_-]{1,50}\z"))
                throw new InvalidOperationException("Select a valid application reference.");
        }

        internal static DataRow LockApplication(MySqlConnection c, MySqlTransaction t, string reference)
        {
            RequireReference(reference);
            DataTable table = Table(c, t, @"SELECT ApplicationID, application_id, Status, Priority, Email
                FROM applications WHERE application_id=@Reference FOR UPDATE;", "@Reference", reference);
            if (table.Rows.Count != 1) throw new InvalidOperationException("The application is unavailable.");
            return table.Rows[0];
        }

        internal static int ApplicationKey(MySqlConnection c, MySqlTransaction t, string reference)
        {
            using (var command = Command(c, t,
                "SELECT ApplicationID FROM applications WHERE application_id=@Reference;",
                "@Reference", reference))
            {
                object value = command.ExecuteScalar();
                if (value == null || value == DBNull.Value)
                    throw new InvalidOperationException("The application is unavailable.");
                return Convert.ToInt32(value);
            }
        }

        internal static void AppendWorkflow(MySqlConnection c, MySqlTransaction t, int applicationId,
            int actor, string action, string fromStatus, string toStatus, string notes)
        {
            if (actor <= 0 || applicationId <= 0) throw new InvalidOperationException("A recorded actor and application are required.");
            if (t == null || t.Connection != c)
                throw new InvalidOperationException("Workflow events require the owning database transaction.");
            using (var command = Command(c, t, @"INSERT INTO application_workflow_history
                (ApplicationID, ActionType, FromStatus, ToStatus, ActionByUserID, Notes, ActionAt)
                VALUES (@App,@Action,@From,@To,@Actor,@Notes,NOW(6));",
                "@App", applicationId, "@Action", action, "@From", fromStatus, "@To", toStatus,
                "@Actor", actor, "@Notes", notes))
                command.ExecuteNonQuery();
        }

        internal static void EndAssignment(MySqlConnection c, MySqlTransaction t, int applicationId, int actor)
        {
            using (var command = Command(c, t, @"UPDATE application_assignments SET Status='Ended',
                UnassignedAt=NOW(6),UnassignedByUserID=@Actor WHERE ApplicationID=@App AND UnassignedAt IS NULL;",
                "@Actor", actor, "@App", applicationId))
                command.ExecuteNonQuery();
        }

        internal static DataRow LockCertificateApplication(MySqlConnection c, MySqlTransaction t,
            HttpContext context, string reference)
        {
            int actor = SessionActor(context);
            DataTable account = Table(c, t, "SELECT Role,Email,IsActive FROM users WHERE UserID=@Actor FOR UPDATE;",
                "@Actor", actor);
            if (account.Rows.Count != 1 || !Convert.ToBoolean(account.Rows[0]["IsActive"]))
                throw new InvalidOperationException("An active account is required.");
            DataRow application = LockApplication(c, t, reference);
            if (!StaffAccess.IsReviewerRole(Convert.ToString(account.Rows[0]["Role"])) &&
                !String.Equals(Convert.ToString(account.Rows[0]["Email"]).Trim(),
                    Convert.ToString(application["Email"]).Trim(), StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Certificate access is denied.");
            if (!String.Equals(Convert.ToString(application["Status"]).Trim(), "Approved", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("A certificate requires an approved application.");
            var payment = Table(c, t, @"SELECT PaymentID FROM payments WHERE ApplicationID=@App
                AND PaymentVerified=1 AND TransactionID LIKE 'HBT-%' ORDER BY PaymentID DESC LIMIT 1 FOR UPDATE;",
                "@App", application["ApplicationID"]);
            if (payment.Rows.Count != 1)
                throw new InvalidOperationException("A certificate requires Hubtel-confirmed payment.");
            return application;
        }

        internal static void Audit(MySqlConnection c, MySqlTransaction t, HttpContext context,
            int actor, int? target, string action, string details)
        {
            using (var command = Command(c, t, @"INSERT INTO account_audit_logs
                (ActorUserID,TargetUserID,ActionType,Details,IPAddress,UserAgent,CreatedAt)
                VALUES (@Actor,@Target,@Action,@Details,@IP,@Agent,NOW());",
                "@Actor", actor, "@Target", target, "@Action", action, "@Details", details,
                "@IP", Limit(context.Request.UserHostAddress, 45),
                "@Agent", Limit(context.Request.UserAgent, 255)))
                command.ExecuteNonQuery();
        }

        private static string Limit(string text, int length)
        {
            return text == null ? null : text.Substring(0, Math.Min(text.Length, length));
        }

        private static void AdminTransaction(HttpContext context, string token, int? target,
            Action<MySqlConnection, MySqlTransaction, int> change)
        {
            ValidatePost(context, token);
            int actor = SessionActor(context);
            using (var c = new MySqlConnection(ConnectionString))
            {
                c.Open();
                using (var t = c.BeginTransaction())
                {
                    // Lock accounts in a stable order before the application row.
                    Table(c, t, @"SELECT UserID FROM users WHERE UserID IN (@Actor,@Target)
                        ORDER BY UserID FOR UPDATE;", "@Actor", actor, "@Target", target ?? actor);
                    string name;
                    if (!StaffAccess.CheckUser(c, t, actor, true, out name))
                        throw new InvalidOperationException("An active administrator account is required.");
                    change(c, t, actor);
                    t.Commit();
                }
            }
        }

        internal static void SetAssignment(HttpContext context, string token, string reference,
            int? officer, string reason)
        {
            reason = (reason ?? "").Trim();
            if (reason.Length > 1000 || (officer.HasValue && officer.Value <= 0))
                throw new InvalidOperationException("Choose an officer and a note of at most 1,000 characters.");
            AdminTransaction(context, token, officer, (c, t, actor) =>
            {
                if (officer.HasValue)
                {
                    var staff = Table(c, t, "SELECT Role,IsActive FROM users WHERE UserID=@Officer;",
                        "@Officer", officer);
                    if (staff.Rows.Count != 1 || !Convert.ToBoolean(staff.Rows[0]["IsActive"]) ||
                        StaffAccess.IsAdminRole(Convert.ToString(staff.Rows[0]["Role"])) ||
                        !StaffAccess.IsReviewerRole(Convert.ToString(staff.Rows[0]["Role"])))
                        throw new InvalidOperationException("Select a currently active officer.");
                }
                DataRow app = LockApplication(c, t, reference);
                if (!IsPending(Convert.ToString(app["Status"])))
                    throw new InvalidOperationException("Only pending applications can be assigned or unassigned.");
                int id = Convert.ToInt32(app["ApplicationID"]);
                var previous = Table(c, t, @"SELECT AssignmentID,OfficerUserID FROM application_assignments
                    WHERE ApplicationID=@App AND UnassignedAt IS NULL FOR UPDATE;", "@App", id);
                int? oldOfficer = previous.Rows.Count == 0 ? (int?)null :
                    Convert.ToInt32(previous.Rows[0]["OfficerUserID"]);
                if (oldOfficer == officer)
                    throw new InvalidOperationException(officer.HasValue ? "This officer is already assigned." : "The application is already unassigned.");
                using (var command = Command(c, t, @"UPDATE application_assignments SET UnassignedAt=NOW(6),
                    UnassignedByUserID=@Actor,Status='Ended' WHERE ApplicationID=@App AND UnassignedAt IS NULL;",
                    "@Actor", actor, "@App", id))
                    command.ExecuteNonQuery();
                if (officer.HasValue)
                    using (var command = Command(c, t, @"INSERT INTO application_assignments
                        (ApplicationID,OfficerUserID,AssignedByUserID,AssignedAt,Status)
                        VALUES (@App,@Officer,@Actor,NOW(6),'Active');",
                        "@App", id, "@Officer", officer, "@Actor", actor))
                        command.ExecuteNonQuery();
                string action = !officer.HasValue ? "ApplicationUnassigned" :
                    oldOfficer.HasValue ? "ApplicationReassigned" : "ApplicationAssigned";
                string note = JsonConvert.SerializeObject(new { PreviousOfficerUserID = oldOfficer,
                    OfficerUserID = officer, Reason = reason });
                string status = Convert.ToString(app["Status"]);
                AppendWorkflow(c, t, id, actor, action, status, status, note);
                Audit(c, t, context, actor, officer, action, "Application " + reference + ": " + note);
            });
        }

        internal static void SetPriority(HttpContext context, string token, string reference, string priority)
        {
            if (!ValidPriority(priority)) throw new InvalidOperationException("Select Normal, High or Urgent.");
            AdminTransaction(context, token, null, (c, t, actor) =>
            {
                DataRow app = LockApplication(c, t, reference);
                if (!IsPending(Convert.ToString(app["Status"])))
                    throw new InvalidOperationException("Priority changes are restricted to pending applications.");
                string old = Convert.ToString(app["Priority"]);
                if (old == priority) throw new InvalidOperationException("The priority is unchanged.");
                int id = Convert.ToInt32(app["ApplicationID"]);
                using (var command = Command(c, t, "UPDATE applications SET Priority=@Priority WHERE ApplicationID=@App;",
                    "@Priority", priority, "@App", id))
                    command.ExecuteNonQuery();
                string note = JsonConvert.SerializeObject(new { PreviousPriority = old, Priority = priority });
                string status = Convert.ToString(app["Status"]);
                AppendWorkflow(c, t, id, actor, "PriorityChanged", status, status, note);
                Audit(c, t, context, actor, null, "PriorityChanged", "Application " + reference + ": " + note);
            });
        }

        internal static void SaveStaffProfile(HttpContext context, string token, int staffId,
            string first, string last, string number, string department, string station, string rank)
        {
            first = (first ?? "").Trim(); last = (last ?? "").Trim();
            number = (number ?? "").Trim(); department = (department ?? "").Trim();
            station = (station ?? "").Trim(); rank = (rank ?? "").Trim();
            if (staffId <= 0 || first.Length == 0 || last.Length == 0 || first.Length > 50 || last.Length > 50 ||
                number.Length > 50 || department.Length > 150 || station.Length > 150 || rank.Length > 100)
                throw new InvalidOperationException("Enter names and staff fields within their stated limits.");
            AdminTransaction(context, token, staffId, (c, t, actor) =>
            {
                var staff = Table(c, t, @"SELECT Role,FirstName,LastName,StaffNumber,Department,Station,`Rank`
                    FROM users WHERE UserID=@Staff;", "@Staff", staffId);
                if (staff.Rows.Count != 1 || !StaffAccess.IsReviewerRole(Convert.ToString(staff.Rows[0]["Role"])))
                    throw new InvalidOperationException("The selected account is not a staff account.");
                string before = JsonConvert.SerializeObject(new { FirstName = staff.Rows[0]["FirstName"],
                    LastName = staff.Rows[0]["LastName"], StaffNumber = staff.Rows[0]["StaffNumber"],
                    Department = staff.Rows[0]["Department"], Station = staff.Rows[0]["Station"],
                    Rank = staff.Rows[0]["Rank"] });
                using (var command = Command(c, t, @"UPDATE users SET FirstName=@First,LastName=@Last,
                    StaffNumber=@Number,Department=@Department,Station=@Station,`Rank`=@Rank WHERE UserID=@Staff;",
                    "@Staff", staffId, "@First", first, "@Last", last,
                    "@Number", number.Length == 0 ? null : number,
                    "@Department", department.Length == 0 ? null : department,
                    "@Station", station.Length == 0 ? null : station, "@Rank", rank.Length == 0 ? null : rank))
                    command.ExecuteNonQuery();
                string after = JsonConvert.SerializeObject(new { FirstName = first, LastName = last,
                    StaffNumber = number, Department = department, Station = station, Rank = rank });
                Audit(c, t, context, actor, staffId, "StaffProfileUpdated", "Before: " + before + "; After: " + after);
            });
        }

        internal static string SafeError(Exception exception)
        {
            System.Diagnostics.Trace.TraceError("Admin feature failed ({0}).", exception.GetType().Name);
            var mysql = exception as MySqlException;
            if (mysql != null && mysql.Number == 1062) return "This staff number is already in use.";
            if (exception is InvalidOperationException && !(exception is MySqlException))
                return exception.Message;
            return "The feature is unavailable. Confirm database access and the reviewed AdminFeatures migration. No partial change was saved.";
        }
    }
}
