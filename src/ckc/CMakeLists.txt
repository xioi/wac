add_library( ckc STATIC "")
target_include_directories( ckc PUBLIC ".")
target_sources( ckc PRIVATE
    "CKCCharacter.m"
    "CKCWalfasDNA.m"
    "CKCScene.m")
target_link_libraries( ckc PUBLIC
    PkgConfig::gtk3 PkgConfig::librsvg)