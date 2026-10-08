POLICE BACKGROUND SYSTEM CHECK — INTEGRATED SOURCE AND DEPLOYMENT

This bundle starts from your latest WORKING FINAL WORK project.
No existing C# application or test source is changed. No package version is
changed. All existing application markup is retained except one equivalent
FAQ CSS compatibility adjustment. SQL/data/uploads are not included or migrated.

PACKAGE CONTENTS
Source/                   Complete Visual Studio project and solution.
MonsterASP-Website.zip    Compiled website contents for upload into /wwwroot.
Verification/             Baseline-preservation and configuration check results.

LOCAL VISUAL STUDIO — DO THIS ONCE
1. Keep your current working project as a backup. Extract THIS whole bundle into
   a NEW empty folder; do not mix it with either earlier MonsterASP ZIP or paste
   a containing folder into another project folder.
2. Copy Web.Local.config and Hubtel.Private.config from your working project
   into the new Source folder, replacing the SAFE placeholders. This preserves
   your working private setup without editing the main Web.config or running a
   PowerShell helper. Do not share those private files.
3. Open Source/Police Background System Check.sln, restore NuGet packages, then
   Clean Solution and Rebuild Solution. This remains .NET Framework 4.8 Web Forms.
   Use Visual Studio ASP.NET/Web development tooling, not dotnet SDK publishing.
4. Run with the configured HTTPS IIS Express URL. Existing role, review,
   document-access and certificate rules are unchanged.

Web.Production.config now physically exists and can be opened in Visual Studio.
It is NOT required for local Debug operation: local operation uses Web.Local.config.
Its placeholder values are NOT actual hosting connection details.

MONSTERASP DEPLOYMENT
1. Back up your existing site and database. Do not delete existing App_Data or
   uploaded-document directories, and do not run any database migration.
2. Select .NET Framework 4.8 / managed CLR v4 hosting and use HTTPS.
3. Configure Source/Web.Production.config PRIVATELY with the actual hosting
   MySQL host/database/account. Upload that configured file to
   /wwwroot/Web.Production.config BEFORE starting the published application.
   Do not use a developer PC's 127.0.0.1 address on a remote host.
   Main Web.config is already wired correctly and needs no credential edits.
4. Upload MonsterASP-Website.zip using the hosting File Manager, then Unzip
   directly into /wwwroot. This archive is already compiled. Do NOT submit the
   source solution to MonsterASP's modern dotnet source/Git builder.
5. The runtime ZIP deliberately omits private files, so extraction does not
   replace existing Web.Production.config, Web.Local.config or Hubtel.Private.config.
   Preserve existing host-private credentials and upload directories.
6. Provision authorised provider credentials separately if Hubtel is enabled.
   Provider payment and SMS acceptance remain pending; upload success alone
   is not a paid-transaction or handset-delivery result.
7. Check landing page, citizen login/submission, officer review, administrator
   functions, restricted documents and certificate eligibility on the target host.

REBUILD FOR A LATER RELEASE
The Source project includes the MonsterASP folder-publish profile.
Use Windows Visual Studio's Publish > MonsterASP, or full Visual Studio
MSBuild.exe on the .csproj with Configuration=Release, DeployOnBuild=true,
PublishProfile=MonsterASP. ZIP the published folder CONTENTS, not the project.
Private configurations are excluded and must already be provisioned at the host.

WHAT THE WARNINGS ACTUALLY MEANT
- Root xmlns:ns0: ASP.NET rejected the earlier packaged Web.config. This also
  caused the many unrecognised asp/uc tags and unknown-control warnings.
  The new root is plain <configuration>, with canonical runtime bindings.
- Dependency conflicts: the requested redirect versions/tokens are preserved
  and MSBuild explicitly reads Web.config during reference resolution.
- sameSite editor schema: HttpOnly/Secure/Lax defaults are unchanged and live in
  the supported external CookieSecurity.policy section. Auth/session Lax and
  secure-cookie settings remain enabled. The policy is published with the site.
- packages element schema: a supplied local XSD validates the unchanged NuGet
  package list. No namespace is added to the packages themselves.
- WebKit CSS pseudo-element: replaced by a standard display:block summary style,
  retaining the native FAQ disclosure and custom plus/minus presentation.
- Missing production file: a real, editable, safe-placeholder file is now included.

VERIFICATION LIMITS
The included results check baseline source hashes, C# compilation against
Microsoft .NET Framework 4.8 references, control/handler class references,
configuration files, cookie security, schema validity, redirects and ZIP layout.
This Linux environment cannot reproduce your Windows Visual Studio designer,
run Windows IIS, or access your hosting/database/provider accounts. It cannot
promise that those external environments will never produce another issue.
No Windows/IIS/live-database/provider pass is fabricated.
