#import <Foundation/Foundation.h>
#import <SDL.h>
#import <stdarg.h>
#import "glad/glad.h"
#import "gui/nfd.h"
#import "gui/WACWindow.h"
#import "gui/WACRender.h"
#import "gui/WACLang.h"
#import <mathc.h>
#import <string.h>

NSString* WACFormat( NSString *fmt, ...);

WACLangMgr *gLangMgr;

int main( int argc, char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    SDL_Init( SDL_INIT_EVERYTHING);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 3);

    const uint width = 800, height = 600;

    SDL_Window *wnd = SDL_CreateWindow( "Waffle & Cookie",
    //SDL_Window *wnd = SDL_CreateWindow( [title UTF8String],
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        width, height, SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
    SDL_GLContext glContext = SDL_GL_CreateContext( wnd);
    int err = gladLoadGLLoader( SDL_GL_GetProcAddress);
    if( err == GL_FALSE) {
        NSLog( @"This graphics device doesn't support OpenGL 3.3.");
        goto end;
    }

    gLangMgr = [[[WACLangMgr alloc] init] autorelease];
    
    glEnable( GL_BLEND);
    glDisable( GL_DEPTH_TEST);
    glPixelStorei( GL_UNPACK_ALIGNMENT, 1);
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    WACWindow *wacWindow = [[[WACWindow alloc] autorelease] initFrom:wnd];
    WACRenderSetup();
    WACOnViewportResized( width, height);

    SDL_Event e;
    while( YES) {
        while( SDL_PollEvent( &e)) {
            if( ![wacWindow processEvent:&e]) goto end;
        }
        [wacWindow updateWindowStatus];
        WACOnViewportResized( [wacWindow width], [wacWindow height]);
        [wacWindow draw];
        SDL_Delay( 33);
    }
end:
    WACRenderCleanup();
    SDL_Quit();
    //[pool release];
    return 0;
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
