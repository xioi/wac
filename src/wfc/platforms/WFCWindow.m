#import "WFCWindow.h"
// #ifdef WFC_BACKEND_SDL
#import "sdl/WFCSDLWindow.h"
// #endif

@implementation WFCResponderEvent
@synthesize type;
@synthesize timestamp;
@synthesize window;

@synthesize mouseButton;
@synthesize mouseLocation;
@synthesize mouseClicks;

- (id)copyWithZone:(nullable NSZone *)zone {
    WFCResponderEvent *copy = [[[self class] alloc] init];
    if( copy) {
        [copy setType:[self type]];
        [copy setTimestamp:[self timestamp]];
        [copy setWindow:[self window]];

        [copy setMouseButton:[self mouseButton]];
        [copy setMouseLocation:[self mouseLocation]];
        [copy setMouseClicks:[self mouseClicks]];
    }
    return copy;
}

+ (instancetype)mouseEventWithType:(WFCResponderEventType)type button:(WFCMouseButtonType)button timpstamp:(NSUInteger)timestamp window:(WFCWindow*)window location:(struct WFCPoint)location click:(NSUInteger)clicks {
    WFCResponderEvent *obj = [[[self class] alloc] init];
    [obj setType:type];
    [obj setTimestamp:timestamp];
    [obj setWindow:window];

    [obj setMouseButton:button];
    [obj setMouseLocation:location];
    [obj setMouseClicks:clicks];
    return obj;
}
@end

@implementation WFCResponder
- (void)onAnimation:(WFCAnimationContext*)ctx {

}
- (void)paint:(WFCPaintContext*)context {

}

- (void)onMouseDown:(WFCResponderEvent*)event {

}
- (void)onMouseUp:(WFCResponderEvent*)event {

}
- (void)onClick:(WFCResponderEvent*)event {

}

- (void)onKeyDown:(WFCResponderEvent*)event {

}
- (void)onKeyUp:(WFCResponderEvent*)event {

}
@end

@implementation WFCWindow
@synthesize title;
@synthesize buttonOption;

- (id)initWithTitle:(NSString*)title_ {
    if( self = [self init]) {
        [self setTitle:title_];
    }
    return self;
}
- (void)dealloc {
    [self removeFromManagement];
    [super dealloc];
}

- (instancetype)addToManagement {
    WFCWindowManagement *mgr = WFCWindowManagementContext();
    [mgr addWindow:self];
    return self;
}
- (void)removeFromManagement {
    WFCWindowManagement *mgr = WFCWindowManagementContext();
    [mgr removeWindow:self];
}

// FIXME:delete
- (void)onMouseDown:(WFCResponderEvent*)event {
    struct WFCPoint l = [event mouseLocation];
    NSLog( @"[%.2f,%.2f] in %lu", l.x, l.y, [event timestamp]);
}
- (void)inKeyDown:(WFCResponderEvent*)event {

}
@end

@implementation WFCWindowManagement
@synthesize target;
@synthesize closeAction;

- (id)init {
    if( self = [super init]) {
        windows = [NSMutableArray new];
    }
    return self;
}
- (void)dealloc {
    [windows release];
    [super dealloc];
}

+ (instancetype)management {
    return WFCWindowManagementContext();
}
- (void)addWindow:(WFCWindow*)ptr {
    if( ![windows containsObject:ptr]) {
        [windows addObject:ptr];
    }
}
- (void)removeWindow:(WFCWindow*)ptr {
    if( [windows containsObject:ptr]) {
        [windows removeObject:ptr];
    }
}

- (WFCSDLWindow*)querySDLWindowByID:(NSUInteger)windowID {
    const NSUInteger count = [windows count];
    for( NSUInteger i = 0;i < count;++i) {
        WFCSDLWindow *w = (WFCSDLWindow*)[windows objectAtIndex:i];
        SDL_Window *raw = [w window];
        if( SDL_GetWindowID( raw) == windowID) {
            return w;
        }
    }
    return NULL;
}

- (BOOL)pollEvent {
// #ifdef WFC_BACKEND_SDL
    SDL_Event e;
    int has = SDL_PollEvent( &e);
    if( has == 0) return NO;

    if( e.type == SDL_QUIT) {
        if( target && closeAction) {
            [target performSelector:closeAction withObject:self];
        }
        return NO;
    }

    NSUInteger timestamp = e.common.timestamp;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    WFCResponderEvent *event = NULL;
    NSUInteger _id = 0;
    WFCSDLWindow *_target;

    switch( e.type) {
        case SDL_MOUSEBUTTONDOWN:
        case SDL_MOUSEBUTTONUP: {
            NSUInteger clicks = e.button.clicks;
            _id = e.button.windowID;
            _target = [self querySDLWindowByID:_id];
            WFCMouseButtonType _button = WFCButtonTypeNone;

            switch( e.button.button) {
                case SDL_BUTTON_LEFT:
                    _button = WFCButtonTypeLeft;
                    break;
                case SDL_BUTTON_MIDDLE:
                    _button = WFCButtonTypeMiddle;
                    break;
                case SDL_BUTTON_RIGHT:
                    _button = WFCButtonTypeRight;
                    break;
            }

            event =
                [[WFCResponderEvent
                    mouseEventWithType:(e.type == SDL_MOUSEBUTTONDOWN) ? WFCResponderEventTypeMouseDown : WFCResponderEventTypeMouseUp // a binary result
                    button:_button
                    timpstamp:timestamp
                    window:_target
                    location:WFCPoint( e.button.x, e.button.y)
                    click:clicks] autorelease];
            if( e.type == SDL_MOUSEBUTTONDOWN) {
                [_target onMouseDown:event];
            }else {
                [_target onMouseUp:event];
            }
            break;
        }
        case SDL_KEYDOWN:
        case SDL_KEYUP:
            _id = e.key.windowID;
            _target = [self querySDLWindowByID:_id];

            event =
                [[WFCResponderEvent
                    keyEventWithType:(e.type == SDL_KEYDOWN) ? WFCResponderEventTypeKeyDown : WFCResponderEventTypeKeyUp
                    key:e.key.keysym.sym
                    modifiers:e.key.keysym.mod
                    timpstamp:timestamp
                    window:_target] autorelease];
            if( e.type == SDL_KEYDOWN) {
                [_target onKeyDown:event];
            }else {
                [_target onKeyUp:event];
            }
            break;
        default:
            break;
    }

    [pool release];
    return YES;
// #endif
    // return NO;
}

- (void)updateWindows:(float)delta {

}
- (void)paintWindows {

}
@end

WFCWindowManagement *gManagement = NULL;
WFCWindowManagement* WFCWindowManagementContext() {
    if( gManagement == NULL) {
        gManagement = [WFCWindowManagement new];
    }
    return gManagement;
}
