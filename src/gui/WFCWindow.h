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

@class WFCContainer;
@interface WFCComponent : NSObject {
    @protected
    WFCFRect mBounds;
    WFCWindow *root; // TODO:
    WFCContainer *parent;

    BOOL isHovering;
}
@property (readwrite, assign) WFCWindow *root;
@property (readwrite, assign) WFCContainer *parent;
@property (readwrite) WFCFRect bounds;
@property (readonly) NSString *uiName;
@property (readonly) BOOL focusable;
@property (readonly) BOOL isHovering;

- (WFCFSize)preferredSize;
- (void)setLocation:(WFCFPoint)location;
- (void)setSize:(WFCFSize)size;

- (WFCFPoint)absolutePosition;

- (void)mouseEnter;
- (void)mouseExit;

- (void)requestFocus;
- (void)didMouseEnter;
- (void)didMouseExit; // TODO: add tracking-area

- (BOOL)hitTest:(WFCFPoint)point;

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

- (WFCComponent*)mouseHit:(WFCFPoint)point;

- (void)layout;
- (void)draw:(WFCDrawContext*)ctx;
@end

@interface WFCLayouter : NSObject
- (void)layoutComponents:(WFCContainer*)container;
@end

@interface WFCFlowLayouter : WFCLayouter {
    @private
    int rcap, ccap;
}
@property (readwrite) int rcap; // row cap
@property (readwrite) int ccap; // column cap

- (id)initWithRowCap:(int)rcap columnCap:(int)ccap;
@end

@interface WFCGridLayouter : WFCLayouter {
    @private
    int cloumn, row, rcap, ccap;
}
@property (readwrite) int rows; // row count
@property (readwrite) int columns; // column count
@property (readwrite) int rcap; // row cap
@property (readwrite) int ccap; // column cap

- (id)initWithRows:(int)rows columns:(int)columns rowCap:(int)rcap columnCap:(int)ccap;
@end

@interface WFCSingleViewContainer : WFCContainer
- (id)initWithParent:(WFCContainer*)parent;
@end

// a debug component
@interface WFCColoredQuadComponent : WFCComponent {
    @private
    WFCColor color;
}
@property (readwrite) WFCColor color;

- (id)initWithColor:(WFCColor)color;
@end

@interface WFCWindow : NSObject {
    @private
    SDL_Window *mount;
    SDL_GLContext glContext;

    WFCSingleViewContainer *container;
    WFCWindowState state;
    WFCDrawContext *ctx;

    WFCComponent *lastHoveringComponent;

    int wdith, height;
}

@property (readwrite) WFCWindowState state;
@property (readonly) NSUInteger windowID;
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

@interface WFCWindowManager : NSObject {
    @private
    NSMutableArray *windows;
}

- (NSUInteger)windowCount;
- (WFCWindow*)windowAtIndex:(NSUInteger)index;

- (void)addWindow:(WFCWindow*)window;
- (void)removeWindow:(WFCWindow*)window;
@end

WFCWindowManager *WFCWindowManagerContext();