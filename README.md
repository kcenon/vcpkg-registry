# kcenon vcpkg Registry

Private vcpkg registry for the kcenon C++20 ecosystem packages.

## Available Ports

| Package | Version | Description |
|---------|---------|-------------|
| kcenon-common-system | 0.2.0 | High-performance C++20 foundation library (header-only) |
| kcenon-thread-system | 0.3.1 | Multithreading framework with lock-free queues |
| kcenon-logger-system | 0.1.3 | Async logging with 4.34M msg/sec throughput |
| kcenon-container-system | 0.1.0 | Thread-safe containers with messaging integration |
| kcenon-monitoring-system | 0.1.0 | Metrics collection, distributed tracing, alerting |
| kcenon-database-system | 0.1.0 | Core DAL with PostgreSQL, SQLite support |
| kcenon-network-system | 0.1.1 | Async TCP/UDP, HTTP/1.1, WebSocket, TLS 1.3 |
| kcenon-pacs-system | 0.1.0 | PACS implementation on kcenon ecosystem |

## Dependency Graph

```
Tier 0: common-system
Tier 1: thread-system, container-system
Tier 2: logger-system
Tier 3: monitoring-system, database-system
Tier 4: network-system
Tier 5: pacs-system
```

## Consumer Setup

Add the following to your project's `vcpkg-configuration.json`:

```json
{
  "default-registry": {
    "kind": "builtin",
    "baseline": "<microsoft-vcpkg-baseline>"
  },
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/kcenon/vcpkg-registry.git",
      "baseline": "<latest-commit-sha>",
      "packages": ["kcenon-*"]
    }
  ]
}
```

Then install packages normally:

```bash
vcpkg install kcenon-monitoring-system
```

## Port Management Strategy

This registry follows **Strategy B: Local + Registry Sync**, where each source
repository maintains its own portfile locally and syncs to this registry on release.

### How It Works

```
Source Repo (e.g., common_system)          vcpkg-registry
┌─────────────────────────────┐            ┌──────────────────────┐
│ vcpkg-ports/                │   sync     │ ports/               │
│   kcenon-common-system/     │ ────────── │   kcenon-common-     │
│     portfile.cmake          │  on release│   system/            │
│     vcpkg.json              │            │     portfile.cmake   │
└─────────────────────────────┘            │     vcpkg.json       │
                                           └──────────────────────┘
```

### Benefits

- **Atomic commits**: Source changes and portfile updates in a single PR
- **CI validation**: Each repo validates its portfile independently
- **Developer visibility**: Full packaging setup visible without switching repos
- **Registry remains canonical**: Consumers always install from this registry

### Local Portfile Locations

Each source repository maintains its port definition at:

```
{repo}/vcpkg-ports/kcenon-{name}/
  ├── portfile.cmake
  └── vcpkg.json
```

### Updating a Port

1. Make source changes in the system repository
2. Update `vcpkg-ports/kcenon-{name}/portfile.cmake` and `vcpkg.json` if needed
3. Commit both source and port changes together
4. On tagged release, sync port files to this registry:
   - Copy updated files to `ports/kcenon-{name}/`
   - Update SHA512 hash in `portfile.cmake` to match the release archive
   - Run `vcpkg x-add-version --all` to update the version database
   - Commit version database changes

### Adding a New Port Version (Registry Side)

1. Copy port files from the source repo's `vcpkg-ports/` directory
2. Update `SHA512` hash and version in `portfile.cmake`
3. Commit the port changes
4. Run `vcpkg x-add-version --all` to update version database
5. Commit version database changes

## End-to-End Validation

Every push and pull request to `main` triggers an end-to-end validation
workflow that verifies all 8 ports can be installed, discovered via CMake, and
linked into a consumer application.

### What Is Validated

For each port the CI pipeline performs four steps:

1. **vcpkg install** -- installs the port using overlay-ports from this registry
2. **CMake configure** -- runs `find_package(<port> CONFIG REQUIRED)` in a
   minimal C++20 test project
3. **CMake build** -- compiles and links the test project against the installed
   port
4. **Run binary** -- executes the resulting binary to confirm headers and
   symbols resolve at runtime

### Platform Matrix

| Platform | Triplet |
|----------|---------|
| Ubuntu (latest) | `x64-linux` |
| macOS (latest) | `arm64-osx` |
| Windows (latest) | `x64-windows` |

This produces **21 jobs** per run (8 ports x 3 platforms, minus 3 Windows exclusions).
Three ports -- `kcenon-logger-system`, `kcenon-network-system`, and `kcenon-pacs-system`
-- are excluded from the Windows matrix due to upstream library linker errors that are
outside the scope of this registry to fix.

### Test Projects

Each port has a minimal test project under `tests/e2e/<port-name>/`:

```
tests/e2e/
  kcenon-common-system/
    CMakeLists.txt
    main.cpp
  kcenon-thread-system/
    ...
  (one directory per port)
```

Each `main.cpp` includes a representative header and exercises a basic API call
to verify both header availability and linkage.

### CI Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| Validate Registry | `.github/workflows/validate-registry.yml` | Port structure, version database, git-tree integrity |
| E2E Port Validation | `.github/workflows/validate-e2e.yml` | Install, find_package, link, and run for all ports |

### Running Locally

To validate a single port locally (requires vcpkg installed):

```bash
# Linux: install system dependencies required by some ports (e.g., pacs-system via ICU)
sudo apt-get install -y autoconf-archive

# macOS: install system dependencies required by ICU and OpenSSL builds
brew install autoconf automake libtool
export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)

# Install the port with overlay-ports
vcpkg install kcenon-common-system:x64-linux \
  --overlay-ports=./ports

# Configure and build the test project
cmake -B tests/e2e/kcenon-common-system/build \
  -S tests/e2e/kcenon-common-system \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=x64-linux \
  -DVCPKG_INSTALLED_DIR=tests/e2e/vcpkg_installed \
  -DVCPKG_MANIFEST_MODE=OFF

cmake --build tests/e2e/kcenon-common-system/build --config Release

# Run the test via ctest
ctest --test-dir tests/e2e/kcenon-common-system/build \
  --build-config Release \
  --output-on-failure
```

## License

BSD-3-Clause
