# Additional CI profile; the regular x64-windows install is also tested.
# Match x64-windows in the pinned tool checkout without relying on environment
# variables that vcpkg removes from Windows package build processes.
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_PROVIDED_FORTRAN ON)
set(VCPKG_BUILD_TYPE release)
set(VCPKG_C_FLAGS "/fsanitize=address /Zi")
set(VCPKG_CXX_FLAGS "/fsanitize=address /Zi")
set(VCPKG_LINKER_FLAGS "/DEBUG /INCREMENTAL:NO")
