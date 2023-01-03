#import "WACEditor.h"
#import <CKCScene.h>

#define WAC_CONTROL_HANDLE_RADIUS (20)
@interface WACControlHandle : CKCSceneObject<CKCSceneControable> {
    @private
    // float handleAngle;
    float relativeX, relativeY;
    float alpha;
}
@property float alpha;
@end

@implementation WACControlHandle
@synthesize alpha;

- (id)init {
    if( self = [super init]) {
        // handleAngle = 0;
        alpha = 1;
    }
    return self;
}

- (void)renderWithContext:(CKCRenderContext*)ctx {
    cairo_t *cr = ctx->cr;
    cairo_arc( cr, x, y, WAC_CONTROL_HANDLE_RADIUS, 0, 2 * M_PI);
    cairo_set_source_rgba( cr, 1, 0, 0, alpha);
    cairo_stroke( cr);
}
- (BOOL)hitAtX:(float)xx y:(float)yy {
    return (xx - x) * (xx - x) + (yy - y) * (yy - y) < WAC_CONTROL_HANDLE_RADIUS * WAC_CONTROL_HANDLE_RADIUS;
}
- (void)beginDragAtX:(float)x_ y:(float)y_ {
    relativeX = x - x_;
    relativeY = y - y_;
}
- (void)dragToX:(float)x_ y:(float)y_ {
    x = x_ + relativeX;
    y = y_ + relativeY;
}
- (void)endDragAtX:(float)x_ y:(float)y_ {

}
@end

WACControlHandle *handle1, *handle2;
CKCSceneSprite *spr1;
@implementation WACEditorProxy
- (instancetype)init {
    if( self = [super init]) {
        scene = [CKCScene new];
        mx = my = 0;
        selectingObject = nil;

        // FIXME: debug code
        handle1 = [WACControlHandle new];
        handle2 = [WACControlHandle new];
        [handle2 setAlpha:0.5];
        spr1 = [CKCSceneSprite new];
        [scene addObject:handle1];
        [scene addObject:handle2];

        [spr1 setIdentity:@"graphics/hat_tmp.svg"];
    }
    return self;
}

- (void)update {
    [spr1 setX:[handle1 x]];
    [spr1 setY:[handle1 y]];
    [spr1 setScalex:([handle2 x] - [handle1 x]) / 100];
    [spr1 setScaley:([handle2 y] - [handle1 y]) / 100];
}
- (void)renderWithContext:(CKCRenderContext*)ctx {
    [spr1 renderWithContext:ctx];
    [scene renderWithContext:ctx];
    
    cairo_t *cr = ctx->cr;
    cairo_arc( cr, mx, my, 5, 0, 2 * M_PI);
    cairo_set_source_rgba( cr, 0, 0, 0, 1);
    cairo_stroke( cr);
}
- (void)pointerDidMoveToX:(float)x y:(float)y {
    mx = x;
    my = y;
    if( selectingObject != nil) {
        [selectingObject dragToX:x y:y];
    }
}
- (void)pointerDidPressAtX:(float)x y:(float)y button:(int)button_ modifier:(GdkModifierType)modifier {
    // Button:
    // 1: left
    // 2: middle
    // 3: right

    // Modifier:
    // 1: shift
    // 4: control
    // 8: option
    // 16: command
    // NSLog( @"Pressed in [%.0f, %.0f], %d %d", x, y, button_, modifier);
    __block id<CKCSceneControable> hitObj = nil;
    [scene enumerateObjectsUsingBlock:^( id obj, NSUInteger i, BOOL *stop) {
        if( [obj conformsToProtocol:@protocol( CKCSceneControable)]) {
            BOOL hit = [obj hitAtX:x y:y];
            NSLog( @"is hit: %d", hit);
            if( hit) {
                hitObj = obj;
                *stop = YES;
            }
        }
    }];
    selectingObject = hitObj;
    [selectingObject beginDragAtX:x y:y];
}
- (void)pointerDidReleaseAtX:(float)x y:(float)y button:(int)button_ modifier:(GdkModifierType)modifier {
    selectingObject = nil;
}
@end
