# kcenon-logger-system portfile
# High-performance C++20 async logging library with 4.34M msg/sec throughput

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kcenon/logger_system
    REF 8e3fb18fe554c652a8f7cb4ab1573110563d23bc
    SHA512 f019f20a3e17bf8398506bf90d880a6aedf1b6b97f12e5030aea980a21eee2a3aca7a5fddcbec745f285bb5a498ee93748d7c47c9f0744fc0854bf0132a09331
    HEAD_REF main
    PATCHES
        fix-unified-deps-target-names.patch
)

# Disable thread_system integration: upstream CMake does not link thread_system
# library properly in vcpkg mode (unresolved externals for thread_pool symbols).
# The logger falls back to its standalone executor which works correctly.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_SAMPLES=OFF
        -DLOGGER_BUILD_INTEGRATION_TESTS=OFF
        -DLOGGER_ENABLE_COVERAGE=OFF
        -DLOGGER_USE_THREAD_SYSTEM=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME LoggerSystem
    CONFIG_PATH lib/cmake/LoggerSystem
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
