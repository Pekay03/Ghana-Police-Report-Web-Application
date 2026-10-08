// Exercises the actual scoped ASPX function using a small DOM stub, not a browser/IIS.
const fs = require("fs");
const path = require("path");
const vm = require("vm");
const assert = require("assert");
const root = path.resolve(__dirname, "..");
const markup = fs.readFileSync(path.join(root, "SubmitApplication.aspx"), "utf8");
const start = markup.indexOf('var lastIdentityType = "";');
const end = markup.indexOf("/* =====================================================\n           DATE LIMITS", start);
assert(start >= 0 && end > start, "Locate actual upload handler");
const nodes = {};
const inputs = {};
for (const name of ["ghanaCardFront", "ghanaCardBack", "identityDocument", "identityDocumentBack"]) {
    inputs[name] = { value: "", required: false, disabled: false };
    nodes[name + "Name"] = { textContent: "" };
}
for (const id of ["ghanaCardFrontCard", "ghanaCardBackCard", "identityDocumentCard",
    "identityDocumentBackCard", "identityDocumentTitle", "identityDocumentDescription",
    "identityDocumentBackTitle"]) nodes[id] = { style: { display: "none" }, textContent: "" };
const selector = { value: "" };
const context = vm.createContext({
    document: { getElementById: id => nodes[id] || null },
    getFormField: name => name === "nationalIdType" ? selector : null,
    getInput: name => inputs[name] || null
});
vm.runInContext(markup.substring(start, end), context);
let passed = 0;
function check(condition, name) { assert(condition, name); passed++; }
for (const [type, enabled] of [
    ["Ghana Card", ["ghanaCardFront", "ghanaCardBack"]],
    ["Voter ID", ["identityDocument", "identityDocumentBack"]],
    ["Driver's Licence", ["identityDocument", "identityDocumentBack"]],
    ["Passport", ["identityDocument"]],
    ["", []]
]) {
    selector.value = type;
    context.syncIdentityUploads();
    for (const name of Object.keys(inputs)) {
        const needed = enabled.includes(name);
        check(inputs[name].required === needed, type + ": required " + name);
        check(inputs[name].disabled === !needed, type + ": disabled " + name);
    }
    for (const [card, input] of [
        ["ghanaCardFrontCard", "ghanaCardFront"], ["ghanaCardBackCard", "ghanaCardBack"],
        ["identityDocumentCard", "identityDocument"], ["identityDocumentBackCard", "identityDocumentBack"]
    ]) check(nodes[card].style.display === (enabled.includes(input) ? "" : "none"), type + ": visibility " + card);
}
selector.value = "Voter ID";
context.syncIdentityUploads();
inputs.identityDocument.value = "previous-front.png";
inputs.identityDocumentBack.value = "previous-back.png";
selector.value = "Driver's Licence";
context.syncIdentityUploads();
check(inputs.identityDocument.value === "", "changed ID clears prior front file");
check(inputs.identityDocumentBack.value === "", "changed ID clears prior back file");
console.log(passed + " upload-visibility and required/disabled-state checks passed.");
