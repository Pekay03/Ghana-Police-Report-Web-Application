using System;
using System.Reflection;
using System.Data;

// Offline policy checks. Not a substitute for IIS, MySQL or live provider tests.
public static class ModuleContractChecks
{
    private static int passed;
    private static void Check(bool condition, string name)
    {
        if (!condition) throw new Exception("FAILED: " + name);
        passed++;
    }
    public static void Main(string[] args)
    {
        Assembly assembly = Assembly.LoadFrom(args[0]);
        Type access = assembly.GetType("PoliceBackgroundCheckSystem.StaffAccess", true);
        MethodInfo admin = access.GetMethod("IsAdminRole", BindingFlags.NonPublic | BindingFlags.Static);
        MethodInfo reviewer = access.GetMethod("IsReviewerRole", BindingFlags.NonPublic | BindingFlags.Static);
        foreach (string role in new[] { "Admin", "Administrator", "System Admin", "system_admin", "SYSTEM-ADMIN" })
        {
            Check((bool)admin.Invoke(null, new object[] { role }), "admin role: " + role);
            Check((bool)reviewer.Invoke(null, new object[] { role }), "admin document reviewer: " + role);
        }
        foreach (string role in new[] { "Officer", "Police Officer", "Vetting-Officer" })
        {
            Check(!(bool)admin.Invoke(null, new object[] { role }), "officer is not administrator");
            Check((bool)reviewer.Invoke(null, new object[] { role }), "officer document reviewer");
        }
        foreach (string role in new[] { null, "", "Citizen", "AdministratorX", "Police Officer Administrator" })
        {
            Check(!(bool)admin.Invoke(null, new object[] { role }), "non-admin denied");
            Check(!(bool)reviewer.Invoke(null, new object[] { role }), "non-reviewer denied");
        }
        Type review = assembly.GetType("PoliceBackgroundCheckSystem.IdentityReview", true);
        MethodInfo tokens = review.GetMethod("TokensEqual", BindingFlags.NonPublic | BindingFlags.Static);
        Check((bool)tokens.Invoke(null, new object[] { "valid-token", "valid-token" }), "matching CSRF token");
        foreach (object[] pair in new[] {
            new object[] { null, null }, new object[] { "", "" },
            new object[] { "abc", "" }, new object[] { "abc", "abcd" },
            new object[] { "abc", "abd" }, new object[] { "ABC", "abc" } })
            Check(!(bool)tokens.Invoke(null, pair), "invalid CSRF token denied");
        MethodInfo fields = review.GetMethod("ComparisonFields", BindingFlags.NonPublic | BindingFlags.Static);
        var source = new DataTable();
        foreach (string column in new[] { "ApplicantName", "RegistryName", "ApplicantDateOfBirth",
            "RegistryDateOfBirth", "ApplicantGender", "RegistryGender", "NameMatch",
            "DateOfBirthMatch", "GenderMatch", "GhanaCardMatch" }) source.Columns.Add(column, typeof(object));
        Check(((DataTable)fields.Invoke(null, new object[] { source })).Rows.Count == 0,
            "no fabricated comparison when source is empty");
        source.Rows.Add("Fixture name", "Different fixture", new DateTime(1990,1,1),
            new DateTime(1990,1,1), "Male", DBNull.Value, false, true, DBNull.Value, true);
        DataTable comparison = (DataTable)fields.Invoke(null, new object[] { source });
        Check(comparison.Rows.Count == 4, "four field-oriented local comparison rows");
        Check((string)comparison.Rows[0]["Result"] == "Recorded mismatch", "stored false remains mismatch");
        Check((string)comparison.Rows[1]["Result"] == "Recorded match", "stored true remains match");
        Check((string)comparison.Rows[2]["Result"] == "No recorded result", "null is never a fabricated match");
        Check((string)comparison.Rows[2]["ComparedValue"] == "Not recorded", "missing compared field explicit");
        Check((string)comparison.Rows[3]["ComparedValue"] == "Not stored in comparison snapshot",
            "no invented compared identity number");
        Console.WriteLine(passed + " offline role/CSRF policy checks passed.");
    }
}
