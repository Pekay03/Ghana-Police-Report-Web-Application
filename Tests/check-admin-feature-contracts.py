"""Offline integration contracts; NOT SQL execution, ASPX rendering or real-record testing."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
passed = 0

def check(value, label):
    global passed
    assert value, label
    passed += 1

def text(name):
    return (root / name).read_text(encoding="utf-8-sig")

ns = {"m": "http://schemas.microsoft.com/developer/msbuild/2003"}
project = ET.parse(root / "Police Background System Check.csproj")
compiled = {e.get("Include") for e in project.findall(".//m:Compile", ns)}
content = {e.get("Include") for e in project.findall(".//m:Content", ns)}
for control in ("ApplicationManagement", "StaffProfiles", "SmsTracking", "AdminOperations"):
    markup = text(control + ".ascx")
    code = text(control + ".ascx.cs")
    if control == "AdminOperations":
        code += text("AdminOperations.Workspaces.cs")
    designer = text(control + ".ascx.designer.cs")
    check(control + ".ascx" in content, control + " content")
    check(control + ".ascx.cs" in compiled, control + " code registration")
    check(control + ".ascx.designer.cs" in compiled, control + " designer registration")
    for identifier in re.findall(r'<(?:asp|uc):\w+\b[^>]*\bID="(\w+)"', markup):
        check(re.search(r"\b" + identifier + r"\s*;", designer), "Designer declaration: " + identifier)
    for handler in re.findall(r'\bOn(?:Click|RowCommand|PageIndexChanging|SelectedIndexChanged|RowDataBound)="(\w+)"', markup):
        check(re.search(r"\b" + handler + r"\s*\(", code), "Handler: " + handler)
check("AdminWorkflowService.cs" in compiled and "SmsDeliveryTracking.cs" in compiled, "Shared services registered")
service = text("AdminWorkflowService.cs")
for token in ("ValidatePost(context, token)", "ORDER BY UserID FOR UPDATE",
              "StaffAccess.CheckUser(c, t, actor, true", "Only pending applications",
              "Priority changes are restricted to pending", "UnassignedAt=NOW(6)",
              "ApplicationReassigned", "ApplicationUnassigned", "AppendWorkflow(c, t",
              "Audit(c, t", "t.Commit()", "LockCertificateApplication", "PaymentVerified=1",
              "TransactionID LIKE 'HBT-%'"):
    check(token in service, token)
check(not re.search(r"(UPDATE|DELETE FROM)\s+application_workflow_history", service, re.I),
      "Append-only workflow writes")
migration = text("AdminFeatures.mysql.sql")
check("REFERENCES users(ID)" not in migration and "REFERENCES applications(ID)" not in migration,
      "Inspected relationship keys, not stale dump keys")
for table in ("application_assignments", "application_workflow_history", "sms_delivery_logs"):
    check("CREATE TABLE IF NOT EXISTS " + table in migration, table + " additive table")
check("GENERATED ALWAYS AS" in migration and "UNIQUE KEY ux_pbcs_active_assignment" in migration,
      "Database-enforced single active assignment")
check(not re.search(r"\b(?:INSERT INTO|DELETE FROM|TRUNCATE TABLE)\b", migration, re.I), "No data seeding/deletion")
check("CreatedAt DATETIME NULL DEFAULT NULL" in migration, "Legacy creation dates remain unknown")
check("ALTER COLUMN CreatedAt SET DEFAULT CURRENT_TIMESTAMP" in migration, "Future creation timestamp")
check("ADD COLUMN LastLoginAt" not in migration, "No duplicate existing last-login field")
for module in ("applications", "identity", "officers", "cases", "security", "analytics", "notifications", "payments"):
    check('module=' + module in text("AdminDashboard.aspx"), "Dedicated route: " + module)
dashboard = text("AdminDashboard.aspx")
module_lookup = re.search(r"function gaGetModuleInfo\(.*?\n    }", dashboard, re.S)
expected_modules = {"applications", "identity", "officers", "cases", "security",
                    "analytics", "notifications", "payments"}
module_cases = set(re.findall(r"case '([a-z]+)': return gaModuleInfo\.([a-z]+);",
                              module_lookup.group(0))) if module_lookup else set()
check(module_cases == {(module, module) for module in expected_modules},
      "Explicit, complete TypeScript-safe module lookup")
check(not re.search(r"\bgaModuleInfo\s*\[", dashboard),
      "No dynamic module metadata indexing")
check('SelectedModule != module' in text("AdminOperations.ascx.cs"), "Unselected grid queries do not execute")
check('OnRowCommand="gvOfficers_RowCommand"' in text("AdminOperations.ascx"), "Officer profile action")
check('AND (@Priority=\'All\' OR Priority=@Priority)' in text("AdminOperations.ascx.cs"), "Priority filter")
for name, action in (("SubmitApplication.aspx.cs", "ApplicationSubmitted"),
                     ("IdentityReview.ascx.cs", '"DocumentSet" + decision'),
                     ("VettingDashboard.aspx.cs", "ApplicationApproved"),
                     ("VettingDashboard.aspx.cs", "ApplicationRejected"),
                     ("SubmitApplication.aspx.cs", "CertificateIssued"),
                     ("VettingDetails.aspx.cs", "CertificateIssued")):
    check(action in text(name) and "AppendWorkflow" in text(name), name + " workflow hook")
tracking = text("SmsDeliveryTracking.cs")
sms = text("HubtelSmsService.cs")
check(sms.index("SmsDeliveryTracking.Begin") < sms.index("SendMessage(recipient"), "Persist pending before provider call")
check("SmsDeliveryTracking.Submitted" in sms and "SmsDeliveryTracking.Failed" in sms, "Record outcomes")
check("!(ex is ProviderRejectedException)" in sms and "hasStatus && status != 0" in sms,
      "Explicit provider rejection is Failed, malformed acknowledgement remains Unknown")
check("'Pending'" in tracking and '"Unknown"' in tracking and '"Submitted"' in tracking, "Honest SMS states")
check("DeliveredAt=" not in tracking, "No fabricated delivery confirmation")
check("content" not in tracking.lower() and "otp" not in tracking.lower(), "No SMS body/OTP storage")
check("RIGHT(s.PhoneNumber,4)" in text("SmsTracking.ascx.cs"), "Masked recipient display")
print(f"{passed} offline admin-feature source/markup/migration contracts passed. Real MySQL/IIS/Hubtel remains untested.")
