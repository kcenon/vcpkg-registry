"""Print the README "Available Ports" table from the registry itself.

Reads versions/baseline.json (the version a consumer resolves) and each
ports/<name>/vcpkg.json (description and port-version), checks that the two
agree, and prints a Markdown table. Paste the output into README.md.

Usage: python3 scripts/port_table.py
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VERSION_KEYS = ("version-semver", "version", "version-string", "version-date")


def main() -> int:
    baseline = json.loads((ROOT / "versions" / "baseline.json").read_text(encoding="utf-8"))["default"]
    rows = []
    for name, entry in baseline.items():  # baseline order follows the dependency tiers
        manifest = json.loads((ROOT / "ports" / name / "vcpkg.json").read_text(encoding="utf-8"))
        version = next(manifest[key] for key in VERSION_KEYS if key in manifest)
        port_version = manifest.get("port-version", 0)
        if (version, port_version) != (entry["baseline"], entry["port-version"]):
            print(f"{name}: ports/ has {version}#{port_version} but versions/baseline.json has "
                  f"{entry['baseline']}#{entry['port-version']}", file=sys.stderr)
            return 1
        description = manifest.get("description", "")
        if isinstance(description, list):
            description = " ".join(description)
        rows.append(f"| {name} | {version} | {port_version} | {description.replace('|', '/')} |")
    print("| Package | Version | Port version | Description |")
    print("|---------|---------|--------------|-------------|")
    print("\n".join(rows))
    return 0


if __name__ == "__main__":
    sys.exit(main())
