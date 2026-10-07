"""Offline dashboard scope and wiring contracts; no Windows/IIS/database/provider execution."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
checks = 0

def text(name):
    return (root / name).read_text(encoding="utf-8-sig")

def check(condition, label):
    global checks
    assert condition, label
    checks += 1

for name, extension in (("AdminDashboard", "aspx"), ("AdminOperations", "ascx"),
                        ("IdentityReview", "ascx"), ("StaffProfiles", "ascx"), ("SmsTracking", "ascx")):
    markup = text(name + "." + extension)
    code = text(name + "." + extension + ".cs")
    if name == "AdminOperations":
        code += text("AdminOperations.Workspaces.cs")
    designer = text(name + "." + extension + ".designer.cs")
    # Controls inside Repeater templates belong to the template's naming container.
    outside = re.sub(r"<ItemTemplate>.*?</ItemTemplate>", "", markup, flags=re.S)
    identifiers = [identifier for kind, identifier in
                   re.findall(r'<(?:asp|uc):(\w+)\b[^>]*\bID="(\w+)"', outside) if kind != "Content"]
    check(len(identifiers) == len(set(identifiers)), name + ": unique non-template control IDs")
    for identifier in identifiers:
        check(bool(re.search(r"\b" + identifier + r"\s*;", designer)), name + " designer " + identifier)
    for handler in re.findall(r'\bOn(?:Click|RowCommand|RowDataBound|PageIndexChanging|SelectedIndexChanged)="(\w+)"', markup):
        check(bool(re.search(r"\bvoid\s+" + handler + r"\s*\(", code)), name + " handler " + handler)

operations = text("AdminOperations.ascx.cs") + text("AdminOperations.Workspaces.cs")
data = text("AdminWorkspaceData.cs")
for parameter in ("@Purpose", "@Officer", "@Assignment", "@Processing", "@Target"):
    check('AddWithValue("' + parameter + '"' in operations, parameter + " bound, not interpolated")
for module in ("cases", "security", "payments", "analytics"):
    check('SelectedModule == "' + module + '"' in operations, module + " selected-only query path")
check("PERCENTILE_CONT(0.5)" in data and "ReviewedAt>=DateSubmitted" in data, "median only valid final timestamps")
check('"AdminProcessingTargetHours"' in data and "? (int?)hours : null" in data, "no assumed processing threshold")
check("NOT EXISTS" in data and "UnassignedAt IS NULL" in data, "unassigned from actual active assignments")
check("pending approval" in data and "[LOCAL INDIVIDUAL DOCUMENT REVIEW:%" in data,
      "pending local-review queue includes existing document-event formats")
check(not re.search(r"\b(?:INSERT\s+INTO|UPDATE|DELETE\s+FROM|CREATE\s+TABLE|ALTER\s+TABLE|DROP\s+TABLE)\b",
                    data + text("AdminOperations.Workspaces.cs"), re.I), "new query helpers are read-only")
check("l.IPAddress,l.UserAgent" in operations, "only known recorded audit context used")
check("no device identity or separate result is inferred" in text("AdminOperations.ascx"), "no invented event results")
check("FocusedStaffAccount" in text("UserManagement.ascx.cs") and "UserID=@FocusedUser" in text("UserManagement.ascx.cs"),
      "staff account actions use exact focused identity")
check("Navigation can suggest an officer" in text("ApplicationManagement.ascx.cs"),
      "officer navigation never writes an assignment")
check("Convert.ToBoolean(row[\"IsActive\"])" in operations and "button.Enabled = false" in operations,
      "inactive staff assignment action disabled")
sms = text("SmsTracking.ascx.cs")
check("Provider accepted" in sms and "s.SentAt AS AcceptedAt" in sms, "honest provider acceptance timestamp")
check("RIGHT(s.PhoneNumber,4)" in sms and "DeliveredAt=" not in sms, "masked recipients and no delivery writes")
check("COALESCE(p.TransactionID,'') NOT LIKE 'HBT-%'" in operations, "missing transaction reference is unconfirmed legacy")
ns = {"m": "http://schemas.microsoft.com/developer/msbuild/2003"}
project = ET.parse(root / "Police Background System Check.csproj")
compiled = {e.get("Include") for e in project.findall(".//m:Compile", ns)}
check({"AdminWorkspaceData.cs", "AdminOperations.Workspaces.cs"} <= compiled, "new support sources compiled")
print(f"{checks} offline admin workspace contracts passed. Windows/IIS and live database checks remain required.")
