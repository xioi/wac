#import <Foundation/Foundation.h>
#import <gtk/gtk.h>
#import <CKCScene.h>

@interface WACEditorProxy : NSObject {
    @private
    CKCScene *scene;
    float mx, my;

    id<CKCSceneControable> selectingObject;
}

- (void)update;
- (void)renderWithContext:(CKCRenderContext*)ctx;
- (void)pointerDidMoveToX:(float)x y:(float)y;
- (void)pointerDidPressAtX:(float)x y:(float)y button:(int)button_ modifier:(GdkModifierType)modifier;
- (void)pointerDidReleaseAtX:(float)x y:(float)y button:(int)button_ modifier:(GdkModifierType)modifier;
@end