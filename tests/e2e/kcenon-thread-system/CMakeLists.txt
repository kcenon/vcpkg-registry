cmake_minimum_required(VERSION 3.20)
project(e2e_thread_system CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(thread_system CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE thread_system::thread_system)

enable_testing()
add_test(NAME e2e_thread_system COMMAND main)
set_tests_properties(e2e_thread_system PROPERTIES TIMEOUT 30)

# Check the real installed archive through an ASan-instrumented consumer.
if(MSVC)
    target_compile_options(main PRIVATE /fsanitize=address /Zi)
else()
    target_compile_options(main PRIVATE -fsanitize=address -fno-omit-frame-pointer)
    target_link_options(main PRIVATE -fsanitize=address)
endif()
if(ABI_NEGATIVE_FLAG)
    target_compile_options(main PRIVATE "${ABI_NEGATIVE_FLAG}")
endif()
