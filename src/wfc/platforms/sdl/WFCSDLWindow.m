#import "WFCSDLWindow.h"
#import <renderers/gl/WFCGLRenderer.h>

WFCGLRenderer *gGLRenderer = NULL;
SDL_GLContext gGLContext;

@implementation WFCSDLWindow
@synthesize window;

- (struct WFCSize)size {
    int w, h;
    SDL_GetWindowSize( window, &w, &h);
    self->size = WFCSize( w, h);
    return self->size;
}

- (void)setSize:(struct WFCSize)size_ {
    [super setSize:size_];
    SDL_SetWindowSize( window, self->size.w, self->size.h);
}

- (void)setStyle:(WFCWindowStyle)style_ {
    [super setStyle:style_];
}

- (void)createWindow {
    window = SDL_CreateWindow(
        "Waffle Core Window",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        800, 600, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
    
    if( gGLRenderer == NULL) {
        SDL_GLContext context = SDL_GL_CreateContext( window);
        gGLContext = context;

        [WFCGLRenderer loadGLFunctions];
        gGLRenderer = [WFCGLRenderer new];
    }

    SDL_SetWindowResizable( window, YES);
}

- (id)init {
    if( self = [super init]) {
        [self createWindow];
        SDL_ShowWindow( window);
    }
    return self;
}
- (void)setTitle:(NSString*)title_ {
    [super setTitle:title_];
    SDL_SetWindowTitle( window, [title UTF8String]);
}
@end

@implementation WFCSDLWindow (Appearance)
- (void)initializePaintContext:(WFCPaintContext*)ctx {
    ctx.renderer = gGLRenderer;
}

- (void)windowWillPaint {
    SDL_GL_MakeCurrent( window, gGLContext);
}
- (void)windowDoPaint {
    // WFCGLRenderer *rnd = (WFCGLRenderer*)ctx.renderer;
    [gGLRenderer renderBegin];
    [gGLRenderer renderEnd];
}
- (void)windowDidPaint {
    SDL_GL_SwapWindow( window);
}
@end
