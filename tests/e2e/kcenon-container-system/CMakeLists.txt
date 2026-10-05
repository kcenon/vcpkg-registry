cmake_minimum_required(VERSION 3.20)
project(e2e_container_system CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Discover the legacy name first so an earlier canonical lookup cannot hide
# a missing compatibility config (released PACS still uses this name).
find_package(ContainerSystem 1.0.0 CONFIG REQUIRED)
find_package(container_system 1.0.0 CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE container_system::container_system)

add_executable(legacy main.cpp)
target_link_libraries(legacy PRIVATE ContainerSystem::container)

enable_testing()
add_test(NAME e2e_container_system COMMAND main)
add_test(NAME e2e_container_system_legacy COMMAND legacy)
