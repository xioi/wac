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

option( WAC_DEBUG "Whether to open the debug mode(-g & inner debugger)" OFF)
if( ${WAC_DEBUG})
    add_compile_options( -g)
    add_compile_definitions( WAC_DEBUG)
endif()

find_package( SDL2 CONFIG REQUIRED)
find_package( freetype CONFIG REQUIRED)
find_package( yaml CONFIG REQUIRED)

add_subdirectory( src)