#import <Foundation/Foundation.h>
#import <gtk/gtk.h>

struct _CKCRenderContext {
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

// - (void)renderWithContext:(CKCRenderContext*)ctx;
@end

@protocol CKCSceneControable
@end

@interface CKCSceneObject : NSObject<CKCSceneApperance> {
    @protected
    float x, y, angle, scale;
}

// - (void)renderWithContext:(CKCRenderContext*)ctx;
@end

@interface CKCScene : NSObject<CKCSceneApperance> {
    @private
    NSMutableArray *objects;
}

- (void)addObject:(CKCSceneObject*)object;
// - (void)renderWithContext:(CKCRenderContext*)ctx;
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