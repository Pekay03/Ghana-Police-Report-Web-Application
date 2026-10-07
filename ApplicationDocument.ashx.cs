using System;
using System.Configuration;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.SessionState;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    public sealed class ApplicationDocument : IHttpHandler, IRequiresSessionState
    {
        private readonly string connectionString =
            ConfigurationManager
                .ConnectionStrings["PoliceReportDB"]
                .ConnectionString;

        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            context.Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            context.Response.Headers["X-Content-Type-Options"] = "nosniff";
            context.Response.Headers["X-Frame-Options"] = "SAMEORIGIN";
            context.Response.Headers["Content-Security-Policy"] =
                "frame-ancestors 'self'";

            int userId;
            if (!TryGetUserId(context, out userId))
            {
                WriteError(context, 403, "Access denied.");
                return;
            }

            string applicationId =
                Convert.ToString(context.Request.QueryString["id"]).Trim();
            string documentType =
                Convert.ToString(context.Request.QueryString["type"])
                    .Trim()
                    .ToUpperInvariant();

            if (!Regex.IsMatch(applicationId, @"\A[A-Za-z0-9_-]{1,50}\z"))
            {
                WriteError(context, 404, "Document not found.");
                return;
            }

            string prefix;
            if (!TryGetDocumentPrefix(documentType, out prefix))
            {
                WriteError(context, 404, "Document not found.");
                return;
            }

            string root = context.Server.MapPath("~/App_Data/Applications/");
            string applicationFolder =
                Path.GetFullPath(Path.Combine(root, applicationId));
            string fullRoot = Path.GetFullPath(root);

            if (!applicationFolder.StartsWith(
                    fullRoot.TrimEnd(Path.DirectorySeparatorChar) +
                        Path.DirectorySeparatorChar,
                    StringComparison.OrdinalIgnoreCase))
            {
                WriteError(context, 404, "Document not found.");
                return;
            }

            string documentPath;
            try
            {
                using (MySqlConnection connection =
                       new MySqlConnection(connectionString))
                {
                    connection.Open();

                    if (!IsCurrentOfficer(connection, userId))
                    {
                        WriteError(context, 403, "Access denied.");
                        return;
                    }

                    using (MySqlCommand command = new MySqlCommand(
                        "SELECT COUNT(*) FROM applications WHERE application_id=@Id;",
                        connection))
                    {
                        command.Parameters.Add(
                            "@Id",
                            MySqlDbType.VarChar,
                            50).Value = applicationId;

                        if (Convert.ToInt32(command.ExecuteScalar()) != 1)
                        {
                            WriteError(context, 404, "Document not found.");
                            return;
                        }
                    }

                    documentPath = FindStoredDocument(applicationFolder, prefix);
                    if (documentPath == null)
                    {
                        WriteError(context, 404, "Document not found.");
                        return;
                    }

                    WriteDocumentAccessAudit(
                        connection,
                        userId,
                        applicationId,
                        documentType);
                }
            }
            catch (MySqlException ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Application document access failed (MySQL error {0}).",
                    ex.Number);
                WriteError(
                    context,
                    503,
                    "The document service is temporarily unavailable.");
                return;
            }
            catch (IOException)
            {
                WriteError(context, 404, "Document not found.");
                return;
            }

            string extension = Path.GetExtension(documentPath).ToLowerInvariant();
            context.Response.ContentType = extension == ".pdf"
                ? "application/pdf"
                : extension == ".png"
                    ? "image/png"
                    : "image/jpeg";
            context.Response.AddHeader(
                "Content-Disposition",
                "inline; filename=\"" + prefix + extension + "\"");
            context.Response.TransmitFile(documentPath);
            context.ApplicationInstance.CompleteRequest();
        }

        private static bool TryGetUserId(HttpContext context, out int userId)
        {
            userId = 0;
            if (context.Session == null)
                return false;

            bool authenticated;
            if (!bool.TryParse(
                    Convert.ToString(context.Session["IsAuthenticated"]),
                    out authenticated) ||
                !authenticated)
                return false;

            return int.TryParse(
                    Convert.ToString(context.Session["UserID"]),
                    out userId) &&
                userId > 0;
        }

        private static bool IsStaffRole(string role)
        {
            string normalized = Convert.ToString(role)
                .Trim()
                .Replace(" ", "")
                .Replace("-", "")
                .Replace("_", "");

            return normalized.Equals("OFFICER", StringComparison.OrdinalIgnoreCase) ||
                normalized.Equals("POLICEOFFICER", StringComparison.OrdinalIgnoreCase) ||
                normalized.Equals("POLICE", StringComparison.OrdinalIgnoreCase) ||
                normalized.Equals("VETTING", StringComparison.OrdinalIgnoreCase) ||
                normalized.Equals("ADMIN", StringComparison.OrdinalIgnoreCase) ||
                normalized.Equals("ADMINISTRATOR", StringComparison.OrdinalIgnoreCase) ||
                normalized.Equals("SYSTEMADMIN", StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsCurrentOfficer(
            MySqlConnection connection,
            int userId)
        {
            const string sql =
                "SELECT Role, IsActive FROM users WHERE UserID=@UserID LIMIT 1;";

            using (MySqlCommand command =
                   new MySqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@UserID",
                    MySqlDbType.Int32).Value = userId;

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    return reader.Read() &&
                        Convert.ToBoolean(reader["IsActive"]) &&
                        IsStaffRole(Convert.ToString(reader["Role"]));
                }
            }
        }

        private static bool TryGetDocumentPrefix(
            string documentType,
            out string prefix)
        {
            switch (documentType)
            {
                case "PASSPORT_PHOTO":
                    prefix = "PassportPhoto";
                    return true;
                case "GHANA_CARD_FRONT":
                    prefix = "GhanaCardFront";
                    return true;
                case "GHANA_CARD_BACK":
                    prefix = "GhanaCardBack";
                    return true;
                case "PASSPORT_BIO_PAGE":
                case "VOTER_ID_DOCUMENT":
                case "VOTER_ID_FRONT":
                case "DRIVERS_LICENCE_FRONT":
                    prefix = "IdentityDocument";
                    return true;
                case "VOTER_ID_BACK":
                case "DRIVERS_LICENCE_BACK":
                    prefix = "IdentityDocumentBack";
                    return true;
                default:
                    prefix = null;
                    return false;
            }
        }

        private static string FindStoredDocument(
            string applicationFolder,
            string prefix)
        {
            if (!Directory.Exists(applicationFolder))
                return null;

            string[] files = Directory.GetFiles(
                applicationFolder,
                prefix + ".*",
                SearchOption.TopDirectoryOnly);

            foreach (string file in files)
            {
                string extension = Path.GetExtension(file).ToLowerInvariant();
                if (extension == ".jpg" ||
                    extension == ".jpeg" ||
                    extension == ".png" ||
                    extension == ".pdf")
                    return file;
            }

            return null;
        }

        private static void WriteDocumentAccessAudit(
            MySqlConnection connection,
            int userId,
            string applicationId,
            string documentType)
        {
            const string sql = @"
                INSERT INTO account_audit_logs
                    (ActorUserID, TargetUserID, ActionType, Details)
                VALUES
                    (@ActorUserID, NULL, 'APPLICATION_DOCUMENT_VIEWED',
                     @Details);";

            using (MySqlCommand command =
                   new MySqlCommand(sql, connection))
            {
                command.Parameters.Add(
                    "@ActorUserID",
                    MySqlDbType.Int32).Value = userId;
                command.Parameters.Add(
                    "@Details",
                    MySqlDbType.Text).Value =
                    "Application " + applicationId +
                    "; document type " + documentType + ".";
                command.ExecuteNonQuery();
            }
        }

        private static void WriteError(
            HttpContext context,
            int statusCode,
            string message)
        {
            context.Response.StatusCode = statusCode;
            context.Response.ContentType = "text/plain";
            context.Response.Write(message);
            context.ApplicationInstance.CompleteRequest();
        }
    }
}