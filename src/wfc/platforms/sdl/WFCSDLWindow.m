#import "WFCSDLWindow.h"

@implementation WFCSDLWindow
@synthesize window;

- (void)createWindow {
    window = SDL_CreateWindow(
        "Waffle Core Window",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        800, 600, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
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

