#import <Foundation/Foundation.h>
#import <gtk/gtk.h>

struct CKCRectangle {
    float x, y, width, height;
};

struct _CKCRenderContext {
    NSUInteger width, height;
    // Platform
    cairo_t *cr;
};
typedef struct _CKCRenderContext CKCRenderContext;

@protocol CKCSceneApperance
- (void)renderWithContext:(CKCRenderContext*)ctx;
@end

@interface CKCSceneSprite : NSObject<CKCSceneApperance> {
    @private
    NSString *identity;
    float x, y, angle, scalex, scaley;
    float orignx, origny;

    BOOL reloadFlag;

    // Platform
    cairo_surface_t *surface;
}
@property (readwrite, copy) NSString *identity;
@property (readwrite) float x;
@property (readwrite) float y;
@property (readwrite) float angle;
@property (readwrite) float scalex;
@property (readwrite) float scaley;
@property (readwrite) float orignx;
@property (readwrite) float origny;
@end

@protocol CKCSceneControable
- (BOOL)hitAtX:(float)x y:(float)y;
- (void)beginDragAtX:(float)x y:(float)y;
- (void)dragToX:(float)x y:(float)y;
- (void)endDragAtX:(float)x y:(float)y;
@end

@class CKCScene;
@interface CKCSceneObject : NSObject<CKCSceneApperance> {
    @protected
    float x, y, angle, scale;
    CKCScene *scene;
}
@property float x;
@property float y;
@property float angle;

- (void)didAddToScene:(CKCScene*)scene_;
- (void)didRemoveFromScene;
@end

@interface CKCScene : NSObject<CKCSceneApperance> {
    @private
    NSMutableArray *objects;
}

- (void)addObject:(CKCSceneObject*)object;
- (void)enumerateObjectsUsingBlock:(void (^)(id , NSUInteger, BOOL * ))block;
@end

@interface CKCStaticObject : CKCSceneObject {
    @protected
    NSString *identity;

    @private
    BOOL reloadFlag;
}
@property (readwrite, copy) NSString *identity;

- (instancetype)initWithIdentity:(NSString*)identity_;

@end