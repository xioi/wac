#import <Foundation/Foundation.h>

typedef struct FT_FaceRec_* FT_Face;
typedef struct hb_buffer_t hb_buffer_t;
typedef struct hb_face_t hb_face_t;
typedef struct hb_font_t hb_font_t;

@interface PKGlyph : NSObject
@end

@interface PKFont : NSObject {
    @private
    FT_Face face;
    NSMutableDictionary *glyphs;
    long size;
}

@property (readwrite) long size;

+ (void)init;
+ (void)cleanup;

- (id)initFromMemory:(NSData*)data;
- (id)initFromFile:(NSString*)path;

- (PKGlyph*)glyphForCharacter:(long)c;
@end