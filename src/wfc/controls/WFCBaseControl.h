#import <WFCUIEvent.h>
#import <renderers/WFCRenderer.h>

@class WFCDrawContext;
@class WFCContainer;
@class WFCWindow;
@interface WFCControl : NSObject <WFCUIEventResponder> {
    @protected
    struct WFCRect mBounds;
    WFCWindow *root;
    WFCContainer *parent;

    BOOL isHovering;
}
@property (readwrite, assign) WFCWindow *root;
@property (readwrite, assign) WFCContainer *parent;
@property (readwrite) struct WFCRect bounds;
@property (readonly) NSString *uiName;
@property (readonly) BOOL focusable;
@property (readonly) BOOL isHovering;

- (struct WFCSize)preferredSize;
- (void)setLocation:(struct WFCPoint)location;
- (void)setSize:(struct WFCSize)size;

- (struct WFCPoint)absolutePosition;

- (void)mouseEnter:(WFCMouseEvent)e;
- (void)mouseExit:(WFCMouseEvent)e;
- (void)mouseDown:(WFCMouseEvent)e;
- (void)mouseUp:(WFCMouseEvent)e;

- (void)requestFocus;

- (BOOL)hitTest:(struct WFCPoint)point;

- (void)draw:(WFCDrawContext*)ctx;
@end

@class WFCLayouter;
@interface WFCContainer : WFCControl {
    @protected
    WFCLayouter *layouter;
    NSMutableArray *components;
}
@property (readwrite, copy) WFCLayouter *layouter;

- (id)initWithLayouter:(WFCLayouter*)l;

- (void)addComponent:(WFCControl*)component;
- (void)addComponent:(WFCControl*)component attribute:(NSInteger)addition;

- (void)removeComponent:(WFCControl*)component;
- (WFCControl*)componentForIndex:(NSUInteger)index;
- (NSInteger)componentAttributeForIndex:(NSUInteger)index;
- (NSUInteger)componentCount;

- (WFCControl*)mouseHit:(struct WFCPoint)point;

- (void)layout;
- (void)draw:(WFCDrawContext*)ctx;
@end

@interface WFCLayouter : NSObject
- (void)layoutComponents:(WFCContainer*)container;
@end

@interface WFCFlowLayouter : WFCLayouter {
    @private
    int rcap, ccap;
}
@property (readwrite) int rcap; // row cap
@property (readwrite) int ccap; // column cap

- (id)initWithRowCap:(int)rcap columnCap:(int)ccap;
@end

@interface WFCGridLayouter : WFCLayouter {
    @private
    int columns, rows, rcap, ccap;
}
@property (readwrite) int rows; // row count
@property (readwrite) int columns; // column count
@property (readwrite) int rcap; // row cap
@property (readwrite) int ccap; // column cap

- (id)initWithRows:(int)rows columns:(int)columns rowCap:(int)rcap columnCap:(int)ccap;
@end

@interface WFCSingleViewContainer : WFCContainer
- (id)initWithParent:(WFCContainer*)parent;
@end

// a debug component
@interface WFCColoredQuadComponent : WFCControl {
    @private
    struct WFCColor color;
}
@property (readwrite) struct WFCColor color;

- (id)initWithColor:(struct WFCColor)color;
@end