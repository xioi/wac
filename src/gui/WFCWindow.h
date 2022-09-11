#import <SDL.h>
#import "WFCRender.h"

@interface WFCText : NSObject
- (NSString*)value;
- (NSString*)remake;
@end

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

@protocol WFCHotkeyProcesser
- (void)addHotkey:(WFCKey)key processer:(void(^)( WFCKey key))func;
- (void)processHotkey:(WFCKey)key;
- (BOOL)hasHotkey:(WFCKey)key;
@end

@interface WFCConstantText : WFCText {
    @private
    NSString *constant;
}
- (id)initFromString:(NSString*)constant;
+ (instancetype)textFromString:(NSString*)constant;
@end

@interface WFCLangText : WFCText {
    @private
    NSMutableArray *text;
    NSString *cache;
}
- (id)initFromString:(NSString*)lang;
+ (instancetype)textFromString:(NSString*)lang;
@end

@class WFCWindow;
@interface WFCDrawContext : NSObject {
    @private
    WFCWindow *target;
    WFCFRect area;
}
@property (readwrite) WFCFRect area;

- (id)initFromWindow:(WFCWindow*)wnd;
- (id)initFromContext:(WFCDrawContext*)ctx;
- (instancetype)clone;

- (void)setOffset:(WFCFPoint)offset;
- (void)drawFilledRect:(WFCFRect)rect color:(WFCColor)col;
- (void)drawImage:(WFCTexture*)txt at:(WFCFPoint)pos;
@end

@interface WFCComponent : NSObject {
    @protected
    WFCFRect bounds;
}
- (WFCFSize)preferredSize;
- (void)setLocation:(WFCFPoint)location;
- (void)setSize:(WFCFSize)size;
- (void)setBounds:(WFCFRect)bounds;
- (WFCFRect)bounds;
- (void)draw:(WFCDrawContext*)ctx;
@end

@interface WFCContainer : WFCComponent
- (void)addComponent:(WFCComponent*)component;
- (void)removeComponent:(WFCComponent*)component;
- (WFCComponent*)compoentForIndex:(NSUInteger)index;
- (NSUInteger)componentCount;
@end

@interface WFCLayouter : NSObject
@end

@interface WFCView : NSObject {
    @protected
    uint width, height;
    uint x, y;
}

- (void)draw:(WFCDrawContext*)ctx;
@end

@interface WFCSingleViewContainer : WFCView {
    @private
    WFCView *parent;
}
- (id)initWithParent:(WFCView*)parent;
@end

@interface WFCWindow : NSObject {
    @private
    SDL_Window *mount;
    SDL_GLContext glContext;

    WFCSingleViewContainer *container;
    WFCWindowState state;
    WFCDrawContext *ctx;

    int wdith, height;
}

@property (readwrite) WFCWindowState state;
@property (readonly) int width;
@property (readonly) int height;

+ (instancetype)windowWithTitle:(NSString*)title width:(NSUInteger)w height:(NSUInteger)h flags:(WFCWindowFlags)f;

- (id)initWithTitle:(NSString*)title width:(NSUInteger)w height:(NSUInteger)h flags:(WFCWindowFlags)f;
- (id)initFrom:(SDL_Window*)window;
- (void)draw;
- (BOOL)processEvent:(SDL_Event*)e;
- (void)updateWindowStatus;

- (void)makeCurrentGLWindow;

- (void)load;
@end