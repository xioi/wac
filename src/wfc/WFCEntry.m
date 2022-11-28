#import "WFCEntry.h"
#ifdef WFC_BACKEND_SDL
#import <SDL.h>
#define WFC_OPENGL_VERSION_MAJOR 3
#define WFC_OPENGL_VERSION_MINOR 3

void WFCInit( struct WFCInit *args) {
    SDL_Init( SDL_INIT_EVERYTHING);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, WFC_OPENGL_VERSION_MAJOR);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, WFC_OPENGL_VERSION_MINOR);
}
void WFCShutdown() {
    SDL_Quit();
}
#else
void WFCInit( struct WFCInit *args) {
}
void WFCShutdown() {
}
#endif