#import <SDL.h>
#import "WACRender.h"

@interface WACText : NSObject
- (NSString*)value;
@end

typedef NS_ENUM( NSUInteger, WACWindowStatus) {
    WACFreeWindow = 0,
    WACFocusingWindow
};

typedef struct WACKey {
    SDL_Keymod mod;
    SDL_KeyCode code;
} WACKey;

@protocol WACHotkeyProcesser
- (void)addHotkey:(WACKey)key processer:(void(^)( WACKey key))func;
- (void)processHotkey:(WACKey)key;
- (BOOL)hasHotkey:(WACKey)key;
@end

@interface WACConstantText : WACText {
    @private
    NSString *constant;
}
- (id)initFromString:(NSString*)constant;
+ (instancetype)textFromString:(NSString*)constant;
@end

@interface WACLangText : WACText {
    @private
    NSString *lang;
}
- (id)initFromString:(NSString*)lang;
+ (instancetype)textFromString:(NSString*)lang;
@end

@class WACWindow;
@interface WACDrawContext : NSObject {
    @private
    WACWindow *target;
}
- (id)initFromWindow:(WACWindow*)wnd;
- (id)initFromContext:(WACDrawContext*)cxt;
- (instancetype)clone;

- (void)setOffset:(WACFPoint)offset;
- (void)drawFilledRect:(WACFRect)rect color:(WACColor)col;
- (void)drawImage:(WACTexture*)txt at:(WACFPoint)pos;
@end

@interface WACView : NSObject {
    @protected
    uint width, height;
    uint x, y;
}

- (void)draw:(WACDrawContext*)cxt;
@end

@interface WACSingleViewContainer : WACView {
    @private
    WACView *view;
}
@end

@interface WACWindow : NSObject {
    @private
    SDL_Window *mount;
    WACSingleViewContainer *container;
    WACWindowStatus status;
    WACDrawContext *cxt;
}

@property (readwrite) WACWindowStatus status;

- (id)initFrom:(SDL_Window*)window;
- (void)draw;
- (BOOL)processEvent:(SDL_Event*)e;

@end