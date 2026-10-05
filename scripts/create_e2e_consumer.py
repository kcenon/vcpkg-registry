"""Create a source-tree-independent manifest consumer of the published Git registry."""
import json
import os
from pathlib import Path
import shutil
import sys

root = Path(__file__).resolve().parents[1]
destination = Path(sys.argv[1])
port = os.environ["PORT"]
shutil.copytree(root / "tests" / "e2e" / port, destination)
(destination / "vcpkg.json").write_text(json.dumps({
    "name": "registry-external-consumer", "version-string": "0",
    "dependencies": [port],
}, indent=2) + "\n")
(destination / "vcpkg-configuration.json").write_text(json.dumps({
    "default-registry": {"kind": "builtin", "baseline": os.environ["VCPKG_BUILTIN_BASELINE"]},
    "registries": [{"kind": "git", "repository": "https://github.com/kcenon/vcpkg-registry.git",
                    "baseline": os.environ["REGISTRY_COMMIT"],
                    "reference": os.environ["REGISTRY_COMMIT"], "packages": ["kcenon-*"]}],
}, indent=2) + "\n")
