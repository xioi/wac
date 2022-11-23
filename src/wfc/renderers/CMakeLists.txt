# if( ${WFC_RENDERER} MATCHES "gl")
#     add_subdirectory( gl)
# else()
#     message( FATAL_ERROR "Wrong renderer:${WFC_RENDERER}")
# endif()

if( TRUE)
    add_subdirectory( gl)
endif()

target_sources( wfc PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/WFCRenderer.m")