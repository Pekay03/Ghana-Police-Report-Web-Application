"""Static contracts only: no database, application records, credentials or provider calls."""
import re
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
passed = 0


def check(condition, name):
    global passed
    if not condition:
        raise AssertionError(name)
    passed += 1


project = ET.parse(ROOT / "Police Background System Check.csproj")
ns = {"m": "http://schemas.microsoft.com/developer/msbuild/2003"}
includes = {element.get("Include").replace("\\", "/")
            for tag in ("Compile", "Content")
            for element in project.findall(".//m:" + tag, ns)}

for name in ("AdminOperations", "IdentityReview"):
    markup = (ROOT / (name + ".ascx")).read_text(encoding="utf-8-sig")
    code = (ROOT / (name + ".ascx.cs")).read_text(encoding="utf-8-sig")
    if name == "AdminOperations":
        code += (ROOT / "AdminOperations.Workspaces.cs").read_text()
    designer = (ROOT / (name + ".ascx.designer.cs")).read_text(encoding="utf-8-sig")
    clean = re.sub(r"<%.*?%>", "binding", markup, flags=re.S)
    clean = re.sub(r"<style.*?</style>", "", clean, flags=re.S)
    # Directives aren't HTML content; strip their placeholder before parsing.
    tree = ET.fromstring('<root xmlns:asp="urn:asp" xmlns:uc="urn:uc">' + clean + "</root>")
    template_ids = {child.get("ID") for element in tree.iter()
                    if element.tag.endswith("ItemTemplate")
                    for child in element.iter() if child.get("ID")}
    identifiers = []
    for element in tree.iter():
        identifier = element.get("ID")
        if not identifier:
            continue
        identifiers.append(identifier)
        if identifier in template_ids:  # Repeater children belong to their naming container.
            continue
        check(bool(re.search(r"\b" + re.escape(identifier) + r"\s*;", designer)),
              name + ": designer declaration " + identifier)
        for attribute in ("OnClick", "OnRowCommand", "OnPageIndexChanging", "OnRowDataBound"):
            handler = element.get(attribute)
            if handler:
                check(bool(re.search(r"\bvoid\s+" + handler + r"\s*\(", code)),
                      name + ": handler " + handler)
    check(len(identifiers) == len(set(identifiers)), name + ": no duplicate IDs")
    for extension in (".ascx", ".ascx.cs", ".ascx.designer.cs"):
        check(name + extension in includes, name + extension + ": included in project")

review = (ROOT / "IdentityReview.ascx.cs").read_text()
operations = (ROOT / "AdminOperations.ascx.cs").read_text()
submit = (ROOT / "SubmitApplication.aspx").read_text()
register = (ROOT / "Register.aspx").read_text()
check("connection.BeginTransaction()" in review and "transaction.Commit()" in review,
      "review and audit transaction")
check("INSERT INTO verification_log" in review and "INSERT INTO account_audit_logs" in review,
      "review uses existing storage")
check(not re.search(r"\b(ALTER|CREATE|DROP)\s+TABLE\b", review + operations, re.I),
      "no schema changes")
check("UPDATE applications" not in review and "UPDATE identity_verifications" not in review,
      "document decisions do not alter application status or registry comparisons")
check('decision != "Verified" && String.IsNullOrWhiteSpace(reason)' in review,
      "Flag/Reject mandatory reason")
check("StaffAccess.CheckUser(connection, transaction" in review,
      "reviewer rechecked inside transaction")
check('identitySelector.addEventListener("change", syncIdentityUploads)' in submit,
      "ID change event uses scoped handler")
check('onchange="syncIdentityUploads()"' not in submit, "no inaccessible inline ID callback")
check("assessmentStaffDetails" in register and "Staff profile saving is deferred" in register,
      "staff fields explicitly deferred")
check("THEN 'Failed / cancelled'" in operations and "THEN 'Pending / unresolved'" in operations,
      "existing Hubtel payment states preserved")
check("ResetTokenHash" not in operations and "ResetTokenHash" not in review,
      "no reset-token exposure")
check("HUBTEL_CLIENT_SECRET" not in (ROOT / "AdminOperations.ascx").read_text(),
      "no provider credentials in new module UI")
print(str(passed) + " static markup, handler, project and storage checks passed.")
