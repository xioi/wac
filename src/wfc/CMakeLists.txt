set( WFC_BACKEND "sdl" CACHE STRING "The backend of WFC. Possible options: sdl(default)")

add_library( wfc STATIC "")
target_include_directories( wfc PUBLIC ".")
target_sources( wfc PRIVATE
    "WFCBase.m"
    "WFCLang.m"
    "WFCEntry.m"
    "glad.c"
)
target_compile_options( wfc PRIVATE ${WAC_OBJC_FLAGS})
target_link_libraries( wfc PUBLIC
    SDL2::SDL2 SDL2::SDL2main SDL2::SDL2-static
    freetype plutosvg yaml panku)

add_subdirectory( platforms)
add_subdirectory( renderers)

# TODO:Multi-backends (really?)
target_compile_definitions( wfc PRIVATE WFC_BACKEND_SDL)