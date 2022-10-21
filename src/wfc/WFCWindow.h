#import <SDL.h>
#import <PKFont.h>
#import "renderers/WFCRenderer.h"
#import "controls/WFCBaseControl.h"
#import "WFCLang.h"

typedef NS_ENUM( NSUInteger, WFCWindowState) {
    WFCFreeWindow = 0,
    WFCFocusingWindow
};
typedef NS_OPTIONS( NSUInteger, WFCWindowFlags) {
    WFCResizable    = 1 << 0,
    WFCBorderLess   = 1 << 1
};

typedef struct WFCKey {
    SDL_Keymod mod;
    SDL_KeyCode code;
} WFCKey;
@protocol WFCHotkeyResponder
- (void)addHotkey:(WFCKey)key processer:(void(^)( WFCKey key))func;
- (void)processHotkey:(WFCKey)key;
- (BOOL)hasHotkey:(WFCKey)key;
@end

@class WFCWindow;
@interface WFCDrawContext : NSObject {
    @private
    WFCWindow *target;
    struct WFCRect area;
    struct WFCPoint offset_;

    WFCBaseRenderer *renderer;
}
@property (readwrite) struct WFCRect area;

- (id)initFromWindow:(WFCWindow*)wnd;
- (id)initFromContext:(WFCDrawContext*)ctx;
- (instancetype)clone;

- (void)setOffset:(struct WFCPoint)offset;
- (void)addOffset:(struct WFCPoint)addition;
- (struct WFCPoint)offset;

- (void)drawFilledRect:(struct WFCRect)rect color:(struct WFCColor)col;
- (void)drawImage:(WFCTexture*)txt at:(struct WFCPoint)pos;
- (void)drawText:(NSString*)text at:(struct WFCPoint)origin font:(PKFont*)font;
@end

@interface WFCWindow : NSObject {
    @private
    SDL_Window *mount;
    SDL_GLContext glContext;

    WFCSingleViewContainer *container;
    WFCWindowState state;
    WFCBaseRenderer *renderer;
    WFCDrawContext *ctx;

    WFCControl *lastHoveringComponent;

    BOOL mousePressing;
    int width, height;
}

@property (readwrite) WFCWindowState state;

@property (readonly) WFCBaseRenderer *renderer;

@property (readonly) NSUInteger windowID;
@property (readonly) BOOL mousePressing;
@property (readonly) int x;
@property (readonly) int y;
@property (readonly) int width;
@property (readonly) int height;

+ (instancetype)windowWithTitle:(NSString*)title width:(NSUInteger)w height:(NSUInteger)h flags:(WFCWindowFlags)f;

- (id)initWithTitle:(NSString*)title width:(NSUInteger)w height:(NSUInteger)h flags:(WFCWindowFlags)f;
- (id)initFrom:(SDL_Window*)window;

- (BOOL)processEvent:(SDL_Event*)e;
- (void)updateWindowStatus;

- (void)didChangeSizeWithPreviousWidth:(int)pw andHeight:(int)ph;

- (void)makeCurrentGLWindow;
- (void)draw;
- (void)swapWindow;
@end

@interface WFCWindowManager : NSObject {
    @private
    NSMutableArray *windows;
}

- (NSUInteger)windowCount;
- (WFCWindow*)windowAtIndex:(NSUInteger)index;

- (void)addWindow:(WFCWindow*)window;
- (void)removeWindow:(WFCWindow*)window;

- (BOOL)processEvent:(SDL_Event*)e;
- (void)draw;
@end

NSInteger WFCGetSDLEventWindowID( SDL_Event *e);
WFCWindowManager *WFCWindowManagerContext();