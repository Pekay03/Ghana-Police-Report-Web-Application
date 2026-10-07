using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using MySql.Data.MySqlClient;

namespace PoliceBackgroundCheckSystem
{
    // Read-only operational definitions shared by the overview and analytics.
    internal static class AdminWorkspaceData
    {
        internal static int? TargetHours
        {
            get
            {
                int hours;
                return Int32.TryParse(ConfigurationManager.AppSettings["AdminProcessingTargetHours"],
                    NumberStyles.None, CultureInfo.InvariantCulture, out hours) && hours > 0 && hours <= 8760
                    ? (int?)hours : null;
            }
        }

        internal static string TargetDescription
        {
            get { return TargetHours.HasValue ? TargetHours.Value + " hours from submission" :
                "Not configured — no processing target is assumed"; }
        }

        internal static DataTable Queue(MySqlConnection connection)
        {
            var source = AdminWorkflowService.Table(connection, null, @"SELECT
                COUNT(CASE WHEN a.Priority='Urgent' THEN 1 END) AS Urgent,
                COUNT(CASE WHEN NOT EXISTS (SELECT 1 FROM application_assignments x
                    WHERE x.ApplicationID=a.ApplicationID AND x.UnassignedAt IS NULL) THEN 1 END) AS Unassigned,
                COUNT(CASE WHEN NOT EXISTS (SELECT 1 FROM verification_log v
                    WHERE v.ApplicationID=a.ApplicationID AND
                    (v.Notes LIKE '[LOCAL DOCUMENT REVIEW:%' OR
                     v.Notes LIKE '[LOCAL INDIVIDUAL DOCUMENT REVIEW:%')) THEN 1 END) AS Awaiting,
                COUNT(CASE WHEN @Target IS NOT NULL AND a.DateSubmitted<=NOW() AND
                    TIMESTAMPDIFF(SECOND,a.DateSubmitted,NOW())>@Target*3600 THEN 1 END) AS OverTarget
                FROM applications a WHERE LOWER(TRIM(a.Status)) IN ('pending','pending approval');",
                "@Target", (object)TargetHours ?? DBNull.Value);
            var result = new DataTable();
            result.Columns.Add("Indicator");
            result.Columns.Add("Applications");
            var row = source.Rows[0];
            result.Rows.Add("Urgent pending applications", Convert.ToString(row["Urgent"], CultureInfo.InvariantCulture));
            result.Rows.Add("Unassigned pending applications", Convert.ToString(row["Unassigned"], CultureInfo.InvariantCulture));
            result.Rows.Add("Pending with no recorded local identity review", Convert.ToString(row["Awaiting"], CultureInfo.InvariantCulture));
            result.Rows.Add("Pending exceeding configured processing target",
                TargetHours.HasValue ? Convert.ToString(row["OverTarget"], CultureInfo.InvariantCulture) : "Not configured");
            return result;
        }

        internal const string ProcessingSql = @"SELECT COUNT(*) AS CompletedApplicationsWithValidTimestamps,
            ROUND(AVG(Hours),2) AS AverageHours, ROUND(MAX(MedianHoursValue),2) AS MedianHours,
            ROUND(MIN(Hours),2) AS MinimumHours, ROUND(MAX(Hours),2) AS MaximumHours
            FROM (SELECT TIMESTAMPDIFF(MINUTE,DateSubmitted,ReviewedAt)/60.0 AS Hours,
                PERCENTILE_CONT(0.5) WITHIN GROUP
                    (ORDER BY TIMESTAMPDIFF(MINUTE,DateSubmitted,ReviewedAt)/60.0) OVER () AS MedianHoursValue
                FROM applications WHERE LOWER(TRIM(Status)) IN ('approved','rejected')
                AND ReviewedAt IS NOT NULL AND DateSubmitted IS NOT NULL
                AND ReviewedAt>=DateSubmitted) measured;";

        internal const string WorkloadSql = @"SELECT CONCAT(u.FirstName,' ',u.LastName) AS Officer,
            COUNT(x.AssignmentID) AS Assigned,
            COUNT(CASE WHEN LOWER(TRIM(a.Status)) IN ('pending','pending approval') THEN 1 END) AS Pending,
            COUNT(CASE WHEN LOWER(TRIM(a.Status))='under review' THEN 1 END) AS UnderReview,
            COUNT(CASE WHEN LOWER(TRIM(a.Status)) IN ('approved','rejected') THEN 1 END) AS Completed
            FROM users u LEFT JOIN application_assignments x ON x.OfficerUserID=u.UserID
                AND x.UnassignedAt IS NULL LEFT JOIN applications a ON a.ApplicationID=x.ApplicationID
            WHERE LOWER(REPLACE(REPLACE(REPLACE(TRIM(u.Role),' ',''),'-',''),'_',''))
                IN ('officer','policeofficer','vettingofficer')
            GROUP BY u.UserID,u.FirstName,u.LastName ORDER BY Assigned DESC,u.UserID;";
    }
}
