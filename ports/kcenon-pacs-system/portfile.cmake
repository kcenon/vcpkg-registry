# kcenon-pacs-system portfile
# Modern C++20 PACS implementation built on the kcenon ecosystem

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kcenon/pacs_system
    REF 1a0560a34eeb61110a9380cb2bdd29fe0de68ce1
    SHA512 aa80d5dada91356692b5db4b44dda84e9d34a6bfce65e9d6c84fab90f296ab91568b67faf3e5ba89ed13e0bcef93f400ae5849afba8076daed912a5b694cdee6
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPACS_BUILD_TESTS=OFF
        -DPACS_BUILD_EXAMPLES=OFF
        -DPACS_BUILD_BENCHMARKS=OFF
        -DPACS_BUILD_SAMPLES=OFF
        -DPACS_WITH_COMMON_SYSTEM=ON
        -DPACS_WITH_CONTAINER_SYSTEM=ON
        -DPACS_WITH_NETWORK_SYSTEM=ON
        -DPACS_BUILD_STORAGE=OFF
        -DPACS_WITH_AWS_SDK=OFF
        -DPACS_WITH_AZURE_SDK=OFF
        -DPACS_BUILD_MODULES=OFF
        -DPACS_WARNINGS_AS_ERRORS=OFF
        -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME pacs_system
    CONFIG_PATH lib/cmake/pacs_system
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
