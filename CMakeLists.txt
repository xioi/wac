cmake_minimum_required( VERSION 3.1)
project( wac OBJC C)

set( CMAKE_EXPORT_COMPILE_COMMANDS ON) # for ccls

if( APPLE)
    set( OBJC_LINK_FLAGS
        -lobjc
        -framework Foundation)
elseif( WIN32)
endif()

add_compile_options( -g)

find_package( SDL2 CONFIG REQUIRED)
find_package( freetype CONFIG REQUIRED)
find_package( yaml CONFIG REQUIRED)

add_subdirectory( src)