#import <Foundation/Foundation.h>

typedef struct WACFRect {
    float x, y, w, h;
} WACFRect;

typedef struct WACFPoint {
    float x, y;
} WACFPoint;

typedef struct WACColor {
    float r, g, b, a;
} WACColor;

typedef struct WACFSize {
    float w, h;
} WACFSize;

@interface WACTexture : NSObject {
    @private
    uint handle;
    NSUInteger width, height;
}

@property (readonly) NSUInteger width;
@property (readonly) NSUInteger height;

+ (instancetype)imageForPath:(NSString*)path;

- (id)initFromFile:(NSString*)path;
- (id)initFromSvg:(char*)data width:(NSUInteger)width_ height:(NSUInteger)height_;
- (id)initFromRGBAImage:(const char*)data width:(NSUInteger)width_ htight:(NSUInteger)height_;

- (void)drawAt:(WACFPoint)pos;
- (void)drawAt:(WACFPoint)pos xscale:(float)xscale yscale:(float)yscale;
- (void)drawAt:(WACFPoint)pos angle:(float)angle;
- (void)drawAt:(WACFPoint)pos xscale:(float)xscale yscale:(float)yscale angle:(float)angle;
@end

WACFRect WACNewFRect( float x, float y, float w, float h);
WACColor WACNewColor( float r, float g, float b, float a);

void WACRenderSetup();
void WACRenderCleanup();

void WACRenderBegin();
void WACRenderEnd();
void WACSetOffset( WACFPoint offset);

void WACOnViewportResized( int w, int h);

void WACClear( float r, float g, float b, float a);
void WACDrawRect( WACFRect rect, WACColor color);
void WACDrawTexture( uint raw, WACFPoint pos);