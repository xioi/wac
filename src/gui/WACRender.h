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