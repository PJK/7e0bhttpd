cmake_minimum_required (VERSION 2.8)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
project(7e0bhttpd)
include(CTest)
find_package(RAGEL 6.6 REQUIRED)


set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -O0 -Wall -pedantic -g -ggdb -fprofile-arcs -ftest-coverage -DDEBUG=true")
set(CMAKE_C_FLAGS_RELEASE "-O3 -Wall -pedantic -DNDEBUG")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11")


set(CMAKE_EXE_LINKER_FLAGS_DEBUG "-g -fprofile-arcs -ftest-coverage")

enable_testing()

set(CTEST_MEMORYCHECK_COMMAND "/usr/bin/valgrind")
set(MEMORYCHECK_COMMAND_OPTIONS "")

add_custom_target(coverage
                  COMMAND ctest
                  COMMAND lcov --capture --directory . --output-file coverage.info
                  COMMAND genhtml coverage.info --output-directory coverage_html
                  COMMAND echo "Coverage report ready: file://${CMAKE_CURRENT_BINARY_DIR}/coverage_html/index.html")

include_directories(src)
subdirs(src)
#subdirs(demo)
#subdirs(test)
#subdirs(bench)
