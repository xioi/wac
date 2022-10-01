#import "WFCWindow.h"
#import "WFCRender.h"

#import <ft2build.h>
#import FT_FREETYPE_H
#import <hb.h>
#import <hb-ft.h>
#import <glad/glad.h>
#import <mathc.h>

WFCTexture *txt;
float t = 0;

@implementation WFCComponent
@synthesize root;
@synthesize parent;
@synthesize isHovering;

- (NSString*)uiName {
    return @"WFCComponentUI";
}

- (BOOL)focusable {
    return NO;
}

- (void)requestFocus {
    // TODO: request focus
}

- (void)mouseEnter:(WFCMouseEvent)e {
    isHovering = YES;
    [self didMouseEnter:e];
}
- (void)mouseExit:(WFCMouseEvent)e {
    isHovering = NO;
    [self didMouseExit:e];
}
- (void)mouseDown:(WFCMouseEvent)e {
    [self didMouseDown:e];
}
- (void)mouseUp:(WFCMouseEvent)e {
    [self didMouseUp:e];
}

- (void)didMouseEnter:(WFCMouseEvent)e {}
- (void)didMouseExit:(WFCMouseEvent)e {}
- (void)didMouseDown:(WFCMouseEvent)e {}
- (void)didMouseUp:(WFCMouseEvent)e {}

- (WFCFPoint)absolutePosition {
    WFCFPoint ap;
    ap.x = 0; ap.y = 0;
    if( [self parent] != nil) {
        WFCFRect pb = [parent bounds];
        ap.x += pb.x;
        ap.y += pb.y;
    }
    ap.x += mBounds.x;
    ap.y += mBounds.y;
    return ap;
}

- (BOOL)hitTest:(WFCFPoint)point {
    WFCFPoint ap = [self absolutePosition];
    point.x -= ap.x; point.y -= ap.y;
    if( (point.x >= 0 && point.x <= mBounds.w) && (point.y >= 0 && point.y <= mBounds.h)) {
        return YES;
    }else {
        return NO;
    }
}

- (WFCFSize)preferredSize {
    return WFCNewFSize( rand() % 40 + 80, rand() % 80 + 80); // FIXME: to default size 100x100
}

- (void)setLocation:(WFCFPoint)location {
    [self setBounds:WFCNewFRect( location.x, location.y, mBounds.w, mBounds.h)];
}

- (void)setSize:(WFCFSize)size {
    [self setBounds:WFCNewFRect( mBounds.x, mBounds.y, size.w, size.h)];
}

- (void)setBounds:(WFCFRect)bounds_ {
    mBounds = bounds_;
}

- (WFCFRect)bounds {
    return mBounds;
}

- (void)draw:(WFCDrawContext*)ctx {
    // TODO:
    [ctx drawFilledRect:mBounds color:WFCNewColor( 0.7, 0, 0.7, 1)];
}
@end

@interface WFCInternalComponent : NSObject {
    @private
    WFCComponent *component;
    NSInteger attribute;
}

@property (readwrite, assign) WFCComponent *component;
@property (readwrite) NSInteger attribute;
@end

@implementation WFCInternalComponent
@synthesize component;
@synthesize attribute;
@end

@implementation WFCContainer
- (id)init {
    if( self = [super init]) {
        layouter = NULL;
        components = [NSMutableArray new];
    }
    return self;
}
- (id)initWithLayouter:(WFCLayouter*)l {
    if( self = [self init]) {
        [self setLayouter:l];
    }
    return self;
}
- (void)dealloc {
    [components release];
    [super dealloc];
}

- (WFCLayouter*)layouter {
    return layouter;
}
- (void)setLayouter:(WFCLayouter*)ll {
    layouter = ll;
    [layouter layoutComponents:self];
}

- (void)addComponent:(WFCComponent*)component {
    [self addComponent:component attribute:-1];
}
- (void)addComponent:(WFCComponent*)component attribute:(NSInteger)addition {
    WFCInternalComponent *ic = [WFCInternalComponent new];
    [ic setComponent:component];
    [ic setAttribute:addition];

    [component setRoot:[self root]];
    [component setParent:self];

    [components addObject:ic];
    [ic release];

    // XXX: Always re-layout as long as a new component is inserted?
    //NSLog( @"%d", self);
    [layouter layoutComponents:self];
}

- (void)removeComponent:(WFCComponent*)component {
    __block id target = NULL;
    [components enumerateObjectsUsingBlock:^( id _Nonnull o, NSUInteger i, BOOL * _Nonnull e) {
        if( [o component] == component) {
            *e = YES;
            target = o;
        }
    }];

    if( target == NULL) return;
    [components removeObject:target];
}
- (WFCComponent*)componentForIndex:(NSUInteger)index {
    WFCInternalComponent *ic = [components objectAtIndex:index];
    if( ic == NULL) return NULL;
    return [ic component];
}
- (NSInteger)componentAttributeForIndex:(NSUInteger)index {
    WFCInternalComponent *ic = [components objectAtIndex:index];
    if( ic == NULL) return -1;
    return [ic attribute];
}
- (NSUInteger)componentCount {
    return [components count];
}

