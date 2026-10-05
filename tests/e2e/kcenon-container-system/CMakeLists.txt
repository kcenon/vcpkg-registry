cmake_minimum_required(VERSION 3.20)
project(e2e_container_system CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(container_system 1.0.0 CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE container_system::container_system)

enable_testing()
add_test(NAME e2e_container_system COMMAND main)
