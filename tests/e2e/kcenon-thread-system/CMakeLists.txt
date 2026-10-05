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

# MSVC requires matching STL annotations in every linked object. Windows runs
# the production package first, then an additional instrumented vcpkg profile.
set(asan_default ON)
if(MSVC)
    set(asan_default OFF)
endif()
option(THREAD_CONSUMER_ASAN "Instrument the installed Thread consumer" ${asan_default})
if(THREAD_CONSUMER_ASAN)
    if(MSVC)
        target_compile_options(main PRIVATE /fsanitize=address /Zi)
        target_link_options(main PRIVATE /DEBUG /INCREMENTAL:NO)
    else()
        target_compile_options(main PRIVATE -fsanitize=address -fno-omit-frame-pointer)
        target_link_options(main PRIVATE -fsanitize=address)
    endif()
endif()
if(ABI_NEGATIVE_FLAG)
    target_compile_options(main PRIVATE "${ABI_NEGATIVE_FLAG}")
endif()
