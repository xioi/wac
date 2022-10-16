#import "WFCWindow.h"
//#import "WFCRender.h"

#import <ft2build.h>
#import FT_FREETYPE_H
#import <glad/glad.h>
#import <mathc.h>

#import "renderers/gl/WFCGLRenderer.h"

WFCTexture *txt;
float t = 0;

extern NSUInteger gTextProgram;

extern struct mat4 gProjectionMatrix;

WFCGLRenderer *renderer;
WFCTexture *texture;
WFCFont *font;

static SDL_GLContext gGLContext;
@implementation WFCWindow
@synthesize state;
@synthesize width;
@synthesize height;
@synthesize mousePressing;

- (WFCPoint)position {
    int wx, wy;
    SDL_GetWindowPosition( mount, &wx, &wy);
    return WFCSPoint( wx, wy);
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
                    WFCSColor(
                        (rand() % 256) / 256.0f,
                        (rand() % 256) / 256.0f,
                        (rand() % 256) / 256.0f, 1)]];
        }

        lastHoveringComponent = nil;
    }
    return self;
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
    if( renderer == NULL) {
        renderer = [WFCGLRenderer new];
        texture = [WFCTexture new];
        font = [WFCFont new];
        texture->name = @"tewi.png";
        [renderer loadTexture:texture];
        font->name = @"Arial Unicode.ttf";
        font->size = 32;
        [renderer loadFont:font];
    }

    [self makeCurrentGLWindow];

    [renderer renderBegin];
    [renderer drawFilledRectAt:svec2( 10, 10) size:svec2( 200, 200) color:WFCSColor( 1, 1, 1, 1)];
    [renderer drawTexturedRectAt:svec2( 10, 220) size:svec2( 200, 200) texture:texture];
    [renderer drawText:
        @"I can eat glass and it doesn't hurt me.\n"
        "我能吞下玻璃而不伤身体。"
        at:svec2( 10, 10) font:font];
    [renderer flush];
    [renderer renderEnd];
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
            WFCControl *hover = [container mouseHit:WFCSPoint( e->button.x, e->button.y)];
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
    [container setBounds:WFCSRect( 10, 10, width - 20, height - 20)];
    [container layout];
    //WFCDidViewportResize( width, height);
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
    /*
    [ctx drawFilledRect:[self bounds] color:WFCNewColor( 0.7, 0.7, 0.7, 1)];
    [super draw:ctx];
    */
}
@end

@implementation WFCColoredQuadComponent
@synthesize color;

- (NSString*)uiName {
    return @"WFCColoredQuadComponentUI";
}

- (WFCSize)preferredSize {
    return WFCSSize( 100, 100);
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

- (void)setOffset:(WFCPoint)offset_2 {
    /*
    WFCSetOffset( offset_2);
    offset_ = offset_2;
    */
}
- (void)addOffset:(WFCPoint)addition {
    offset_.x += addition.x;
    offset_.y += addition.y;
    [self setOffset:offset_];
}
- (WFCPoint)offset {
    return offset_;
}

- (void)drawFilledRect:(WFCRect)rect color:(WFCColor)col {
    //WFCDrawRect( rect, col);
}
- (void)drawImage:(WFCTexture*)txt at:(WFCPoint)pos {
    // TODO:add a more general method

}
- (void)drawText:(NSString*)text at:(WFCPoint)origin font:(PKFont*)font {
    // TODO:
    
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
