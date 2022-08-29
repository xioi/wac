#import "PKFont.h"
#import <ft2build.h>
#import FT_FREETYPE_H
#import <hb.h>
#import <hb-ft.h>

static FT_Library ft_library;
static BOOL doneInit = NO;

@implementation PKFont
+ (void)init {
    if( !doneInit) {
        FT_Init_FreeType( &ft_library);
        doneInit = YES;
    }
}
+ (void)cleanup {
    if( doneInit) {
        FT_Done_FreeType( ft_library);
        doneInit = NO;
    }
}

- (id)init {
    if( self = [super init]) {
        glyphs = [NSMutableDictionary new];
    }
    return self;
}

- (id)initFromMemory:(NSData*)data {
    if( self = [self init]) {
        FT_New_Memory_Face( ft_library, [data bytes], [data length], 0, &face);
    }
    return self;
}
- (id)initFromFile:(NSString*)path {
    if( self = [self init]) {
        FT_New_Face( ft_library, [path UTF8String], 0, &face);
    }
    return self;
}
- (void)dealloc {
    FT_Done_Face( face);
    [super dealloc];
}

- (long)size {
    return size;
}
- (void)setSize:(long)size_ {
    size = size_;
    FT_Set_Char_Size( face, 0, size_, 0, 0);
}

- (PKGlyph*)glyphForCharacter:(long)c {
    NSString *key = [NSString stringWithFormat:@"%c", (unichar)c];

    PKGlyph *glyph = [glyphs objectForKey:key];
    if( glyph == NULL) { // cache missed, then create and remember
        glyph = [[PKGlyph alloc] init];
        [glyphs setValue:glyph forKey:key];
    }

    return glyph;
}
@end