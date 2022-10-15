set( WFC_RENDERER "gl" CACHE STRING "The renderer of WFC. Possible options: gl(default)")

add_library( wfc STATIC "")
target_include_directories( wfc PUBLIC ".")
target_sources( wfc PRIVATE
    "WFCBase.m"
    "WFCLang.m"
    "WFCWindow.m"
    "glad.c"
)
target_compile_options( wfc PRIVATE ${WAC_OBJC_FLAGS})
target_link_libraries( wfc PUBLIC
    SDL2::SDL2 SDL2::SDL2main SDL2::SDL2-static
    freetype plutosvg yaml panku)

add_subdirectory( renderers)
add_subdirectory( controls)