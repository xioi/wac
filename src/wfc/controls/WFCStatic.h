#import "WFCBaseControl.h"

typedef NS_ENUM( NSUInteger, WFCTextAlign) {
    WFCLeftText = 0,
    WFCCenterText,
    WFCRightText
};

@interface WFCStatic : WFCControl {
    @private
    NSString *text;
    WFCFont *font;
    WFCTextAlign align;
}
@property (readwrite, copy) NSString *text;
@property (readwrite, copy) WFCFont *font;
@property (readwrite) WFCTextAlign align;

@end