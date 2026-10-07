using System;
using System.Reflection;

// Pure policy checks only. No database, ASPX execution or provider requests.
public static class AdminFeatureContractChecks
{
    private static int passed;
    private static void Check(bool value, string name)
    {
        if (!value) throw new Exception("FAILED: " + name);
        passed++;
    }
    private static object Call(Type type, string method, params object[] arguments)
    {
        return type.GetMethod(method, BindingFlags.NonPublic | BindingFlags.Static).Invoke(null, arguments);
    }
    public static void Main(string[] args)
    {
        Type type = Assembly.LoadFrom(args[0]).GetType("PoliceBackgroundCheckSystem.AdminWorkflowService", true);
        foreach (string priority in new[] { "Normal", "High", "Urgent" })
            Check((bool)Call(type, "ValidPriority", priority), priority);
        foreach (string priority in new[] { null, "", "urgent", "Low", "Normal ", "';DROP TABLE users;--" })
            Check(!(bool)Call(type, "ValidPriority", priority), "Reject unsupported priority");
        foreach (string status in new[] { "Pending", " pending ", "PENDING APPROVAL" })
            Check((bool)Call(type, "IsPending", status), "Pending state");
        foreach (string status in new[] { null, "", "Approved", "Rejected", "Completed", "Pending payment" })
            Check(!(bool)Call(type, "IsPending", status), "Non-pending state");
        foreach (string reference in new[] { "APP-000123", "GPRS_20261005-1", new string('A', 50) })
        {
            Call(type, "RequireReference", reference);
            Check(true, "Supported reference");
        }
        foreach (string reference in new[] { null, "", "APP 1", "<script>", "APP-1\n", new string('A', 51) })
        {
            bool rejected = false;
            try { Call(type, "RequireReference", reference); }
            catch (TargetInvocationException ex) { rejected = ex.InnerException is InvalidOperationException; }
            Check(rejected, "Reject malformed reference");
        }
        bool transactionRequired = false;
        try { Call(type, "AppendWorkflow", null, null, 1, 1, "PriorityChanged", "Pending", "Pending", ""); }
        catch (TargetInvocationException ex) { transactionRequired = ex.InnerException is InvalidOperationException; }
        Check(transactionRequired, "No detached workflow write");
        Type sms = Assembly.LoadFrom(args[0]).GetType("PoliceBackgroundCheckSystem.Helpers.HubtelSmsService", true);
        foreach (string json in new[] { "{\"Status\":5}", "{\"Status\":0}" })
        {
            bool rejected = false;
            try { Call(sms, "ParseAcknowledgement", json); }
            catch (TargetInvocationException ex)
            {
                rejected = ex.InnerException is InvalidOperationException &&
                    (ex.InnerException.GetType().Name == "ProviderRejectedException") == json.Contains(":5");
            }
            Check(rejected, "Definite rejection distinguished from malformed acknowledgement");
        }
        Console.WriteLine(passed + " offline admin-feature policy checks passed; no database/provider calls made.");
    }
}
