using System;
using System.Web;
using System.Web.SessionState;

namespace PoliceBackgroundCheckSystem.Helpers
{
    public static class SessionHelper
    {
        private static HttpSessionState Session
        {
            get
            {
                return HttpContext.Current.Session;
            }
        }

        public static bool IsLoggedIn
        {
            get
            {
                return Session["UserId"] != null;
            }
        }

        public static int UserId
        {
            get
            {
                if (Session["UserId"] == null)
                    return 0;

                return Convert.ToInt32(
                    Session["UserId"]
                );
            }
        }

        public static string Username
        {
            get
            {
                return Session["Username"] == null
                    ? string.Empty
                    : Session["Username"].ToString();
            }
        }

        public static string FullName
        {
            get
            {
                return Session["FullName"] == null
                    ? string.Empty
                    : Session["FullName"].ToString();
            }
        }

        public static string Role
        {
            get
            {
                return Session["Role"] == null
                    ? string.Empty
                    : Session["Role"].ToString();
            }
        }

        public static string BadgeNumber
        {
            get
            {
                return Session["BadgeNumber"] == null
                    ? string.Empty
                    : Session["BadgeNumber"].ToString();
            }
        }

        public static string Station
        {
            get
            {
                return Session["Station"] == null
                    ? string.Empty
                    : Session["Station"].ToString();
            }
        }

        public static void Login(
            int userId,
            string username,
            string fullName,
            string role,
            string badgeNumber,
            string station)
        {
            Session["UserId"] = userId;
            Session["Username"] = username;
            Session["FullName"] = fullName;
            Session["Role"] = role;
            Session["BadgeNumber"] = badgeNumber;
            Session["Station"] = station;
        }

        public static void Logout()
        {
            Session.Clear();
            Session.Abandon();
        }

        public static bool IsCitizen()
        {
            return Role.Equals(
                "Citizen",
                StringComparison.OrdinalIgnoreCase
            );
        }

        public static bool IsOfficer()
        {
            return Role.Equals(
                "PoliceOfficer",
                StringComparison.OrdinalIgnoreCase
            );
        }

        public static bool IsAdministrator()
        {
            return Role.Equals(
                "Administrator",
                StringComparison.OrdinalIgnoreCase
            );
        }
    }
}