- (WFCComponent*)mouseHit:(WFCFPoint)point {
    __block WFCComponent *target = nil;
    [components enumerateObjectsUsingBlock:^( id _Nonnull obj, NSUInteger i, BOOL * _Nonnull ret) {
        WFCComponent *component_ = [obj component];
        if( [component_ hitTest:point]) {
            target = component_;
            *ret = YES;
        }
    }];
    return target;
}

- (void)layout {
    [layouter layoutComponents:self];
}
- (void)draw:(WFCDrawContext*)ctx {
    WFCDrawContext *c2 = [ctx clone];
    [c2 addOffset:WFCNewFPoint( [self bounds].x, [self bounds].y)];
    NSUInteger c = [self componentCount];
    for( int i=0;i<c;++i) {
        [[self componentForIndex:i] draw:c2];
    }
    [c2 release];
}
@end

@implementation WFCLayouter
- (void)layoutComponents:(WFCContainer*)container {

}
@end

@implementation WFCFlowLayouter
@synthesize rcap;
@synthesize ccap;

- (id)init {
    if( self = [self initWithRowCap:1 columnCap:1]) {

    }
    return self;
}
- (id)initWithRowCap:(int)rcap_ columnCap:(int)ccap_{
    if( self = [super init]) {
        rcap = rcap_;
        ccap = ccap_;
    }
    return self;
}
- (void)layoutComponents:(WFCContainer*)container {
    WFCFPoint np;
    np.x = rcap;np.y = ccap;
    int lmh = 0;
    const NSUInteger c = [container componentCount];
    for( int i=0;i<c;++i) {
        WFCComponent *component = [container componentForIndex:i];
        WFCFSize pSize = [component preferredSize];

        //NSLog( @"%.2f %.2f", np.x + pSize.w + rcap, [container bounds].w);
        if( np.x + pSize.w + rcap > [container bounds].w) {
            np.x = rcap;
            np.y += lmh + ccap;
        }
        [component setBounds:WFCNewFRect( np.x, np.y, pSize.w, pSize.h)];
        np.x += pSize.w + rcap;

        if( pSize.h > lmh) lmh = pSize.h;
    }
}
@end

@implementation WFCGridLayouter
@synthesize rows;
@synthesize columns;
@synthesize rcap;
@synthesize ccap;

- (id)initWithRows:(int)rows_ columns:(int)columns_ rowCap:(int)rcap_ columnCap:(int)ccap_ {
    if( self = [self init]) {
        rcap = rcap_;
        ccap = ccap_;
        rows = rows_;
        columns = columns_;
    }
    return self;
}

- (void)layoutComponents:(WFCContainer*)container {
    const NSUInteger c = [container componentCount];
    const WFCFRect siz = [container bounds];
    int cw = (siz.w - ccap - columns * ccap) / columns, ch = (siz.h - rcap - rows * rcap) / rows;
    int cc = 0, rc = 0;
    for( int i=0;i<c;++i) {
        if( cc >= columns) {
            rc += 1;
            cc = 0;
        }
        WFCComponent *component = [container componentForIndex:i];
        [component setBounds:WFCNewFRect( (cc + 1) * ccap + cc * cw, (rc + 1) * rcap + rc * ch, cw, ch )];
        ++cc;
    }
}
@end

extern NSUInteger gTextProgram;

extern struct mat4 gProjectionMatrix;

static SDL_GLContext gGLContext;
@implementation WFCWindow
@synthesize state;
@synthesize width;
@synthesize height;
@synthesize mousePressing;

- (WFCFPoint)position {
    int wx, wy;
    SDL_GetWindowPosition( mount, &wx, &wy);
    return WFCNewFPoint( wx, wy);
}
- (int)x {
    return (int)[self position].x;
}
- (int)y {
    return (int)[self position].y;
}
- (NSUInteger)windowID {
    return SDL_GetWindowID( mount);
}

- (id)init {
    if( self = [super init]) {
        state = WFCFreeWindow;
        container =
            [[WFCSingleViewContainer new]
                //initWithLayouter:[[WFCFlowLayouter new] initWithRowCap:10 columnCap:10]];
                initWithLayouter:[[WFCGridLayouter new] initWithRows:4 columns:5 rowCap:10 columnCap:10]];
        [container setRoot:self];

        for( int i=0;i<20;++i) {
            [container addComponent:
                [[WFCColoredQuadComponent alloc] initWithColor:
                    WFCNewColor(
                        (rand() % 256) / 256.0f,
                        (rand() % 256) / 256.0f,
                        (rand() % 256) / 256.0f, 1)]];
        }

        lastHoveringComponent = nil;
    }
    return self;
}

