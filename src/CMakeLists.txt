if( APPLE)
    set( nfd_src
        "./gui/nfd_common.c"
        "./gui/nfd_cocoa.m")
elseif( WIN32)
    set( nfd_src
        "./gui/nfd_common.c"
        "./gui/nfd_win.cpp")
endif()

add_subdirectory( plutosvg)

add_library( panku STATIC "")
target_sources(
    panku PRIVATE
    "./pk/PKException.m" "./pk/PKLoader.m"
    "./pk/PKFont.m" "./pk/mathc.c"
    "./pk/PKException.h" "./pk/PKLoader.h"
    "./pk/PKFont.h" "./pk/mathc.h"
)
target_include_directories( panku PUBLIC "./pk")
target_link_libraries( panku freetype harfbuzz harfbuzz::harfbuzz)

add_executable( wac "")
target_sources( wac PRIVATE
    "./wac.m" "./cocoa.m"
    "./gui/WFCBase.m" "./gui/WFCLang.m" "./gui/WFCWindow.m" "./gui/WFCRender.m"
    "./glad.c" ${nfd_src})

target_link_libraries( wac PRIVATE
    SDL2::SDL2 SDL2::SDL2main SDL2::SDL2-static
    freetype plutosvg yaml panku harfbuzz harfbuzz::harfbuzz)

target_compile_options( wac PRIVATE -fconstant-string-class=NSConstantString)

set_target_properties( wac
PROPERTIES
RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)