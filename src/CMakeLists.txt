if( APPLE)
    set( nfd_src
        "wfc/nfd_common.c"
        "wfc/nfd_cocoa.m")
    
    set( WAC_OBJC_INCLUDE_DIR "")
elseif( WIN32)
    set( nfd_src
        "wfc/nfd_common.c"
        "wfc/nfd_win.cpp")
    set( WAC_OBJC_INCLUDE_DIR "${WAC_GNUSTEP_ROOT}/System/Library/Headers")
endif()

add_subdirectory( plutosvg)
add_subdirectory( pk)
add_subdirectory( wfc)
add_subdirectory( ckc)

add_executable( wac "")
target_sources( wac PRIVATE
    "wac.m"
    "cocoa.m"
    ${nfd_src})

target_link_libraries( wac PRIVATE wfc ckc Intl::Intl)
target_compile_options( wac PRIVATE ${WAC_OBJC_FLAGS})
set_target_properties( wac
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)