- (void)load {
}

+ (instancetype)windowWithTitle:(NSString*)title width:(NSUInteger)w height:(NSUInteger)h flags:(WFCWindowFlags)f {
    return [[[WFCWindow alloc] initWithTitle:title width:w height:h flags:f] retain];
}

- (id)initWithTitle:(NSString*)title width:(NSUInteger)w height:(NSUInteger)h flags:(WFCWindowFlags)f {
    Uint32 flags = SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL;

    if( f & WFCResizable) {
        flags |= SDL_WINDOW_RESIZABLE;
    }
    if( f & WFCBorderLess) {
        flags |= SDL_WINDOW_BORDERLESS;
    }

    SDL_Window *wnd = SDL_CreateWindow( [title UTF8String],
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        w, h, flags);
    
    if( self = [self initFrom:wnd]) {
    }else {
        if( wnd != NULL) {
            SDL_DestroyWindow( wnd);
        }
        return NULL;
    }
    return self;
}
- (id)initFrom:(SDL_Window*)window {
    if( self = [self init]) {
        mount = window;
        ctx = [[WFCDrawContext alloc] initFromWindow:self];
        //glContext = SDL_GL_CreateContext( window);
        
        if( gGLContext == nil) {
            gGLContext = SDL_GL_CreateContext( window);
        }
        //[self didChangeSizeWithPreviousWidth:0 andHeight:0];
    }
    return self;
}
- (void)dealloc {
    [ctx release];
    [txt release];
    [super dealloc];
}

- (void)draw {
    [self makeCurrentGLWindow];

    WFCClear( 1, 1, 1, 1);
    [ctx setOffset:WFCNewFPoint( 0, 0)];
    [container draw:ctx];

    /* [ctx setOffset:WFCNewFPoint( 0, 0)];
    if( lastHoveringComponent != nil) {
        WFCFRect r_focus = [lastHoveringComponent bounds];
        WFCFPoint offset_focus = [lastHoveringComponent absolutePosition];
        r_focus.x = offset_focus.x;
        r_focus.y = offset_focus.y;
        [ctx drawFilledRect:r_focus color:WFCNewColor( 1, 0, 0, 0.5)];
    } */
    [self swapWindow];
}
- (void)swapWindow {
    SDL_GL_SwapWindow( mount);
}
- (BOOL)processEvent:(SDL_Event*)e {
    NSUInteger wnd_id = SDL_GetWindowID( mount);

    switch( e->type) {
        case SDL_MOUSEBUTTONDOWN: { // 处理鼠标按下事件
            mousePressing = YES;
            WFCMouseEvent me;
            me.type = WFCMouseDown;
            me.x = e->button.x;
            me.y = e->button.y;
            me.button = e->button.button;
            me.times = e->button.clicks;

            if( e->button.clicks >= 2) {
                NSLog( @"Clicked %d times", e->button.clicks);
            }
            if( lastHoveringComponent != nil) {
                [lastHoveringComponent mouseDown:me];
            }
            break;
        }
        case SDL_MOUSEBUTTONUP: { // 处理鼠标抬起事件
            mousePressing = NO;
            break;
        }
        case SDL_MOUSEMOTION: {
            WFCComponent *hover = [container mouseHit:WFCNewFPoint( e->button.x, e->button.y)];
            WFCMouseEvent mouseevent;
                mouseevent.x = e->button.x;
                mouseevent.y = e->button.y;
            if( hover == nil) {
                mouseevent.type = WFCMouseExit;
                [lastHoveringComponent mouseExit:mouseevent]; // send exit
            }else if( hover != lastHoveringComponent) {
                mouseevent.type = WFCMouseExit;
                [lastHoveringComponent mouseExit:mouseevent]; // send exit
                mouseevent.type = WFCMouseEnter;
                [hover mouseEnter:mouseevent]; // send enter
                lastHoveringComponent = hover;
            }
            break;
        }
        case SDL_KEYDOWN: { // TODO:处理键盘按下事件
            break;
        }
    }
    [self updateWindowStatus];

    return YES;
}

- (void)didChangeSizeWithPreviousWidth:(int)pw andHeight:(int)ph {
    //NSLog( @"%d %d", width, height);
    [container setBounds:WFCNewFRect( 10, 10, width - 20, height - 20)];
    [container layout];
    WFCOnViewportResized( width, height);
}

- (void)updateWindowStatus {
    int previousw = width, previoush = height;
    SDL_GetWindowSize( mount, &width, &height);

    if( previousw != width || previoush != height) {
        [self didChangeSizeWithPreviousWidth:previousw andHeight:previoush];
    }
}

