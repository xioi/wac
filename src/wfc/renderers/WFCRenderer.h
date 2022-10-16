#import <Foundation/Foundation.h>
#import <mathc.h>

#define WFC_OPENGL_VERSION_MAJOR 3
#define WFC_OPENGL_VERSION_MINOR 3

typedef struct WFCPoint {
    float x, y;
} WFCPoint;

typedef struct WFCSize {
    float w, h;
} WFCSize;

typedef struct WFCRect {
    WFCPoint origin;
    WFCSize size;
} WFCRect;

typedef struct WFCColor {
    float r, g, b, a;
} WFCColor;

WFCPoint WFCSPoint( float x, float y);
WFCSize WFCSSize( float w, float h);
WFCRect WFCSRect( float x, float y, float w, float h);
WFCColor WFCSColor( float r, float g, float b, float a);

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
- (void)setDrawColor:(WFCColor)color;
- (void)addVert:(struct vec3)position uv:(struct vec2)uv;
- (void)flush;
- (void)drawFilledRectAt:(struct vec2)pos size:(struct vec2)size color:(WFCColor)color;
- (void)drawTexturedRectAt:(struct vec2)pos size:(struct vec2)size texture:(WFCTexture*)texture;
- (void)drawText:(NSString*)text at:(struct vec2)pos font:(id)font;
- (struct vec2)measureText:(NSString*)text font:(id)font;

- (BOOL)textureEnabling;
- (void)setTextureEnabling:(BOOL)enable;
- (void)bindTexture:(WFCTexture*)texture;

- (void)setResolution:(WFCSize)resolution;
- (void)setViewport:(WFCRect)viewport;

- (BOOL)loadTexture:(WFCTexture*)txt;
- (void)releaseTexture:(WFCTexture*)txt;
- (BOOL)loadFont:(WFCFont*)font;
- (void)releaseFont:(WFCFont*)font;
@end

@interface WFCBaseRenderer : NSObject <WFCRendererProtocol> {
    @protected
    BOOL textureEnabling;
    WFCColor drawColor;
    WFCSize resolution;

    WFCTexture *lastTexture;
    BOOL textureUsed;
}
+ (void)initialize;
+ (void)cleanup;
@end