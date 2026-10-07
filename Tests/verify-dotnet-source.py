"""Linux offline source check using Microsoft net48 metadata, not Mono framework metadata.

Requires Python 3, Mono/csc and network access to NuGet for reference packages.
No Windows/MSBuild, ASPX execution, database, migration, secrets or provider calls.
Downloads/restores verification dependencies ONLY under the requested scratch directory.
"""
import concurrent.futures
import os
from pathlib import Path
import shutil
import subprocess
import sys
import urllib.request
import xml.etree.ElementTree as ET
import zipfile

root = Path(__file__).resolve().parents[1]
scratch = Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/police-dotnet-source-check").resolve()
scratch.mkdir(parents=True, exist_ok=True)
ns = {"m": "http://schemas.microsoft.com/developer/msbuild/2003"}
project = ET.parse(root / "Police Background System Check.csproj")
packages = {}
references = []
for element in project.findall(".//m:Reference", ns):
    hint = element.find("m:HintPath", ns)
    if hint is None:
        references.append((element.get("Include").split(",")[0], None))
    else:
        relative = hint.text.replace("\\", "/").split("../packages/", 1)[1]
        folder, file = relative.split("/", 1)
        references.append((folder, file))
for package in ET.parse(root / "packages.config").getroot():
    folder = package.get("id") + "." + package.get("version")
    if any(name == folder for name, file in references):
        packages[folder] = (package.get("id"), package.get("version"))
packages["Microsoft.NETFramework.ReferenceAssemblies.net48.1.0.3"] = (
    "Microsoft.NETFramework.ReferenceAssemblies.net48", "1.0.3")


def restore(item):
    folder, (name, version) = item
    destination = scratch / folder
    if (destination / ".restored").is_file():
        return
    archive = scratch / (folder + ".nupkg")
    url = ("https://api.nuget.org/v3-flatcontainer/" + name.lower() + "/" + version.lower() +
           "/" + name.lower() + "." + version.lower() + ".nupkg")
    with urllib.request.urlopen(url, timeout=90) as response, archive.open("wb") as out:
        shutil.copyfileobj(response, out)
    with zipfile.ZipFile(archive) as package:
        package.extractall(destination)
    (destination / ".restored").touch()


with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
    list(pool.map(restore, packages.items()))
framework = scratch / "Microsoft.NETFramework.ReferenceAssemblies.net48.1.0.3/build/.NETFramework/v4.8"
assert (framework / "mscorlib.dll").is_file(), "Missing Microsoft .NET Framework 4.8 reference assemblies"
binary = scratch / "bin"
binary.mkdir(exist_ok=True)
assemblies = [framework / "mscorlib.dll", framework / "System.Configuration.dll"]
for name, file in references:
    path = scratch / name / file if file else framework / (name + ".dll")
    assert path.is_file(), "Missing declared assembly: " + str(path)
    assemblies.append(path)
    if file:
        shutil.copy2(path, binary / path.name)
arguments = ["csc", "-nologo", "-nostdlib+", "-langversion:7.3", "-define:DEBUG,TRACE"]
arguments += ["-r:" + str(path) for path in dict.fromkeys(assemblies)]
sources = [root / element.get("Include").replace("\\", "/")
           for element in project.findall(".//m:Compile", ns)]
assembly = binary / "PoliceBackgroundCheckSystem.dll"
subprocess.run(arguments + ["-target:library", "-out:" + str(assembly)] +
               [str(path) for path in sources], check=True)
print(str(len(sources)) + " project C# files compiled against Microsoft .NET Framework 4.8 references.", flush=True)
env = dict(os.environ, MONO_PATH=str(binary))
for name in ("ModuleContractChecks", "HubtelContractChecks", "IndividualDocumentReviewChecks", "AdminFeatureContractChecks"):
    extra = []
    if name == "IndividualDocumentReviewChecks":
        # Compile actual policy sources into the harness to access internal helpers.
        extra = [str(root / "IndividualDocumentReviewStore.cs"), str(root / "ApplicationDocumentCatalog.cs")]
    executable = binary / (name + ".exe")
    project_reference = [] if extra else ["-r:" + str(assembly)]
    subprocess.run(arguments + project_reference + ["-out:" + str(executable),
                   str(root / "Tests" / (name + ".cs"))] + extra, check=True)
    subprocess.run(["mono", str(executable), str(assembly)], env=env, check=True)
for name in ("check-module-markup.py", "check-individual-review-contracts.py", "check-admin-feature-contracts.py", "check-admin-workspace-contracts.py"):
    subprocess.run([sys.executable, str(root / "Tests" / name)], check=True)
subprocess.run(["node", str(root / "Tests/check-upload-visibility.js")], check=True)
subprocess.run(["node", str(root / "Tests/check-admin-navigation.js")], check=True)
print("Offline verification complete. Windows/IIS/MySQL execution remains required.", flush=True)
