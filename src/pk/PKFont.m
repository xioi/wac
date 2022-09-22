#import "PKFont.h"
#import <ft2build.h>
#import FT_FREETYPE_H
#import <hb.h>
#import <hb-ft.h>

static FT_Library ft_library;
static BOOL fontInitialized = NO;

@implementation PKFont
@synthesize size;

+ (void)initialize {
    if( !fontInitialized) {
        FT_Init_FreeType( &ft_library);
        fontInitialized = YES;
    }
}
+ (void)cleanup {
    if( fontInitialized) {
        FT_Done_FreeType( ft_library);
        fontInitialized = NO;
    }
}

- (id)init {
    if( self = [super init]) {
        glyphs = [NSMutableDictionary new];
    }
    return self;
}

- (id)initFromMemory:(NSData*)data size:(float)size_ {
    if( self = [self init]) {
        if( [data bytes] == NULL) {
            // TODO: load default font
            return self;
        }
        FT_New_Memory_Face( ft_library, [data bytes], [data length], 0, &face);
    }
    return self;
}
- (id)initFromFile:(NSString*)path size:(float)size_ {
    NSData *dat = [NSData dataWithContentsOfFile:path];
    if( self = [self initFromMemory:dat size:size_]) {
    }
    [dat release];
    return self;
}
- (void)dealloc {
    FT_Done_Face( face);
    [super dealloc];
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

@implementation PKGlyph
@synthesize code;
@synthesize width;
@synthesize height;
@synthesize xadvance;
@synthesize yadvance;

@end
