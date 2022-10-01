#import "PanKu.h"

typedef struct FT_FaceRec_* FT_Face;
typedef struct hb_buffer_t hb_buffer_t;
typedef struct hb_face_t hb_face_t;
typedef struct hb_font_t hb_font_t;

// @protocol PKGlyphLoaderDelegate

// @end

@interface PKGlyph : NSObject {
    @private
    long code;

    int width, height, xadvance, yadvance;
    NSData *data;
}

@property (readonly) long code;
@property (readonly) int width;
@property (readonly) int height;
@property (readonly) int xadvance;
@property (readonly) int yadvance;

@end

@interface PKFont : NSObject {
    @private
    FT_Face face;
    NSMutableDictionary *glyphs;
    float size;
}

@property (readonly) float size;

+ (void)initialize;
+ (void)cleanup;

- (id)initFromMemory:(NSData*)data size:(float)size;
- (id)initFromFile:(NSString*)path size:(float)size;

- (PKGlyph*)glyphForCharacter:(long)c;
@end