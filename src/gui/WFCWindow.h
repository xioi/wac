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
    WFCFPoint offset_;
}
@property (readwrite) WFCFRect area;

- (id)initFromWindow:(WFCWindow*)wnd;
- (id)initFromContext:(WFCDrawContext*)ctx;
- (instancetype)clone;

- (void)setOffset:(WFCFPoint)offset;
- (void)addOffset:(WFCFPoint)addition;
- (WFCFPoint)offset;

- (void)drawFilledRect:(WFCFRect)rect color:(WFCColor)col;
- (void)drawImage:(WFCTexture*)txt at:(WFCFPoint)pos;
@end

@interface WFCComponent : NSObject {
    @protected
    WFCFRect mBounds;
}
- (WFCFSize)preferredSize;
- (void)setLocation:(WFCFPoint)location;
- (void)setSize:(WFCFSize)size;
- (void)setBounds:(WFCFRect)bounds;
- (WFCFRect)bounds;
- (void)draw:(WFCDrawContext*)ctx;
@end

@class WFCLayouter;
@interface WFCContainer : WFCComponent {
    @protected
    WFCLayouter *layouter;
    NSMutableArray *components;
}
@property (readwrite, copy) WFCLayouter *layouter;

- (id)initWithLayouter:(WFCLayouter*)l;

- (void)addComponent:(WFCComponent*)component;
- (void)addComponent:(WFCComponent*)component attribute:(NSInteger)addition;

- (void)removeComponent:(WFCComponent*)component;
- (WFCComponent*)componentForIndex:(NSUInteger)index;
- (NSInteger)componentAttributeForIndex:(NSUInteger)index;
- (NSUInteger)componentCount;

- (void)layout;
- (void)draw:(WFCDrawContext*)ctx;
@end

@interface WFCLayouter : NSObject
- (void)layoutComponents:(WFCContainer*)container;
@end

@interface WFCFlowLayouter : WFCLayouter {
    @private
    int rcap;
}
- (id)initWithRowCap:(int)rcap;
@end

@interface WFCSingleViewContainer : WFCContainer {
    @private
    WFCContainer *parent;
}
- (id)initWithParent:(WFCContainer*)parent;
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

- (void)didChangeSizeWithPreviousWidth:(int)pw andHeight:(int)ph;

- (void)makeCurrentGLWindow;

- (void)load;
@end