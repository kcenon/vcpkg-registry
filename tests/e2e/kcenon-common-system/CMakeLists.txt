cmake_minimum_required(VERSION 3.20)
project(e2e_common_system CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(common_system CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE common_system::common_system)

enable_testing()
add_test(NAME e2e_common_system COMMAND main)
