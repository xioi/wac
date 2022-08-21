#import "WACWindow.h"
#import "WACRender.h"

@implementation WACWindow
@synthesize status;

- (id)init {
    if( self = [super init]) {
        status = WACFreeWindow;
    }
    return self;
}

- (id)initFrom:(SDL_Window*)window {
    if( self = [self init]) {
        mount = window;
        cxt = [[WACDrawContext alloc] initFromWindow:self];
    }
    return self;
}
- (void)dealloc {
    [cxt release];
    [super dealloc];
}

- (void)draw {
    WACRenderBegin();
    WACClear( 1, 1, 1, 1);
    [container draw:cxt];
    WACDrawRect( WACNewFRect( -0.5, -0.5, 1, 1), WACNewColor( 1, 0, 0, 1));
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
@end

@implementation WACView
- (void)draw:(WACDrawContext*)cxt {
    // default method
}
@end

@implementation WACDrawContext
- (id)initFromWindow:(WACWindow*)wnd {
    if( self = [self init]) {
        self->target = wnd;
    }
    return self;
}
- (id)initFromContext:(WACDrawContext*)cxt {
    if( self = [self init]) {
        self->target = cxt->target;
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
@end