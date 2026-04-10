cmake_minimum_required(VERSION 3.20)
project(e2e_thread_system CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(thread_system CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE thread_system::thread_system)

enable_testing()
add_test(NAME e2e_thread_system COMMAND main)
