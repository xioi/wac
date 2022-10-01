#import <Foundation/Foundation.h>

typedef struct WFCFPoint {
    float x, y;
} WFCFPoint;

typedef struct WFCFSize {
    float w, h;
} WFCFSize;

typedef struct WFCFRect { // TODO: -> WFCFPoint origin; WFCFSize size;
    float x, y, w, h;
} WFCFRect;

typedef struct WFCColor {
    float r, g, b, a;
} WFCColor;

@interface WFCTexture : NSObject {
    @private
    uint handle;
    NSUInteger width, height;
    BOOL complete;
}

@property (readonly) uint handle;
@property (readonly) NSUInteger width;
@property (readonly) NSUInteger height;

+ (instancetype)imageForPath:(NSString*)path;

- (id)initFromFile:(NSString*)path;
- (id)initFromSvg:(char*)data width:(NSUInteger)width_ height:(NSUInteger)height_;
- (id)initFromRGBAImage:(const char*)data width:(NSUInteger)width_ height:(NSUInteger)height_;

- (void)drawAt:(WFCFPoint)pos;
- (void)drawAt:(WFCFPoint)pos width:(float)ww height:(float)hh;
- (void)drawAt:(WFCFPoint)pos xscale:(float)xscale yscale:(float)yscale;
- (void)drawAt:(WFCFPoint)pos angle:(float)angle;
- (void)drawAt:(WFCFPoint)pos width:(float)ww height:(float)hh angle:(float)angle;
- (void)drawAt:(WFCFPoint)pos xscale:(float)xscale yscale:(float)yscale angle:(float)angle;
@end

WFCFPoint WFCNewFPoint( float x, float y);
WFCFSize WFCNewFSize( float w, float h);
WFCFRect WFCNewFRect( float x, float y, float w, float h);
WFCColor WFCNewColor( float r, float g, float b, float a);

void WFCRenderSetup();
void WFCRenderCleanup();

void WFCRenderBegin();
void WFCRenderEnd();
void WFCSetOffset( WFCFPoint offset);

void WFCOnViewportResized( int w, int h);

void WFCClear( float r, float g, float b, float a);
void WFCDrawRect( WFCFRect rect, WFCColor color);
void WFCDrawTexture( uint raw, WFCFPoint pos);