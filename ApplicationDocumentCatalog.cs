using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;

namespace PoliceBackgroundCheckSystem.Helpers
{
    // Shared by read-only inspection and officer document-review requirements.
    public static class ApplicationDocumentCatalog
    {
        public static string[] RequiredTypes(string idType)
        {
            switch ((idType ?? "").Trim().ToUpperInvariant())
            {
                case "GHANA CARD": return new[] { "PASSPORT_PHOTO", "GHANA_CARD_FRONT", "GHANA_CARD_BACK" };
                case "PASSPORT": return new[] { "PASSPORT_PHOTO", "PASSPORT_BIO_PAGE" };
                case "VOTER ID": return new[] { "PASSPORT_PHOTO", "VOTER_ID_FRONT", "VOTER_ID_BACK" };
                case "DRIVER'S LICENCE": return new[] { "PASSPORT_PHOTO", "DRIVERS_LICENCE_FRONT", "DRIVERS_LICENCE_BACK" };
                default: return new string[0];
            }
        }

        public static string Prefix(string type)
        {
            switch (type)
            {
                case "PASSPORT_PHOTO": return "PassportPhoto";
                case "GHANA_CARD_FRONT": return "GhanaCardFront";
                case "GHANA_CARD_BACK": return "GhanaCardBack";
                case "PASSPORT_BIO_PAGE":
                case "VOTER_ID_DOCUMENT": // Historical single-side Voter ID uploads.
                case "VOTER_ID_FRONT":
                case "DRIVERS_LICENCE_FRONT": return "IdentityDocument";
                case "VOTER_ID_BACK":
                case "DRIVERS_LICENCE_BACK": return "IdentityDocumentBack";
                default: return null;
            }
        }

        public static string Label(string type)
        {
            switch (type)
            {
                case "PASSPORT_PHOTO": return "Passport photograph";
                case "GHANA_CARD_FRONT": return "Ghana Card — front";
                case "GHANA_CARD_BACK": return "Ghana Card — back";
                case "PASSPORT_BIO_PAGE": return "Passport bio-data page";
                case "VOTER_ID_DOCUMENT": return "Voter ID (historical single document)";
                case "VOTER_ID_FRONT": return "Voter ID — front";
                case "VOTER_ID_BACK": return "Voter ID — back";
                case "DRIVERS_LICENCE_FRONT": return "Driver's Licence — front";
                case "DRIVERS_LICENCE_BACK": return "Driver's Licence — back";
                default: return "Unknown document";
            }
        }

        public static string FindFile(string applicationId, string type)
        {
            if (!Regex.IsMatch(applicationId ?? "", @"^[A-Za-z0-9_-]{1,50}$"))
                return null;
            string prefix = Prefix(type);
            if (prefix == null) return null;
            string folder = Path.Combine(HttpContext.Current.Server.MapPath("~/App_Data/Applications"), applicationId);
            if (!Directory.Exists(folder)) return null;
            foreach (string file in Directory.GetFiles(folder, prefix + ".*"))
            {
                string extension = Path.GetExtension(file).ToLowerInvariant();
                if (extension == ".jpg" || extension == ".jpeg" || extension == ".png" ||
                    (type != "PASSPORT_PHOTO" && extension == ".pdf"))
                    return file;
            }
            return null;
        }
    }
}