- (void)makeCurrentGLWindow {
    SDL_GL_MakeCurrent( mount, gGLContext);
}
@end

@implementation WFCSingleViewContainer
- (id)initWithParent:(WFCContainer*)parent_ {
    if( self = [self init]) {
        parent = parent_;
    }
    return self;
}
- (void)draw:(WFCDrawContext*)ctx {
    [ctx drawFilledRect:[self bounds] color:WFCNewColor( 0.7, 0.7, 0.7, 1)];
    [super draw:ctx];
}
@end

@implementation WFCColoredQuadComponent
@synthesize color;

- (NSString*)uiName {
    return @"WFCColoredQuadComponentUI";
}

- (WFCFSize)preferredSize {
    return WFCNewFSize( 100, 100);
}

- (id)initWithColor:(WFCColor)color_ {
    if( self = [self init]) {
        color = color_;
    }
    return self;
}

- (void)didMouseDown:(WFCMouseEvent)e {
    NSLog( @"clicked %d times! isHovering:%d", e.times, isHovering);
}

- (void)draw:(WFCDrawContext*)ctx {
    WFCColor color2 = color;
    if( [self isHovering]) {
        color2.a = 0.5;
    }
    [ctx drawFilledRect:mBounds color:color2];
}
@end

@implementation WFCDrawContext
@synthesize area;

- (id)initFromWindow:(WFCWindow*)wnd {
    if( self = [self init]) {
        self->target = wnd;
    }
    return self;
}
- (id)initFromContext:(WFCDrawContext*)ctx {
    if( self = [self init]) {
        self->target = ctx->target;
        self->area = ctx->area;
    }
    return self;
}
- (instancetype)clone {
    return [[WFCDrawContext alloc] initFromContext:self];
}

- (void)setOffset:(WFCFPoint)offset_2 {
    WFCSetOffset( offset_2);
    offset_ = offset_2;
}
- (void)addOffset:(WFCFPoint)addition {
    offset_.x += addition.x;
    offset_.y += addition.y;
    [self setOffset:offset_];
}
- (WFCFPoint)offset {
    return offset_;
}

- (void)drawFilledRect:(WFCFRect)rect color:(WFCColor)col {
    WFCDrawRect( rect, col);
}
- (void)drawImage:(WFCTexture*)txt at:(WFCFPoint)pos {
    // TODO:add a more general method

}
@end

@implementation WFCWindowManager
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

- (NSUInteger)windowCount {
    return [windows count];
}
- (WFCWindow*)windowAtIndex:(NSUInteger)index {
    if( index >= [windows count]) {
        return nil;
    }
    return [windows objectAtIndex:index];
}

- (void)addWindow:(WFCWindow*)window {
    __block BOOL exist = NO;
    [windows enumerateObjectsUsingBlock:^( id obj, NSUInteger i, BOOL *stop) {
        if( obj == window) {
            exist = YES;
            *stop = YES;
            return;
        }
    }];
    if( !exist) {
        [windows addObject:window];
    }
}
- (void)removeWindow:(WFCWindow*)window {
    [windows removeObject:window];
}

- (BOOL)processEvent:(SDL_Event*)e {
    if( e->type == SDL_QUIT) return NO;
    NSUInteger c = [self windowCount];
    NSInteger wid = WFCGetSDLEventWindowID( e);
    for( NSUInteger i=0;i<c;++i) {
        WFCWindow *wnd = [self windowAtIndex:i];
        if( wid == -1) continue;
        if( wid == -2) {
            [wnd processEvent:e];
            continue;
        }
        if( [wnd windowID] == wid) {
            [wnd processEvent:e];
            break;
        }
    }
    return YES;
}
- (void)draw {
    NSUInteger c = [self windowCount];
    for( NSUInteger i=0;i<c;++i) {
        [[self windowAtIndex:i] draw];
    }
}
@end

static NSLock *gWindowManagerLock = nil;
static WFCWindowManager *gWindowManager = nil;
WFCWindowManager *WFCWindowManagerContext() {
    [gWindowManagerLock lock];
    if( gWindowManager == nil) {
        gWindowManager = [WFCWindowManager new];
    }
    [gWindowManagerLock unlock];
    return gWindowManager;
}

NSInteger WFCGetSDLEventWindowID( SDL_Event *e) {
    switch( e->type) {
        case SDL_MOUSEMOTION:
            return e->motion.windowID;
            break;
        case SDL_MOUSEBUTTONDOWN:
        case SDL_MOUSEBUTTONUP:
            return e->button.windowID;
            break;
        case SDL_MOUSEWHEEL:
            return e->wheel.windowID;
        case SDL_KEYDOWN:
        case SDL_KEYUP:
            return e->key.windowID;
        // TODO:
        default:
            break;
    }
    return -2; // for all windows
}

void WFCWindowInit() {
    gWindowManagerLock = [NSLock new];
}
