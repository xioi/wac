#import <Foundation/Foundation.h>
#import <renderers/WFCRenderer.h>

typedef NS_OPTIONS( NSUInteger, WFCWindowButtonOption) {
    WFCNoWindowButton   = 0,
    WFCCloseButton      = 1 << 0,
    WFCMaximizeButton   = 1 << 1,
    WFCMinimizeButton   = 1 << 2,
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
}
@property (readwrite) WFCResponderEventType type;
@property (readwrite) NSUInteger timestamp;
@property (readwrite, retain) WFCWindow *window;

@property (readwrite) WFCMouseButtonType mouseButton;
@property (readwrite) struct WFCPoint mouseLocation;
@property (readwrite) NSUInteger mouseClicks;

@property (readwrite) NSInteger keyCode;

+ (instancetype)mouseEventWithType:(WFCResponderEventType)type button:(WFCMouseButtonType)button timpstamp:(NSUInteger)timestamp window:(WFCWindow*)window location:(struct WFCPoint)location click:(NSUInteger)clicks;
+ (instancetype)keyEventWithType:(WFCResponderEventType)type key:(NSInteger)keycode modifiers:(NSUInteger)keymod timpstamp:(NSUInteger)timestamp window:(WFCWindow*)window;
@end

@interface WFCAnimationContext : NSObject {
    @private
}
@end

@interface WFCResponder : NSObject
// - (void)update:(float)delta;
- (void)onAnimation:(WFCAnimationContext*)ctx;
- (void)paint:(WFCPaintContext*)context;

- (void)onMouseDown:(WFCResponderEvent*)event;
- (void)onMouseUp:(WFCResponderEvent*)event;
- (void)onClick:(WFCResponderEvent*)event;

- (void)onKeyDown:(WFCResponderEvent*)event;
- (void)onKeyUp:(WFCResponderEvent*)event;
@end

@interface WFCView : WFCResponder {
    @private
    WFCResponder *parent;
}
@property (readwrite, retain) WFCResponder *parent;

- (void)addSubview:(WFCView*)subview;
@end

@interface WFCWindow : WFCResponder {
    @protected
    NSString *title;
    WFCWindowButtonOption buttonOption;
}
@property (readwrite, copy) NSString *title;
@property (readwrite) WFCWindowButtonOption buttonOption;

@property (readwrite, retain) WFCView *rootView;

- (id)initWithTitle:(NSString*)title;

- (instancetype)addToManagement;
- (void)removeFromManagement;
@end

@interface WFCWindow (Appearance)
- (void)paint;
@end

@interface WFCWindowManagement : NSObject {
    @private
    NSMutableArray *windows;

    id target;
    SEL closeAction;
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