#import <Foundation/Foundation.h>
#import <mathc.h>

#define WFC_OPENGL_VERSION_MAJOR 3
#define WFC_OPENGL_VERSION_MINOR 3

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
    @public
    int width;
    int height;
    BOOL complete;

    NSString *name;
    void *data;
}
@end

@interface WFCFont : NSObject {
    @public
    NSString *name;
    NSString *family;
    float size;

    void *data;
}
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
}
+ (void)initialize;
+ (void)cleanup;
@end