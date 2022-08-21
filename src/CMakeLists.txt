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

add_executable( wac "")

if( NOT ${_VCPKG_INSTALLED_DIR} EQUAL "")
    target_include_directories( wac PRIVATE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/cairo/")
    target_link_directories( wac PRIVATE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/")
endif()

target_sources( wac PRIVATE
    "./wac.m" "./cocoa.m"
    "./gui/WACBase.m" "./gui/WACLang.m" "./gui/WACWindow.m" "./gui/WACRender.m"
    "./glad.c" ${nfd_src})

target_link_libraries( wac PRIVATE
    SDL2::SDL2 SDL2::SDL2main SDL2::SDL2-static
    freetype plutosvg yaml)

target_compile_options( wac PRIVATE -fconstant-string-class=NSConstantString)

set_target_properties( wac
PROPERTIES
RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)