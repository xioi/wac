#import "WACWindow.h"
#import "WACRender.h"

WACTexture *txt;
float t = 0;

@implementation WACWindow
@synthesize state;
@synthesize width;
@synthesize height;

- (id)init {
    if( self = [super init]) {
        state = WACFreeWindow;
        txt = [WACTexture imageForPath:@"./tewi.png"];
    }
    return self;
}

- (id)initFrom:(SDL_Window*)window {
    if( self = [self init]) {
        mount = window;
        ctx = [[WACDrawContext alloc] initFromWindow:self];
    }
    return self;
}
- (void)dealloc {
    [ctx release];
    [txt release];
    [super dealloc];
}

- (void)draw {
    WACRenderBegin();
    WACClear( 1, 1, 1, 1);
    [container draw:ctx];
    WACDrawRect( WACNewFRect( 20, 20, 200, 200), WACNewColor( 1, 0, 0, 1));
    [txt drawAt:WACNewFPoint( 200, 200) width:400 height:400 angle:t];
    t += 1.0 * M_PI / 180;
    WACRenderEnd();
    SDL_GL_SwapWindow( mount);
}
- (BOOL)processEvent:(SDL_Event*)e {
    uint wnd_id = SDL_GetWindowID( mount);

    switch( e->type) {
        case SDL_QUIT:
            return NO;
        case SDL_WINDOWEVENT_SIZE_CHANGED: { // FIXME: 事件无效
            //int w = e->window.data1, h = e->window.data2;
            //WACOnViewportResized( w, h);
            break;
        }
        case SDL_MOUSEBUTTONDOWN: { // 处理鼠标按下事件
            if( e->button.windowID == wnd_id) {
                // TODO:
                // * 判断焦点
                // * dispatch消息
                //NSLog( @"Mouse Button Down %d in [%d,%d]", e->button.button, e->button.x, e->button.y);
            }
            break;
        }
        case SDL_KEYDOWN: { // 处理键盘按下事件
            if( e->key.windowID == wnd_id) {
                SDL_Keysym sym =  e->key.keysym;
                NSLog( @"Key down of %c Shift?:%d", sym.sym, sym.mod & KMOD_SHIFT);
            }
            break;
        }
    }

    return YES;
}

- (void)updateWindowStatus {
    SDL_GetWindowSize( mount, &width, &height);
}
@end

@implementation WACView
- (void)draw:(WACDrawContext*)ctx {
    // default method
}
@end

@implementation WACSingleViewContainer
- (id)initWithParent:(WACView*)parent_ {
    if( self = [self init]) {
        parent = parent_;
    }
    return self;
}
- (void)draw:(WACDrawContext*)ctx {
    //[ctx drawFilledRect:]
}
@end

@implementation WACDrawContext
@synthesize area;

- (id)initFromWindow:(WACWindow*)wnd {
    if( self = [self init]) {
        self->target = wnd;
    }
    return self;
}
- (id)initFromContext:(WACDrawContext*)ctx {
    if( self = [self init]) {
        self->target = ctx->target;
    }
    return self;
}
- (instancetype)clone {
    return [[WACDrawContext alloc] initFromContext:self];
}

- (void)setOffset:(WACFPoint)offset {
    WACSetOffset( offset);
}
- (void)drawFilledRect:(WACFRect)rect color:(WACColor)col {
    WACDrawRect( rect, col);
}
- (void)drawImage:(WACTexture*)txt at:(WACFPoint)pos {
    // TODO:add a more general method

}
@end
