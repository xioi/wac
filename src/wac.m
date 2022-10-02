#import <Foundation/Foundation.h>
#import <SDL.h>
#import <stdarg.h>
#import "glad/glad.h"
#import <WFCWindow.h>
#import <WFCRender.h>
#import <WFCLang.h>
#import <PKException.h>

#define WAC_OPENGL_VERSION_MAJOR 3
#define WAC_OPENGL_VERSION_MINOR 3

NSString* WACFormat( NSString *fmt, ...);
void WACInit();

int main( int argc, char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    WACInit();

    const unsigned int width = 800, height = 600;
    WFCWindow *wacWindow =
        [[WFCWindow
            windowWithTitle:@"Waffle & Cookie"
            width:width
            height:height
            flags:WFCResizable] autorelease];

    int err = gladLoadGLLoader( SDL_GL_GetProcAddress);
    if( err == GL_FALSE) {
        PKRuntimeError( @"This graphics device doesn't support OpenGL %d.%d.", WAC_OPENGL_VERSION_MAJOR, WAC_OPENGL_VERSION_MINOR);
        PKExit( 1);
    }

    WFCRenderSetup();
    WFCOnViewportResized( width, height);

    WFCWindowManager *wndMgr = WFCWindowManagerContext();
    [wndMgr addWindow:wacWindow];

    SDL_Event e;
    while( YES) {
        while( SDL_PollEvent( &e)) {
            if( ![wndMgr processEvent:&e]) goto end;
        }
        [wndMgr draw];
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
    SDL_Init( SDL_INIT_EVERYTHING);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, WAC_OPENGL_VERSION_MAJOR);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, WAC_OPENGL_VERSION_MINOR);

    WFCWindowInit();
#ifdef WAC_DEBUG
    NSLog( @"[DEBUG] Waffle & Cookie (OpenGL%d.%d) Initialized.", WAC_OPENGL_VERSION_MAJOR, WAC_OPENGL_VERSION_MINOR);
#endif
}

// NSLog( @"%@", WACFormat( @"{0} {1} {0}", @"0", @"1")); ---> "0 1 0"
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
    unsigned int begin = 0, ptr = 0, end = [fmt length];
    while( ptr < end) {
        unsigned int fw = ptr;
        while( fw <= end) {
            if( fw == end) {
                [r appendString:[fmt substringWithRange:NSMakeRange( ptr - begin, fw - ptr)]];
                break;
            }
            if( [fmt characterAtIndex:fw] == '{') {
                [r appendString:[fmt substringWithRange:NSMakeRange( ptr - begin, fw - ptr)]];
                ++fw;
                unsigned int value = 0;
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
