//#import "WFCRender.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM( NSUInteger, WFCMouseEventType) {
    WFCMouseMotion = 0,
    WFCMouseDown,
    WFCMouseUp,
    WFCMouseEnter,
    WFCMouseExit
};
typedef struct {
    WFCMouseEventType type;
    int x, y;
    int times;

    uint8_t state;
    uint8_t button;
} WFCMouseEvent;

@protocol WFCUIEventResponder
- (void)didMouseEnter:(WFCMouseEvent)e;
- (void)didMouseExit:(WFCMouseEvent)e;
- (void)didMouseDown:(WFCMouseEvent)e;
- (void)didMouseUp:(WFCMouseEvent)e;
@end