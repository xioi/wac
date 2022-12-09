#import <Foundation/Foundation.h>
#import <renderers/WFCRenderer.h>

typedef NS_OPTIONS( NSUInteger, WFCWindowStyle) {
    WFCWindowStyleNone              = 0,
    WFCWindowStyleButtonClose       = 1 << 0,
    WFCWindowStyleButtonMaximize    = 1 << 1,
    WFCWindowStyleButtonMinimize    = 1 << 2,
    WFCWindowStyleResizable         = 1 << 3,
    WFCWindowStyleBorderless        = 1 << 4,
};

typedef NS_OPTIONS( NSUInteger, WFCMouseButtonType) {
    WFCButtonTypeNone       = 0,
    WFCButtonTypeLeft       = 1 << 0,
    WFCButtonTypeMiddle     = 1 << 1,
    WFCButtonTypeRight      = 1 << 2
};

typedef NS_ENUM( NSUInteger, WFCResponderEventType) {
    WFCResponderEventTypeMouseDown = 0,
    WFCResponderEventTypeMouseUp,
    
    WFCResponderEventTypeKeyDown,
    WFCResponderEventTypeKeyUp
};

@class WFCWindow;
@interface WFCResponderEvent : NSObject <NSCopying> {
    @private
    WFCResponderEventType type;
    NSUInteger timestamp;
    WFCWindow *window;

    WFCMouseButtonType mouseButton;
    struct WFCPoint mouseLocation;
    NSUInteger mouseClicks;

    NSInteger keyCode;
    NSUInteger keyModifiers;
}
@property (readwrite) WFCResponderEventType type;
@property (readwrite) NSUInteger timestamp;
@property (readwrite, retain) WFCWindow *window;

@property (readwrite) WFCMouseButtonType mouseButton;
@property (readwrite) struct WFCPoint mouseLocation;
@property (readwrite) NSUInteger mouseClicks;

@property (readwrite) NSInteger keyCode;
@property (readwrite) NSUInteger keyModifiers;

+ (instancetype)mouseEventWithType:(WFCResponderEventType)type button:(WFCMouseButtonType)button timpstamp:(NSUInteger)timestamp window:(WFCWindow*)window location:(struct WFCPoint)location click:(NSUInteger)clicks;
+ (instancetype)keyEventWithType:(WFCResponderEventType)type key:(NSInteger)keycode modifiers:(NSUInteger)keymod timpstamp:(NSUInteger)timestamp window:(WFCWindow*)window;
@end

@interface WFCAnimationContext : NSObject {
    @private
    NSUInteger timestamp;
}
@property (readwrite) NSUInteger timestamp;

@end

@interface WFCResponder : NSObject
// - (void)update:(float)delta;
// - (void)requestBeginAnimation;
// - (void)requestEndAnimation;
// - (void)onAnimation:(WFCAnimationContext*)ctx;
- (void)paint:(WFCPaintContext*)context offset:(struct WFCPoint)offset;

- (void)onMouseDown:(WFCResponderEvent*)event;
- (void)onMouseUp:(WFCResponderEvent*)event;
- (void)onClick:(WFCResponderEvent*)event;

- (void)onKeyDown:(WFCResponderEvent*)event;
- (void)onKeyUp:(WFCResponderEvent*)event;
@end

@interface WFCView : WFCResponder {
    @private
    WFCView *superview;
    struct WFCRect bounds;
    NSMutableArray *subviews;
    WFCWindow *window;
}
@property (readwrite, retain) WFCWindow *window;
@property (readwrite, retain) WFCView *superview;
@property (readwrite) struct WFCRect bounds;

- (void)addSubview:(WFCView*)subview;
- (void)removeSubview:(WFCView*)subview;
- (void)removeFromSuperview;
@end

@interface WFCView (Events)
- (void)didRemoveFromSuperview:(WFCView*)superview;
- (void)didAddIntoSuperview:(WFCView*)superview;
- (void)didRemoveSubview:(WFCView*)subview;
- (void)didAddSubview:(WFCView*)subview;
@end

@interface WFCColoredRectView : WFCView {
    @private
    struct WFCColor color;
}
@property (readwrite) struct WFCColor color;

- (id)initWithColor:(struct WFCColor)color_;
@end

@interface WFCWindow : WFCResponder {
    @protected
    NSString *title;
    WFCWindowStyle style;
    WFCView *view;
    WFCPaintContext *paintContext;
    struct WFCSize size;
}
@property (readwrite, copy) NSString *title;
@property (readwrite) WFCWindowStyle style;
@property (readwrite) struct WFCSize size;

@property (readwrite, retain) WFCView *view;

- (id)initWithTitle:(NSString*)title;

// @return  WFCWindow* it self
- (instancetype)addToManagement;
- (void)removeFromManagement;
@end

@interface WFCWindow (Appearance)
- (void)initializePaintContext:(WFCPaintContext*)ctx;
- (void)paint;

- (void)windowWillPaint;
- (void)windowDoPaint;
- (void)windowDidPaint;

- (void)windowDidSizeChange:(struct WFCSize)size;
@end

@interface WFCWindowManagement : NSObject {
    @private
    NSMutableArray *windows;

    id target;
    SEL closeAction;

    WFCPaintContext *paintContext;
}
@property (readwrite, retain) id target;
@property (readwrite) SEL closeAction;

+ (instancetype)management;
- (void)addWindow:(WFCWindow*)ptr;
- (void)removeWindow:(WFCWindow*)ptr;

- (BOOL)pollEvent;

- (void)updateWindows:(float)delta;
- (void)paintWindows;
@end

WFCWindowManagement* WFCWindowManagementContext();