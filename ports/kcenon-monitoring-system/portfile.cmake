# kcenon-monitoring-system portfile
# High-performance C++20 monitoring system with metrics, tracing, and alerting

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kcenon/monitoring_system
    REF "v${VERSION}"
    SHA512 65e6e23cfa8ae49b653230d13ff111c393eda35bcd45802e0b8318028fc36aeed9bf92300d5c7a8b41618e0da7689852930ad3d2ea0a82011ef45973de1d03e4
    HEAD_REF main
)

# Feature-based options
set(MONITORING_WITH_LOGGER OFF)
if("logging" IN_LIST FEATURES)
    set(MONITORING_WITH_LOGGER ON)
endif()

set(MONITORING_WITH_NETWORK OFF)
if("network" IN_LIST FEATURES)
    set(MONITORING_WITH_NETWORK ON)
endif()

set(MONITORING_WITH_GRPC_TRANSPORT OFF)
if("grpc" IN_LIST FEATURES)
    set(MONITORING_WITH_GRPC_TRANSPORT ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMONITORING_BUILD_TESTS=OFF
        -DMONITORING_BUILD_INTEGRATION_TESTS=OFF
        -DMONITORING_BUILD_EXAMPLES=OFF
        -DMONITORING_BUILD_BENCHMARKS=OFF
        -DMONITORING_WITH_COMMON_SYSTEM=ON
        -DMONITORING_WITH_THREAD_SYSTEM=ON
        -DMONITORING_WITH_LOGGER_SYSTEM=${MONITORING_WITH_LOGGER}
        -DMONITORING_WITH_NETWORK_SYSTEM=${MONITORING_WITH_NETWORK}
        -DMONITORING_WITH_GRPC=${MONITORING_WITH_GRPC_TRANSPORT}
        -DFETCHCONTENT_FULLY_DISCONNECTED=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME monitoring_system
    CONFIG_PATH lib/cmake/monitoring_system
)

# Patch config: ensure upstream targets referenced in monitoring_system-targets.cmake
# are created before the targets file is included.  monitoring_system was built
# against build-tree aliases (thread_system::thread_system, kcenon::common_system)
# that do not exist as installed IMPORTED targets.
set(_config "${CURRENT_PACKAGES_DIR}/share/monitoring_system/monitoring_system-config.cmake")
file(READ "${_config}" _contents)
string(REPLACE
    "include(\"\${CMAKE_CURRENT_LIST_DIR}/monitoring_system-targets.cmake\")"
    "# Create aliases for targets referenced by monitoring_system-targets.cmake\nif(TARGET thread_system::thread_base AND NOT TARGET thread_system::thread_system)\n  add_library(thread_system::thread_system INTERFACE IMPORTED)\n  set_target_properties(thread_system::thread_system PROPERTIES INTERFACE_LINK_LIBRARIES thread_system::thread_base)\nendif()\nif(TARGET common_system::common_system AND NOT TARGET kcenon::common_system)\n  add_library(kcenon::common_system INTERFACE IMPORTED)\n  set_target_properties(kcenon::common_system PROPERTIES INTERFACE_LINK_LIBRARIES common_system::common_system)\nendif()\n\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/monitoring_system-targets.cmake\")"
    _contents "${_contents}"
)
file(WRITE "${_config}" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
