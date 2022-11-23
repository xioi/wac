target_sources( wfc PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/WFCWindow.m")

if( TRUE)
    target_sources( wfc PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/sdl/WFCSDLWindow.m")
endif()