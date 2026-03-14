# kcenon-network-system portfile
# Modern C++20 async network library with TCP/UDP, HTTP/1.1, WebSocket, and TLS 1.3

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kcenon/network_system
    REF "v${VERSION}"
    SHA512 b67280d55415a3d26618683d348f105650c1589a64f24aa64ed533f273350c14512ba99d7c63cb7387e7ad15033ded56b482b14e76aa2f4479533468c0982658
    HEAD_REF main
    PATCHES
        fix-common-system-target.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_WEBSOCKET_SUPPORT=ON
        -DBUILD_MESSAGING_BRIDGE=OFF
        -DNETWORK_BUILD_BENCHMARKS=OFF
        -DNETWORK_BUILD_INTEGRATION_TESTS=OFF
        -DNETWORK_BUILD_MODULES=OFF
        -DBUILD_WITH_COMMON_SYSTEM=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME NetworkSystem
    CONFIG_PATH lib/cmake/NetworkSystem
)

# Remove empty directories that cause vcpkg post-build validation warnings
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/kcenon/network/core"
    "${CURRENT_PACKAGES_DIR}/include/kcenon/network/experimental"
    "${CURRENT_PACKAGES_DIR}/include/kcenon/network/http"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
