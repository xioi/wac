#import <Foundation/Foundation.h>
#import <mathc.h>

struct WFCPoint {
    float x, y;
};

struct WFCSize {
    float w, h;
};

struct WFCRect {
    struct WFCPoint origin;
    struct WFCSize size;
};

struct WFCColor {
    float r, g, b, a;
};

struct WFCPoint WFCPoint( float x, float y);
struct WFCSize WFCSize( float w, float h);
struct WFCRect WFCRect( float x, float y, float w, float h);
struct WFCColor WFCColor( float r, float g, float b, float a);

@interface WFCTexture : NSObject {
    @private
    NSInteger width;
    NSInteger height;
    BOOL complete;

    NSString *name;
    void *data;
}
@property (readwrite, copy) NSString *name;
@property (readwrite) NSInteger width;
@property (readwrite) NSInteger height;
@property (readwrite) BOOL complete;

@property (readwrite) void *data;
@end

@interface WFCFont : NSObject {
    @private
    NSString *name;
    float size;

    void *data;
}
@property (readwrite, copy) NSString *name;
@property (readwrite) float size;

@property (readwrite) void *data;
@end

@protocol WFCRendererProtocol
- (void)renderBegin;
- (void)renderEnd;
- (void)setDrawColor:(struct WFCColor)color;
- (void)addVert:(struct vec3)position uv:(struct vec2)uv;
- (void)flush;
- (void)drawFilledRectAt:(struct vec2)pos size:(struct vec2)size color:(struct WFCColor)color;
- (void)drawTexturedRectAt:(struct vec2)pos size:(struct vec2)size texture:(WFCTexture*)texture;
- (void)drawText:(NSString*)text at:(struct vec2)pos font:(id)font;
- (struct vec2)measureText:(NSString*)text font:(id)font;

- (BOOL)textureEnabling;
- (void)setTextureEnabling:(BOOL)enable;
- (void)bindTexture:(WFCTexture*)texture;

- (void)setResolution:(struct WFCSize)resolution;
- (void)setViewport:(struct WFCRect)viewport;

- (BOOL)loadTexture:(WFCTexture*)txt;
- (void)releaseTexture:(WFCTexture*)txt;
- (BOOL)loadFont:(WFCFont*)font;
- (void)releaseFont:(WFCFont*)font;

- (void)clipBegin;
- (void)clipEnd;
@end

@protocol WFCDefaultRenderResourceSource
- (WFCFont*)defaultFont;
@end

@interface WFCBaseRenderer : NSObject <WFCRendererProtocol, WFCDefaultRenderResourceSource> {
    @protected
    BOOL textureEnabling;
    struct WFCColor drawColor;
    struct WFCSize resolution;

    WFCTexture *lastTexture;
    BOOL textureUsed;

    struct WFCRect clip;
}
@property (readwrite) struct WFCRect clip;

+ (void)initialize;
+ (void)cleanup;
@end

@interface WFCPaintContext : NSObject <NSCopying> {
    @private
    struct WFCPoint offset;
    WFCBaseRenderer *renderer;
}
@property (readwrite) struct WFCPoint offset;
@property (readwrite, retain) WFCBaseRenderer *renderer;

+ (instancetype)paintContextWithRenderer:(WFCBaseRenderer*)renderer_;
- (id)initWithRenderer:(WFCBaseRenderer*)renderer_;
@end