if( APPLE)
    set( nfd_src
        "./wfc/nfd_common.c"
        "./wfc/nfd_cocoa.m")
elseif( WIN32)
    set( nfd_src
        "./wfc/nfd_common.c"
        "./wfc/nfd_win.cpp")
endif()

add_subdirectory( plutosvg)
add_subdirectory( pk)
add_subdirectory( wfc)

add_executable( wac "")
target_sources( wac PRIVATE
    "wac.m"
    "cocoa.m"
    ${nfd_src})

target_link_libraries( wac PRIVATE wfc)
target_compile_options( wac PRIVATE -fconstant-string-class=NSConstantString)
set_target_properties( wac
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)