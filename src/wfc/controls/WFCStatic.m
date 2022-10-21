#import "WFCStatic.h"
#import <WFCWindow.h>

@implementation WFCStatic
@synthesize text;
@synthesize font;
@synthesize align;

- (id)init {
    if( self = [super init]) {
        text = @"";
        font = NULL;
        align = WFCLeftText;
    }
}

- (void)loadDefaultFont {
    WFCBaseRenderer *rnd = [[self root] renderer];

}

- (WFCSize)preferredSize {
    WFCBaseRenderer *rnd = [[self root] renderer];
    if( font == NULL) [self loadDefaultFont];
    struct vec2 text_size = [rnd measureText:text font:font];
    return WFCSize( text_size.x, text_size.y);
}

- (void)draw:(WFCDrawContext*)ctx {
}
@end
