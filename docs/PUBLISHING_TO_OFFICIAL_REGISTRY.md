# Publishing to the Official vcpkg Registry

This guide documents how to publish kcenon ecosystem ports to the
[official Microsoft vcpkg registry](https://github.com/microsoft/vcpkg) (`microsoft/vcpkg`),
making them available to all vcpkg users worldwide without any custom registry configuration.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Step-by-Step Process](#step-by-step-process)
- [Portfile Requirements](#portfile-requirements)
- [PR Review Checklist](#pr-review-checklist)
- [kcenon-Specific Considerations](#kcenon-specific-considerations)
- [Maintenance](#maintenance)
- [References](#references)

---

## Overview

### Current Setup: Custom Git Registry

The kcenon ecosystem currently distributes ports through a custom Git registry:

```
# Consumer must explicitly configure the registry
# vcpkg-configuration.json
{
  "registries": [{
    "kind": "git",
    "repository": "https://github.com/kcenon/vcpkg-registry.git",
    "baseline": "<commit-sha>",
    "packages": ["kcenon-*"]
  }]
}
```

### Target: Official vcpkg Curated Registry

Publishing to `microsoft/vcpkg` enables zero-configuration installation:

```bash
# No vcpkg-configuration.json needed
vcpkg install kcenon-common-system
```

### Key Differences

| Aspect | Custom Registry | Official Registry |
|--------|:-:|:-:|
| Consumer setup | Requires `vcpkg-configuration.json` | None (built-in) |
| Discoverability | Must know the registry URL | `vcpkg search` finds it |
| Release cycle | Immediate (self-managed) | Gated by Microsoft PR review |
| Control | Full | Shared with vcpkg maintainers |
| CI testing | Self-hosted | Microsoft-hosted (all triplets) |

### Recommended Strategy: Dual Registry

Maintain **both** registries simultaneously:

- **Custom registry** — for rapid iteration, pre-release versions, and internal ecosystem use
- **Official registry** — for stable, production-ready releases

---

## Prerequisites

### Project Maturity Requirements

The official registry enforces strict eligibility criteria:

1. **6-month maturity rule** — At least one of:
   - The project has a release that is at least **6 months old**
   - The project demonstrates at least **6 months of active public development**
   - The project is an official component of another qualifying project

2. **Active maintenance** — The project must be actively maintained:
   - Maintainers are responsive and reachable
   - The project is not archived or abandoned
   - Meaningful changes are being made

3. **Platform testing** — The port must build successfully on at least one
   [official vcpkg triplet](https://learn.microsoft.com/en-us/vcpkg/concepts/triplets):
   - `x64-windows`
   - `x64-linux`
   - `x64-osx`

4. **Open-source license** — The project must have a recognized license (kcenon uses BSD-3-Clause)

### Tooling

- [Git](https://git-scm.com/)
- [vcpkg](https://github.com/microsoft/vcpkg) (cloned and bootstrapped)
- A GitHub account with a fork of `microsoft/vcpkg`

---

## Step-by-Step Process

### Step 1: Fork the vcpkg Repository

```bash
# On GitHub: fork https://github.com/microsoft/vcpkg
# Then add your fork as a remote
cd /path/to/vcpkg
git remote add myfork https://github.com/<your-username>/vcpkg.git
git remote -v  # Verify myfork is listed
```

### Step 2: Create a Topic Branch

```bash
git fetch origin
git checkout -b add-kcenon-common-system origin/master
```

Use a descriptive branch name: `add-<port-name>` for new ports, `update-<port-name>` for updates.

### Step 3: Prepare Port Files

Create the port directory under `ports/`:

```
ports/kcenon-common-system/
├── portfile.cmake
├── vcpkg.json
└── usage           # Optional but recommended
```

#### portfile.cmake

Adapt the existing portfile from the custom registry. Key differences for the official registry:

```cmake
# ports/kcenon-common-system/portfile.cmake

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kcenon/common_system
    REF "v${VERSION}"
    SHA512 0  # Will be computed — see Step 4
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOMMON_BUILD_TESTS=OFF
        -DCOMMON_BUILD_INTEGRATION_TESTS=OFF
        -DCOMMON_BUILD_EXAMPLES=OFF
        -DCOMMON_BUILD_BENCHMARKS=OFF
        -DCOMMON_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME common_system
    CONFIG_PATH lib/cmake/common_system
)

# Header-only: remove empty lib and debug directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
```

> **Important**: Do NOT include `-DFETCHCONTENT_FULLY_DISCONNECTED=ON` in the official registry
> portfile. This flag is only needed for the custom registry where dependencies are pre-installed
> by vcpkg. In the official registry, vcpkg handles dependency resolution natively.

#### vcpkg.json

```json
{
  "name": "kcenon-common-system",
  "version-semver": "0.2.0",
  "description": "High-performance C++20 foundation library providing Result<T> pattern, interfaces, and common utilities",
  "homepage": "https://github.com/kcenon/common_system",
  "license": "BSD-3-Clause",
  "supports": "!(uwp | xbox)",
  "dependencies": [
    {
      "name": "vcpkg-cmake",
      "host": true
    },
    {
      "name": "vcpkg-cmake-config",
      "host": true
    }
  ]
}
```

Notes:
- **No `port-version`** field for initial submission (defaults to 0)
- Description must be in **English** and accurately describe the library
- Use `version-semver` for semantic versioning

#### usage (optional)

```
The package kcenon-common-system provides CMake targets:

    find_package(common_system CONFIG REQUIRED)
    target_link_libraries(main PRIVATE common_system::common_system)
```

### Step 4: Compute the SHA512 Hash

The `SHA512` field in `portfile.cmake` must match the release archive. To compute it:

```bash
# Download the release archive
wget https://github.com/kcenon/common_system/archive/refs/tags/v0.2.0.tar.gz

# Compute SHA512
shasum -a 512 v0.2.0.tar.gz | awk '{print $1}'
```

Replace the placeholder `SHA512 0` with the actual hash (lowercase).

Alternatively, set `SHA512 0` and run `vcpkg install` — vcpkg will report the expected hash
in the error message.

### Step 5: Test Locally

```bash
# Test with overlay port first
vcpkg install kcenon-common-system --overlay-ports=ports/kcenon-common-system

# Or test directly from the ports directory
vcpkg install kcenon-common-system
```

Verify:
- [ ] Port installs without errors
- [ ] `find_package()` works in a test CMakeLists.txt
- [ ] Builds on at least one official triplet

### Step 6: Update Version Database

```bash
# Stage the port files
git add ports/kcenon-common-system

# Commit the port
git commit -m "Add kcenon-common-system port"

# Update version database
vcpkg x-add-version kcenon-common-system

# Commit the version database changes
git add versions/
git commit -m "Update version database for kcenon-common-system"
```

This updates:
- `versions/baseline.json` — adds the port with its baseline version
- `versions/k-/kcenon-common-system.json` — creates the version history file

### Step 7: Push and Create a Pull Request

```bash
git push myfork add-kcenon-common-system
```

On GitHub, create a **Draft PR** from your fork to `microsoft/vcpkg:master`.

PR title format: `[kcenon-common-system] Add new port (version 0.2.0)`

PR body should include:
- Brief description of the library
- Links to the project homepage and repository
- Confirmation that it meets the maturity requirements
- The [PR review checklist](#pr-review-checklist) (filled out)

### Step 8: Wait for CI and Review

1. Wait for CI to pass on all tested triplets
2. Convert from Draft to Ready for Review once CI is green
3. Respond to reviewer feedback promptly (PRs inactive >60 days may be closed)

---

## Portfile Requirements

### Must Follow

| Requirement | Details |
|-------------|---------|
| **No deprecated helpers** | Use `vcpkg_cmake_configure()`, not `vcpkg_configure_cmake` |
| **Minimal comments** | Remove boilerplate; portfiles should be declarative |
| **Lowercase hex** | All SHA512 hashes and git-tree SHAs in lowercase |
| **Install copyright** | Use `vcpkg_install_copyright(FILE_LIST ...)` |
| **No vendored deps** | All dependencies via vcpkg, not embedded copies |
| **Tests disabled** | Set `BUILD_TESTS=OFF` or equivalent by default |
| **Tool port deps** | Include `vcpkg-cmake` and `vcpkg-cmake-config` as host deps |

### Features

Features must be **additive** — installing `port[featureA,featureB]` must work if both
`port[featureA]` and `port[featureB]` install independently.

Features must NOT:
- Implement mutually exclusive alternatives (e.g., different crypto backends)
- Add new APIs when enabled by default
- Control polyfills without baking the state into installed headers

When a feature controls an optional dependency, explicitly disable it when not selected:

```cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "encryption" CMAKE_REQUIRE_FIND_PACKAGE_OpenSSL
    INVERTED_FEATURES
        "encryption" CMAKE_DISABLE_FIND_PACKAGE_OpenSSL
)
```

### Naming

Port names must be **distinctive** and unambiguous:

- Short names or common words require a disambiguating prefix
- The `kcenon-` prefix satisfies this requirement
- Searching the port name should lead to the corresponding project

### Patching

If upstream changes are needed:

1. **Prefer options** over patching (e.g., `-DCMAKE_DISABLE_FIND_PACKAGE_XYz=ON`)
2. **Notify upstream** for any patch useful to them (30-day waiting period)
3. **Minimize patches** — use `if(0)` blocks instead of deleting lines
4. **Download approved patches** from upstream PRs instead of including patch files

---

## PR Review Checklist

Microsoft reviewers will verify the following. Ensure these are addressed before submission.

### Port Quality

- [ ] Builds successfully on CI (at least one official triplet)
- [ ] No deprecated helper functions used
- [ ] Correct copyright/license file installed
- [ ] No unnecessary files in the port directory
- [ ] Description is in English and accurately describes the library

### vcpkg.json

- [ ] `name` follows naming conventions
- [ ] `version-semver` matches the upstream release
- [ ] `description` is concise (1-2 sentences)
- [ ] `homepage` points to the official project page
- [ ] `license` uses a valid SPDX identifier
- [ ] Dependencies are correctly specified with version constraints where needed
- [ ] Features are additive and well-documented

### portfile.cmake

- [ ] Downloads from the official source repository
- [ ] SHA512 hash is correct and lowercase
- [ ] Tests, examples, and docs are disabled
- [ ] Handles `VCPKG_LIBRARY_LINKAGE` correctly (static vs shared)
- [ ] No path-dependent behavior
- [ ] No conflicting file installations

### Version Database

- [ ] `vcpkg x-add-version` has been run
- [ ] `versions/baseline.json` is updated
- [ ] Port-specific version file exists under `versions/`

---

## kcenon-Specific Considerations

### Submission Order

Submit ports in **dependency tier order** to avoid dangling dependencies:

```
Tier 0: kcenon-common-system          (no kcenon deps)
     ↓
Tier 1: kcenon-thread-system          (depends on common)
        kcenon-container-system        (depends on common)
     ↓
Tier 2: kcenon-logger-system          (depends on common)
     ↓
Tier 3: kcenon-monitoring-system      (depends on common)
        kcenon-database-system         (depends on common)
     ↓
Tier 4: kcenon-network-system         (depends on common, container, thread)
     ↓
Tier 5: kcenon-pacs-system            (depends on common, container, network, thread)
```

Each tier's PR should only be submitted after the previous tier's ports are merged.

### Portfile Adaptations

When adapting portfiles from the custom registry for the official registry:

1. **Remove `FETCHCONTENT_FULLY_DISCONNECTED=ON`**
   - In the custom registry, this prevents FetchContent from downloading during vcpkg builds
   - In the official registry, vcpkg resolves dependencies natively — this flag is not needed
   and may cause build failures

2. **Remove `port-version` from initial vcpkg.json**
   - The official registry starts at port-version 0 (implicit)
   - Only add `port-version` when updating the port without a version bump

3. **Verify PACKAGE_NAME/CONFIG_PATH**
   - Ensure the values match the **tagged release** install paths, not main branch
   - This was the source of issues fixed in the custom registry
   (see kcenon/vcpkg-registry#49)

4. **Add `unofficial-` namespace for custom CMake exports** (if any)
   - Any CMake config not provided by upstream should use `unofficial-<port>::` namespace
   - kcenon ports already use their own namespaces, so this typically does not apply

### Dual Registry Strategy

After publishing to the official registry:

```
Custom Registry (kcenon/vcpkg-registry)
├── Rapid iteration on port changes
├── Pre-release / development versions
├── Internal CI validation
└── Sync to official on stable releases

Official Registry (microsoft/vcpkg)
├── Stable, production-ready versions
├── Global discoverability
├── Microsoft CI on all triplets
└── Community maintenance support
```

Workflow:
1. Develop and test port changes in the custom registry
2. When a stable release is tagged, prepare the official registry PR
3. Submit PR to `microsoft/vcpkg` with the tested portfile
4. Continue using the custom registry for ecosystem-internal development

### Port Name Compatibility

The `kcenon-` prefix used in the custom registry follows the official naming convention:

> Ports with short names or named after common words require disambiguation.
> The repository's owner, username, or organization is an acceptable unambiguous prefix.

The existing `kcenon-common-system`, `kcenon-thread-system`, etc. names can be used
as-is in the official registry.

---

## Maintenance

### Updating a Port

When a new version of a kcenon library is released:

```bash
# In your microsoft/vcpkg fork
git fetch origin
git checkout -b update-kcenon-common-system-0.3.0 origin/master

# Update portfile.cmake: change SHA512 hash
# Update vcpkg.json: change version-semver
# Reset port-version to 0 (or remove the field)

# Test locally
vcpkg install kcenon-common-system --overlay-ports=ports/kcenon-common-system

# Update version database
git add ports/kcenon-common-system
git commit -m "Update kcenon-common-system to 0.3.0"
vcpkg x-add-version kcenon-common-system
git add versions/
git commit -m "Update version database"

# Push and create PR
git push myfork update-kcenon-common-system-0.3.0
```

PR title: `[kcenon-common-system] Update to version 0.3.0`

### Port-Only Fixes

When fixing the portfile without a new upstream version:

1. Increment `port-version` in `vcpkg.json`
2. Run `vcpkg x-add-version`
3. Submit PR with explanation of the fix

### Responding to Reviews

- PRs inactive for **60 days** may be closed
- Address all reviewer feedback promptly
- Use Draft PRs to get early CI feedback before requesting review
- If CI fails on a specific triplet, investigate and fix rather than marking `# BROKEN`

### Handling CI Failures

Common causes and solutions:

| Failure | Solution |
|---------|----------|
| Missing dependency | Add to `dependencies` in vcpkg.json |
| Platform-specific build error | Add `supports` constraint or platform guard |
| Test binary built | Ensure `BUILD_TESTS=OFF` or equivalent |
| File conflict with another port | Ensure unique installation paths |
| SHA512 mismatch | Recompute hash from the release archive |

---

## References

- [Tutorial: Add a port to the vcpkg open-source registry](https://learn.microsoft.com/en-us/vcpkg/get_started/get-started-adding-to-registry)
- [vcpkg Maintainer Guide](https://learn.microsoft.com/en-us/vcpkg/contributing/maintainer-guide)
- [vcpkg PR Review Checklist](https://learn.microsoft.com/en-us/vcpkg/contributing/pr-review-checklist)
- [Registries Concepts](https://learn.microsoft.com/en-us/vcpkg/concepts/registries)
- [Publishing to a Private Git Registry](https://learn.microsoft.com/en-us/vcpkg/produce/publish-to-a-git-registry)
- [Versioning Reference](https://learn.microsoft.com/en-us/vcpkg/users/versioning)
- [microsoft/vcpkg GitHub Repository](https://github.com/microsoft/vcpkg)
