#import <Foundation/Foundation.h>
#import <SDL.h>
#import <stdarg.h>
#import "glad/glad.h"
#import "gui/WFCWindow.h"
#import "gui/WFCRender.h"
#import "gui/WFCLang.h"

#define WAC_OPENGL_VERSION_MAJOR 3
#define WAC_OPENGL_VERSION_MINOR 3

NSString* WACFormat( NSString *fmt, ...);
void WACInit();
NSUInteger WACGetSDLEventWindowID( SDL_Event *e);

int main( int argc, char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    SDL_Init( SDL_INIT_EVERYTHING);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, WAC_OPENGL_VERSION_MAJOR);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, WAC_OPENGL_VERSION_MINOR);

    WACInit();

    const uint width = 800, height = 600;
    WFCWindow *wacWindow =
        [[WFCWindow
            windowWithTitle:@"Waffle & Cookie"
            width:width
            height:height
            flags:WFCResizable] autorelease];
    [wacWindow makeCurrentGLWindow];

    int err = gladLoadGLLoader( SDL_GL_GetProcAddress);
    if( err == GL_FALSE) {
        NSLog( @"This graphics device doesn't support OpenGL 3.3.");
        exit( 1);
    }
    
    glEnable( GL_BLEND);
    glDisable( GL_DEPTH_TEST);
    glPixelStorei( GL_UNPACK_ALIGNMENT, 1);
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    [wacWindow load];
    WFCRenderSetup();
    WFCOnViewportResized( width, height);

    WFCWindowManager *wndMgr = WFCWindowManagerContext();
    [wndMgr addWindow:wacWindow];

    SDL_Event e;
    while( YES) {
        while( SDL_PollEvent( &e)) {
            if( e.type == SDL_QUIT) goto end;
            //if( ![wacWindow processEvent:&e]) goto end;
            uint c = [wndMgr windowCount];
            for( uint i=0;i<c;++i) {
                WFCWindow *wnd = [wndMgr windowAtIndex:i];
                NSUInteger wid = WACGetSDLEventWindowID( &e);
                if( [wnd windowID] == wid) {
                    [wnd processEvent:&e];
                    break;
                }
            }
        }
        [wacWindow draw];
        SDL_Delay( 33);
    }
end:
    WFCRenderCleanup();
    SDL_Quit();
    [pool release];
    return 0;
}

void WFCWindowInit();
void WACInit() {
    WFCWindowInit();
}

NSUInteger WACGetSDLEventWindowID( SDL_Event *e) {
    switch( e->type) {
        case SDL_MOUSEMOTION:
        case SDL_MOUSEBUTTONDOWN:
        case SDL_MOUSEBUTTONUP:
            return e->button.windowID;
            break;
        default: // TODO: add more
            break;
    }
    return 99999;
}

NSString* WACFormat( NSString *fmt, ...) {
    NSString *args[128], *now;
    int i=0;
    va_list l;
    va_start( l, fmt);
    while( (now = va_arg( l, NSString*)) != 0) {
        args[i] = now;
        ++i;
    }
    va_end( l);
    NSMutableString *r = [NSMutableString new];
    uint begin = 0, ptr = 0, end = [fmt length];
    while( ptr < end) {
        uint fw = ptr;
        while( fw <= end) {
            if( fw == end) {
                [r appendString:[fmt substringWithRange:NSMakeRange( ptr - begin, fw - ptr)]];
                break;
            }
            if( [fmt characterAtIndex:fw] == '{') {
                [r appendString:[fmt substringWithRange:NSMakeRange( ptr - begin, fw - ptr)]];
                ++fw;
                uint value = 0;
                while( [fmt characterAtIndex:fw] != '}') {
                    value *= 10;
                    value += [fmt characterAtIndex:fw] - '0';
                    ++fw;
                }
                // unsafe
                [r appendString:args[value]];
                ++fw;
                break;
            }
            ++fw;
        }
        ptr = fw;
    }
    return r;
}
