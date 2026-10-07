"""Offline source contracts: no database, credentials, HTTP or provider requests."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
code = (root / "VettingDashboard.aspx.cs").read_text()
store = (root / "IndividualDocumentReviewStore.cs").read_text()
admin = (root / "AdminDashboard.aspx.cs").read_text()
markup = (root / "VettingDashboard.aspx").read_text()
designer = (root / "VettingDashboard.aspx.designer.cs").read_text()
save = code.split("protected void btnSaveDocumentReview_Click", 1)[1].split(
    "private bool AreRequiredIdentityDocumentsAccepted", 1)[0]
checks = 0


def check(value, name):
    global checks
    assert value, name
    checks += 1


check("INSERT INTO verification_log" in save and "INSERT INTO account_audit_logs" in save, "existing storage")
check("transaction.Commit()" in save and "transaction.Rollback()" in save, "atomic review and audit")
check(save.index("INSERT INTO verification_log") < save.index("INSERT INTO account_audit_logs") <
      save.index("transaction.Commit()"), "no success before both writes")
check(not re.search(r"\b(?:INSERT\s+INTO|UPDATE|DELETE\s+FROM)\s+identity_document_reviews\b",
                    code + store + admin, re.I), "legacy table read only")
check(not re.search(r"\b(?:CREATE|ALTER|DROP)\s+TABLE\b", code + store + admin, re.I), "no DDL")
check("FROM identity_document_reviews" in store and "ex.Number != 1146" in store,
      "only genuinely absent legacy table is optional")
check("FROM identity_document_reviews" not in code + admin, "no unconditional legacy query outside store")
check("LIMIT 100" not in store, "complete history for latest-state decisions")
check("reason.Length < 5 || reason.Length > 1000" in save, "server enforces review reasons")
check("LockPendingApplication(connection, transaction, applicationId)" in save, "pending and current officer lock")
check("IndividualDocumentReviewStore.Encode" in save, "structured notes not delimiter-dependent reasons")
check("ReviewerUserID" in store and "NOW()" in save, "persist actor and database time")
check("UPDATE applications" not in save and "UPDATE identity_verifications" not in save, "review leaves status/comparison unchanged")
check("AreRequiredIdentityDocumentsAccepted(connection, transaction, applicationId)" in code,
      "final approval reads history on locked transaction")
lock = code.split("private bool LockPendingApplication", 1)[1].split("private void InsertAuditLog", 1)[0]
check("FROM users" in lock and "FOR UPDATE" in lock and "IsActive" in lock, "current actor checked within mutation")
check('role != "policeofficer"' in lock and 'role != "officer"' in lock and
      'role != "police"' in lock and 'role != "vetting"' in lock, "administrators cannot make final decisions")
check("GetRequiredDocumentTypes(idType)" in save and "FindApplicationDocumentPath" in save,
      "only submitted required document selectable")
check("RequireOfficerAuthentication()" in save, "officer session required")
check("IndividualDocumentReviewStore.Load" in admin, "admin existing timeline reads merged history")
for name in ("ddlDocumentReviewType", "ddlDocumentReviewDecision", "txtDocumentReviewReason",
             "btnSaveDocumentReview", "lblDocumentReviewMessage", "gvIdentityReviewHistory"):
    check(len(re.findall(r'ID="' + name + '"', markup)) == 1 and
          bool(re.search(r"\b" + name + r"\s*;", designer)), "markup/designer contract: " + name)
check('OnClick="btnSaveDocumentReview_Click"' in markup, "save event contract")
for field in ("DocumentTypeDisplay", "DecisionDisplay", "ReviewReason", "ReviewerUserID",
              "ReviewerName", "ReviewedAtDisplay", "StorageSource"):
    check('DataField="' + field + '"' in markup and 'table.Columns.Add("' + field + '"' in code,
          "history field contract: " + field)
check('ApplicationDocument.ashx' in code, "protected document preview retained")
global_code = (root / "Global.asax.cs").read_text()
check("ViewStateUserKey" in global_code and "Session" in global_code, "existing session-bound postback CSRF protection")
ns = {"m": "http://schemas.microsoft.com/developer/msbuild/2003"}
project = ET.parse(root / "Police Background System Check.csproj")
includes = [e.get("Include").replace("\\", "/") for tag in ("Compile", "Content")
            for e in project.findall(".//m:" + tag, ns)]
check("IndividualDocumentReviewStore.cs" in includes, "helper in project")
for file in includes:
    check((root / file).is_file(), "project file exists: " + file)
print(str(checks) + " offline individual-review source/markup/project contract checks passed.")
