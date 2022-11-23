#import <Foundation/Foundation.h>
#import <renderers/WFCRenderer.h>

@class WFCVisualContainer;
@class WFCLogicContainer;
@class WFCPaintContext;

@interface WFCVisualView : NSObject {
    @protected
    WFCVisualContainer *parent;
}
- (void)draw:(WFCPaintContext*)ctx;
@end

@interface WFCLogicView : NSObject {
    @protected
    WFCLogicContainer *parent;
}
@property (readonly) struct WFCRect responseArea;
@end

@interface WFCVisualContainer : WFCVisualView {
    @protected
    NSMutableArray *children;
}
@end

@interface WFCLogicContainer : WFCLogicView {
    @protected
    NSMutableArray *children;
}
@end