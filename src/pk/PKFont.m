#import "PKFont.h"
#import <ft2build.h>
#import FT_FREETYPE_H

static FT_Library ft_library;
static BOOL fontInitialized = NO;

@interface PKGlyph (Loading)
- (void)fillData:(const char*)ptr length:(NSUInteger)length;
- (void)setCode:(long)code_;
- (void)setWidth:(int)width_;
- (void)setHeight:(int)height_;
- (void)setXAdvance:(int)xadvance_;
- (void)setYAdvance:(int)yadvance_;
@end

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
        FT_Set_Pixel_Sizes( face, 0, size_);
    }
    return self;
}
- (id)initFromFile:(NSString*)path size:(float)size_ {
    NSData *dat = [NSData dataWithContentsOfFile:path];
    if( self = [self initFromMemory:dat size:size_]) {
        // pass
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
        [self loadGlyph:glyph code:c];
        [glyphs setValue:glyph forKey:key];
        [glyph release];
    }

    return glyph;
}

- (void)loadGlyph:(PKGlyph*)glyph code:(unichar)code {
    FT_Load_Char( face, code, FT_LOAD_RENDER);
    FT_Bitmap *bm = &face->glyph->bitmap;
    const char *raw = (const char*)bm->buffer;
    NSUInteger buffer_size = bm->pitch * bm->rows;
    
    [glyph fillData:raw length:buffer_size];
    [glyph setCode:code];
    [glyph setWidth:bm->width];
    [glyph setHeight:bm->rows];
    [glyph setXAdvance:face->glyph->advance.x];
    [glyph setYAdvance:face->glyph->advance.y];
}
@end

@implementation PKGlyph
@synthesize data;
@synthesize code;
@synthesize width;
@synthesize height;
@synthesize xadvance;
@synthesize yadvance;

- (id)init {
    if( self = [super init]) {
        data = [NSData new];
    }
    return self;
}
- (void)dealloc {
    [data release];
    [super dealloc];
}

@end

@implementation PKGlyph (Loading)
- (void)fillData:(const char*)ptr length:(NSUInteger)length {
    data = [data initWithBytes:ptr length:length];
}
- (void)setCode:(long)code_ {
    code = code_;
}
- (void)setWidth:(int)width_ {
    width = width_;
}
- (void)setHeight:(int)height_ {
    height = height_;
}
- (void)setXAdvance:(int)xadvance_ {
    xadvance = xadvance_;
}
- (void)setYAdvance:(int)yadvance_ {
    yadvance = yadvance_;
}
@end
