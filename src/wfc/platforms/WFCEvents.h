#import <Foundation/Foundation.h>

typedef NS_ENUM( NSUInteger, WFCEventType) {
    WFCNoEvent = 0,
};

typedef NS_ENUM( NSUInteger, WFCFocusEventType) {
    WFCFocusEnter   = 0,
    WFCFocusExit    = 1,
};
struct WFCFocusEvent {
    WFCFocusEventType type;
};

struct WFCViewEvent {
    union {
        struct WFCFocusEvent focus;
    } event;

    WFCEventType type;
};