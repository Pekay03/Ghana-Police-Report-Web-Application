// Offline contract/unit checks only. No database, SMS or wallet request is made.
using System;
using System.Globalization;
using System.Reflection;
using Newtonsoft.Json.Linq;
using PoliceBackgroundCheckSystem.Helpers;

public static class HubtelContractChecks
{
    private static int passed;
    private static void Check(bool value, string label)
    {
        if (!value) throw new Exception("FAILED: " + label);
        passed++;
    }
    private static object Call(Type type, string name, params object[] args)
    {
        return type.GetMethod(name, BindingFlags.NonPublic | BindingFlags.Static).Invoke(null, args);
    }
    private static void Reject(Action action, string label)
    {
        try { action(); }
        catch (TargetInvocationException e)
        {
            if (e.InnerException is InvalidOperationException ||
                e.InnerException is Newtonsoft.Json.JsonException) { passed++; return; }
            throw;
        }
        catch (FormatException) { passed++; return; }
        throw new Exception("FAILED: should reject " + label);
    }
    public static void Main()
    {
        foreach (string number in new[] { "0240000000", "+233240000000", "233240000000", "024 000-0000", "(024) 0000000" })
            Check(HubtelSmsService.ToE164GhanaPhone(number) == "+233240000000", "Ghana E164 format");
        foreach (string number in new[] { "", "+234240000000", "0240000", "abc0240000000", "+233340000000", "00233240000000" })
            Reject(() => HubtelSmsService.ToE164GhanaPhone(number), "invalid Ghana phone");
        foreach (string json in new[] {
            "{\"Status\":0,\"MessageId\":\"offline-message-id\"}",
            "{\"status\":\"0\",\"messageid\":\"offline-message-id\"}" })
            Check(Convert.ToString(Call(typeof(HubtelSmsService), "ParseAcknowledgement", json)) == "offline-message-id", "SMS acceptance acknowledgement");
        foreach (string json in new[] {
            "{\"Status\":1,\"MessageId\":\"offline-message-id\"}",
            "{\"MessageId\":\"offline-message-id\"}", "{\"Status\":0}",
            "{\"Status\":0,\"MessageId\":\"<script>\"}", "not JSON" })
            Reject(() => Call(typeof(HubtelSmsService), "ParseAcknowledgement", json), "failed or malformed SMS acknowledgement");
        foreach (string type in new[] { "Ghana Card", "Voter ID", "Driver's Licence" })
        {
            string[] required = ApplicationDocumentCatalog.RequiredTypes(type);
            Check(required.Length == 3 && required[0] == "PASSPORT_PHOTO", "photograph plus both ID sides");
            foreach (string document in required)
                Check(ApplicationDocumentCatalog.Prefix(document) != null, "document storage mapping");
        }
        Check(ApplicationDocumentCatalog.RequiredTypes("Passport").Length == 2, "passport bio-page retained");
        Check(ApplicationDocumentCatalog.RequiredTypes("unknown").Length == 0, "unsupported ID refused");
        Check(ApplicationDocumentCatalog.Prefix("VOTER_ID_DOCUMENT") == "IdentityDocument", "historical file remains inspectable");
        string reference = "HBT-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        JObject paid = JObject.Parse("{\"Status\":\"Paid\",\"ClientReference\":\"" + reference +
            "\",\"Amount\":150.00,\"CurrencyCode\":\"GHS\",\"TransactionId\":\"offline-provider-id\"}");
        Check(Convert.ToString(Call(typeof(HubtelPaymentService), "ValidatePaidData", paid, reference, 150m)) == "offline-provider-id",
            "matching paid transaction accepted");
        foreach (string property in new[] { "Status", "ClientReference", "Amount", "CurrencyCode", "TransactionId" })
        {
            JObject missing = (JObject)paid.DeepClone();
            missing.Remove(property);
            Reject(() => Call(typeof(HubtelPaymentService), "ValidatePaidData", missing, reference, 150m), "missing " + property);
        }
        foreach (string status in new[] { "Unpaid", "Pending", "Failed", "Cancelled", "Refunded", "Success" })
        {
            JObject wrong = (JObject)paid.DeepClone(); wrong["Status"] = status;
            Reject(() => Call(typeof(HubtelPaymentService), "ValidatePaidData", wrong, reference, 150m), "non-paid status");
        }
        foreach (string property in new[] { "ClientReference", "Amount", "CurrencyCode", "TransactionId" })
        {
            JObject wrong = (JObject)paid.DeepClone();
            wrong[property] = property == "Amount" ? (JToken)149m : (JToken)"<wrong>";
            Reject(() => Call(typeof(HubtelPaymentService), "ValidatePaidData", wrong, reference, 150m), "mismatched " + property);
        }
        CultureInfo.CurrentCulture = CultureInfo.GetCultureInfo("fr-FR");
        Check(Convert.ToString(Call(typeof(HubtelPaymentService), "ValidatePaidData", paid, reference, 150m)) == "offline-provider-id",
            "amount parsing independent of server culture");
        Console.WriteLine(passed + " offline C# checks passed. This is NOT a live Hubtel or Web Forms end-to-end test.");
    }
}
