add_library( panku STATIC "")
target_sources( panku PRIVATE
    "PKException.m"
    "PKLoader.m"
    "PKFont.m"
    "PKSerialization.m"
    "mathc.c"
)
target_include_directories( panku PUBLIC ".")
target_link_libraries( panku freetype harfbuzz harfbuzz::harfbuzz)