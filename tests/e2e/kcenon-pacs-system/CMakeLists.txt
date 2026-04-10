cmake_minimum_required(VERSION 3.20)
project(e2e_pacs_system CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# pacs_system's upstream config requires find_dependency(network_system) and
# find_dependency(container_system), but those packages are installed under
# the PACKAGE_NAME "NetworkSystem" and "ContainerSystem" respectively.
# That name mismatch prevents find_package(pacs_system CONFIG REQUIRED) from
# succeeding, so we verify the install by locating the vcpkg include path
# directly instead of relying on the CMake package machinery.
find_path(PACS_SYSTEM_INCLUDE_DIR
    NAMES pacs/core/dicom_tag.hpp
    HINTS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
    REQUIRED
)

add_executable(main main.cpp)
target_include_directories(main PRIVATE "${PACS_SYSTEM_INCLUDE_DIR}")

enable_testing()
add_test(NAME e2e_pacs_system COMMAND main)
