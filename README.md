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

## Adding a New Port Version

1. Update port files in `ports/<port-name>/`
2. Commit the port changes
3. Run `vcpkg x-add-version --all` to update version database
4. Commit version database changes

## License

BSD-3-Clause
