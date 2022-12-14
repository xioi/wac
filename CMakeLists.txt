cmake_minimum_required( VERSION 3.1)
project( wac C OBJC)

set( CMAKE_EXPORT_COMPILE_COMMANDS ON) # for ccls

set( WAC_OBJC_FLAGS
        -fconstant-string-class=NSConstantString
        -fblocks)
if( APPLE)
    set( WAC_OBJC_LINK_FLAGS
        -lobjc
        -framework Foundation)
elseif( WIN32)
    # TODO:add Windows-supporting compiling environments
    message( STATUS "Windows Platform")
    set( WAC_GNUSTEP_ROOT "" CACHE STRING "The root directory (it has \"System\" as its sub directory) of your GNUStep")
    set( WAC_OBJC_LINK_FLAGS
        -lobjc)
endif()

if( ${CMAKE_BUILD_TYPE} MATCHES "Debug")
    add_compile_options( -g)
    add_compile_definitions( WAC_DEBUG)
else()
endif()

find_package( PkgConfig REQUIRED)
pkg_check_modules( gtk3 REQUIRED IMPORTED_TARGET "gtk+-3.0")
# pkg_check_modules( sdl2 REQUIRED IMPORTED_TARGET "sdl2")
pkg_check_modules( librsvg REQUIRED IMPORTED_TARGET "librsvg-2.0")

find_package( Freetype REQUIRED)
find_package( Intl REQUIRED)

add_subdirectory( plutosvg)
add_subdirectory( src)

file( COPY ${CMAKE_CURRENT_SOURCE_DIR}/ui DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
file( COPY ${CMAKE_CURRENT_SOURCE_DIR}/graphics DESTINATION ${CMAKE_CURRENT_BINARY_DIR})