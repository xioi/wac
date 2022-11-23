#import "glad/glad.h"
#import <WFCEntry.h>
#import <platforms/sdl/WFCSDLWindow.h>
#import <renderers/gl/WFCGLRenderer.h>
#import <PKException.h>
#import <SDL.h>

NSString* WACFormat( NSString *fmt, ...);
BOOL running = YES;

@interface application : NSObject
- (void)close:(WFCWindowManagement*)sender;
@end

int main( int argc, char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    struct WFCInit init;
    init.argc = argc;
    init.argv = argv;
    WFCInit( &init);

    WFCWindow *window = [[[WFCSDLWindow alloc] initWithTitle:@"Waffle & Cookie"] addToManagement];

    WFCWindowManagement *management = WFCWindowManagementContext();
    [management setTarget:[[application new] autorelease]];
    [management setCloseAction:@selector(close:)];
    while( running) {
        while( [management pollEvent]) {
        }
        [management updateWindows:1.0/30];
        [management paintWindows];
        SDL_Delay( 33);
    }
end:
    WFCShutdown();
    [pool release];
    return 0;
}

@implementation application
- (void)close:(WFCWindowManagement*)sender {
    running = NO;
}
@end

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
