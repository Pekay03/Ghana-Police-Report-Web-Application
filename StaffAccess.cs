using System;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    // Never authorize a privileged action solely from a stale session role.
    internal static class StaffAccess
    {
        internal static string NormalizeRole(string role)
        {
            return (role ?? "").Trim().Replace(" ", "").Replace("-", "")
                .Replace("_", "").ToLowerInvariant();
        }

        internal static bool IsAdminRole(string role)
        {
            string normalized = NormalizeRole(role);
            return normalized == "admin" || normalized == "administrator" ||
                normalized == "systemadmin";
        }

        internal static bool IsReviewerRole(string role)
        {
            string normalized = NormalizeRole(role);
            return IsAdminRole(role) || normalized == "officer" ||
                normalized == "policeofficer" || normalized == "vettingofficer";
        }

        internal static bool TryUser(HttpContext context, bool adminOnly,
            out int userId, out string name)
        {
            userId = 0;
            name = "";
            bool authenticated;
            if (context.Session == null ||
                !Boolean.TryParse(Convert.ToString(context.Session["IsAuthenticated"]), out authenticated) ||
                !authenticated ||
                !Int32.TryParse(Convert.ToString(context.Session["UserID"]), out userId) ||
                userId <= 0) return false;
            try
            {
                using (MySqlConnection connection = new MySqlConnection(
                    ConfigurationManager.ConnectionStrings["PoliceReportDB"].ConnectionString))
                {
                    connection.Open();
                    return CheckUser(connection, null, userId, adminOnly, out name);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Staff access check failed ({0}).", ex.GetType().Name);
                return false;
            }
        }

        internal static bool CheckUser(MySqlConnection connection, MySqlTransaction transaction,
            int userId, bool adminOnly, out string name)
        {
            name = "";
            using (MySqlCommand command = new MySqlCommand(
                "SELECT Role, IsActive, FirstName, LastName FROM users WHERE UserID=@UserID LIMIT 1" +
                (transaction == null ? ";" : " FOR UPDATE;"), connection, transaction))
            {
                command.Parameters.AddWithValue("@UserID", userId);
                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    if (!reader.Read() || !Convert.ToBoolean(reader["IsActive"])) return false;
                    string role = Convert.ToString(reader["Role"]);
                    if (!(adminOnly ? IsAdminRole(role) : IsReviewerRole(role))) return false;
                    name = (Convert.ToString(reader["FirstName"]) + " " +
                        Convert.ToString(reader["LastName"])).Trim();
                    return true;
                }
            }
        }
    }
}
