add_library( panku STATIC "")
target_sources( panku PRIVATE
    "PKException.m"
    "PKLoader.m"
    "PKFont.m"
    "mathc.c"
)
message( STATUS ${WAC_OBJC_INCLUDE_DIR})
target_include_directories( panku PUBLIC "." ${WAC_OBJC_INCLUDE_DIR})
target_link_libraries( panku freetype)