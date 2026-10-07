// Runs the actual navigation function with a minimal DOM, not a browser or Web Forms host.
const fs = require("fs");
const path = require("path");
const vm = require("vm");
const assert = require("assert");
const source = fs.readFileSync(path.join(__dirname, "..", "AdminDashboard.aspx"), "utf8");
for (const match of source.matchAll(/<script\b[^>]*>([\s\S]*?)<\/script>/gi))
    new vm.Script(match[1].replace(/<%[\s\S]*?%>/g, "offline"), { filename: "AdminDashboard.inline.js" });
const start = source.indexOf("function gaSwitchTab");
const end = source.indexOf("\n    }\n", start);
assert(start >= 0 && end > start, "actual navigation function found");
const code = source.slice(start, end + 7);
let passed = 0;
function navigate(search, tab, module) {
    let url = "";
    const context = vm.createContext({
        document: { querySelectorAll: () => [], querySelector: () => null, getElementById: () => null },
        window: { location: { pathname: "/AdminDashboard.aspx", search },
            history: { replaceState: (state, title, next) => { url = next; } } },
        sessionStorage: { setItem: () => {} },
        URLSearchParams,
        encodeURIComponent,
        gaGetModuleInfo: name => name ? { title: name, sub: "" } : null,
        gaCurrentModule: () => "applications",
        gaGetPageInfo: name => ({ title: name, sub: "" })
    });
    vm.runInContext(code, context);
    context.gaSwitchTab(tab, module);
    return new URL(url, "https://offline.invalid").searchParams;
}
function check(condition, label) { assert(condition, label); passed++; }
const applications = navigate("?tab=operations&module=applications&officer=14&assignment=Unassigned&priority=Urgent&processing=Open&assignTo=14", "operations", "applications");
for (const [key, value] of [["officer", "14"], ["assignment", "Unassigned"], ["priority", "Urgent"], ["processing", "Open"], ["assignTo", "14"]])
    check(applications.get(key) === value, "preserve " + key + " for later server postback");
check(applications.get("tab") === "operations" && applications.get("module") === "applications", "correct workspace");
const identity = navigate("?tab=operations&module=identity&reference=APP_fixture", "operations", "identity");
check(identity.get("reference") === "APP_fixture", "preserve review reference");
const account = navigate("?tab=users&staff=14", "users", "");
check(account.get("staff") === "14", "preserve focused staff account");
const payments = navigate("?tab=operations&module=applications&assignTo=14&officer=14", "operations", "payments");
check(!payments.has("assignTo") && !payments.has("officer"), "no cross-module assignment context");
const overview = navigate("?tab=users&staff=14", "overview", "");
check(!overview.has("staff") && overview.get("tab") === "overview", "no unrelated account context");
console.log(passed + " offline admin navigation checks passed; inline JavaScript syntax checked.");
