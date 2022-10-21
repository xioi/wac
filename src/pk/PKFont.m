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
- (void)setYBearing:(int)ybearing_;
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

- (NSString*)familyName {
    if( face != NULL) {
        return @(face->family_name);
    }else {
        return @"[Font not loaded]";
    }
}
- (NSString*)styleName {
    if( face != NULL) {
        return @(face->style_name);
    }else {
        return @"[Font not loaded]";
    }
}

- (id)init {
    if( self = [super init]) {
        glyphs = [NSMutableDictionary new];
        face = NULL;
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
        size = size_;
    }
    return self;
}
- (id)initFromFile:(NSString*)path size:(float)size_ {
    NSData *dat = [NSData dataWithContentsOfFile:path];
    if( self = [self initFromMemory:dat size:size_]) {
        // pass
    }
    //[dat release]; // this causes segmentation fault, how strange!
    return self;
}
- (void)dealloc {
    FT_Done_Face( face);
    //[glyphs release];
    [super dealloc];
}

- (PKGlyph*)glyphForCharacter:(long)c {
    // Do some hash and ...
    // make sure this single character to be stored
    // as a NSString so NSDictionary can find it.
    // (It requires NSString. A bit strange, huh?
    //  I even cannot use NSNumber...)
    NSString *key = [NSString stringWithFormat:@"%c", (unichar)c];
    // NSNumber *key = [NSNumber numberWithLong:c];

    PKGlyph *glyph = [glyphs objectForKey:key];
    if( glyph == NULL) { // cache missed, then create and remember
        glyph = [[[self glyphClass] alloc] init];
        [self loadGlyph:glyph code:c];
        [glyphs setValue:glyph forKey:key];
        [glyph release];
    }

    return glyph;
}

- (void)loadGlyph:(PKGlyph*)glyph code:(unichar)code {
    //FT_Set_Pixel_Sizes( face, 0, 1);
    FT_Set_Char_Size( face, 0, size * 16, 300, 300);
    FT_Load_Char( face, code, FT_LOAD_RENDER);
    FT_Bitmap *bm = &face->glyph->bitmap;
    const char *raw = (const char*)bm->buffer;
    NSUInteger buffer_size = bm->pitch * bm->rows;
    
    [glyph setCode:code];
    [glyph setWidth:bm->width];
    [glyph setHeight:bm->rows];
    [glyph setXAdvance:face->glyph->advance.x];
    [glyph setYAdvance:face->glyph->advance.y];
    [glyph setYBearing:face->glyph->bitmap_top];
    [glyph fillData:raw length:buffer_size];
}

- (Class)glyphClass {
    return [PKGlyph class];
}
@end

@implementation PKGlyph
@synthesize data;
@synthesize code;
@synthesize width;
@synthesize height;
@synthesize xadvance;
@synthesize yadvance;
@synthesize ybearing;

- (id)init {
    if( self = [super init]) {
        data = [NSData alloc];
    }
    return self;
}
- (void)dealloc {
    [data release];
    [super dealloc];
}

- (void)glyphDidFillData {}
@end

@implementation PKGlyph (Loading)
- (void)fillData:(const char*)ptr length:(NSUInteger)length {
    data = [data initWithBytes:ptr length:length];
    [self glyphDidFillData];
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
- (void)setYBearing:(int)ybearing_ {
    ybearing = ybearing_;
}
@end
