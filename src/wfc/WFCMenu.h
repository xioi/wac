// #import <platforms/WFCWindow.h>
#import <Foundation/Foundation.h>

@interface WFCMenuBar : NSObject {
    @protected
}
@end

@interface WFCMenu : NSObject {
    @protected

}
@end

@interface WFCBaseMenuItem : NSObject {
    @protected
    BOOL enabled;
    NSString *text;
    // icon;
}
@property (readwrite) BOOL enabled;
@property (readwrite, copy) NSString *text;
@end

@interface WFCTextMenuItem : WFCBaseMenuItem {
    @private
}
+ (instancetype)textMenuItemWithText:(NSString*)text_;
@end