set(SOURCES main.c http.c)

set(CMAKE_SKIP_BUILD_RPATH FALSE)

if (NOT DEFINED CMAKE_MACOSX_RPATH)
	set(CMAKE_MACOSX_RPATH 0)
endif()

RAGEL_TARGET(http_parser http.rl ${CMAKE_CURRENT_BINARY_DIR}/http.c)
add_executable(7e0bhttpd ${SOURCES})
