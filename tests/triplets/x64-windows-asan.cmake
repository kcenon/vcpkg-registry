# Additional CI profile; the regular x64-windows install is also tested.
include("$ENV{VCPKG_ROOT}/triplets/x64-windows.cmake")
set(VCPKG_BUILD_TYPE release)
set(VCPKG_C_FLAGS "/fsanitize=address /Zi")
set(VCPKG_CXX_FLAGS "/fsanitize=address /Zi")
set(VCPKG_LINKER_FLAGS "/DEBUG /INCREMENTAL:NO")
