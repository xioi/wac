#import "../WFCWindow.h"
#import <SDL.h>

@interface WFCSDLWindow : WFCWindow {
    @private
    SDL_Window *window;
    
}
@property (readonly) SDL_Window *window;
@end