if( APPLE)
    set( WAC_OBJC_INCLUDE_DIR "")
elseif( WIN32)
    set( WAC_OBJC_INCLUDE_DIR "${WAC_GNUSTEP_ROOT}/System/Library/Headers")
endif()

add_subdirectory( ckc)

add_executable( wac "")
target_sources( wac PRIVATE
    "wac.m"
    "WACEditor.m")

target_link_libraries( wac PRIVATE PkgConfig::librsvg PkgConfig::gtk3 Intl::Intl plutosvg ckc)
target_compile_options( wac PRIVATE ${WAC_OBJC_FLAGS})
target_link_options( wac PRIVATE ${WAC_OBJC_LINK_FLAGS})
set_target_properties( wac
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/"
)