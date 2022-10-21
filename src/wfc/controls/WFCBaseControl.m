#import "WFCBaseControl.h"


@implementation WFCControl
@synthesize root;
@synthesize parent;
@synthesize isHovering;

- (NSString*)uiName {
    return @"WFCComponentUI";
}

- (BOOL)focusable {
    return NO;
}

- (void)requestFocus {
    // TODO: request focus
}

- (void)mouseEnter:(WFCMouseEvent)e {
    isHovering = YES;
    [self didMouseEnter:e];
}
- (void)mouseExit:(WFCMouseEvent)e {
    isHovering = NO;
    [self didMouseExit:e];
}
- (void)mouseDown:(WFCMouseEvent)e {
    [self didMouseDown:e];
}
- (void)mouseUp:(WFCMouseEvent)e {
    [self didMouseUp:e];
}

- (void)didMouseEnter:(WFCMouseEvent)e {}
- (void)didMouseExit:(WFCMouseEvent)e {}
- (void)didMouseDown:(WFCMouseEvent)e {}
- (void)didMouseUp:(WFCMouseEvent)e {}

- (struct WFCPoint)absolutePosition {
    struct WFCPoint ap;
    ap.x = 0; ap.y = 0;
    if( [self parent] != nil) {
        struct WFCRect pb = [parent bounds];
        ap.x += pb.origin.x;
        ap.y += pb.origin.y;
    }
    ap.x += mBounds.origin.x;
    ap.y += mBounds.origin.y;
    return ap;
}

- (BOOL)hitTest:(struct WFCPoint)point {
    struct WFCPoint ap = [self absolutePosition];
    point.x -= ap.x; point.y -= ap.y;
    if( (point.x >= 0 && point.x <= mBounds.size.w) && (point.y >= 0 && point.y <= mBounds.size.h)) {
        return YES;
    }else {
        return NO;
    }
}

- (struct WFCSize)preferredSize {
    return WFCSize( rand() % 40 + 80, rand() % 80 + 80); // FIXME: to default size 100x100
}

- (void)setLocation:(struct WFCPoint)location {
    [self setBounds:WFCRect( location.x, location.y, mBounds.size.w, mBounds.size.h)];
}

- (void)setSize:(struct WFCSize)size {
    [self setBounds:WFCRect( mBounds.origin.x, mBounds.origin.y, size.w, size.h)];
}

- (void)setBounds:(struct WFCRect)bounds_ {
    mBounds = bounds_;
}

- (struct WFCRect)bounds {
    return mBounds;
}

- (void)draw:(WFCDrawContext*)ctx {
    // TODO:
    //[ctx drawFilledRect:mBounds color:WFCNewColor( 0.7, 0, 0.7, 1)];
}
@end

@interface WFCInternalComponent : NSObject {
    @private
    WFCControl *component;
    NSInteger attribute;
}

@property (readwrite, assign) WFCControl *component;
@property (readwrite) NSInteger attribute;
@end

@implementation WFCInternalComponent
@synthesize component;
@synthesize attribute;
@end

@implementation WFCContainer
- (id)init {
    if( self = [super init]) {
        layouter = NULL;
        components = [NSMutableArray new];
    }
    return self;
}
- (id)initWithLayouter:(WFCLayouter*)l {
    if( self = [self init]) {
        [self setLayouter:l];
    }
    return self;
}
- (void)dealloc {
    [components release];
    [super dealloc];
}

- (WFCLayouter*)layouter {
    return layouter;
}
- (void)setLayouter:(WFCLayouter*)ll {
    layouter = ll;
    [layouter layoutComponents:self];
}

- (void)addComponent:(WFCControl*)component {
    [self addComponent:component attribute:-1];
}
- (void)addComponent:(WFCControl*)component attribute:(NSInteger)addition {
    WFCInternalComponent *ic = [WFCInternalComponent new];
    [ic setComponent:component];
    [ic setAttribute:addition];

    [component setRoot:[self root]];
    [component setParent:self];

    [components addObject:ic];
    [ic release];

    // XXX: Always re-layout as long as a new component is inserted?
    //NSLog( @"%d", self);
    [layouter layoutComponents:self];
}

- (void)removeComponent:(WFCControl*)component {
    __block id target = NULL;
    [components enumerateObjectsUsingBlock:^( id _Nonnull o, NSUInteger i, BOOL * _Nonnull e) {
        if( [o component] == component) {
            *e = YES;
            target = o;
        }
    }];

    if( target == NULL) return;
    [components removeObject:target];
}
- (WFCControl*)componentForIndex:(NSUInteger)index {
    WFCInternalComponent *ic = [components objectAtIndex:index];
    if( ic == NULL) return NULL;
    return [ic component];
}
- (NSInteger)componentAttributeForIndex:(NSUInteger)index {
    WFCInternalComponent *ic = [components objectAtIndex:index];
    if( ic == NULL) return -1;
    return [ic attribute];
}
- (NSUInteger)componentCount {
    return [components count];
}

- (WFCControl*)mouseHit:(struct WFCPoint)point {
    __block WFCControl *target = nil;
    [components enumerateObjectsUsingBlock:^( id _Nonnull obj, NSUInteger i, BOOL * _Nonnull ret) {
        WFCControl *component_ = [obj component];
        if( [component_ hitTest:point]) {
            target = component_;
            *ret = YES;
        }
    }];
    return target;
}

- (void)layout {
    [layouter layoutComponents:self];
}
- (void)draw:(WFCDrawContext*)ctx {
    WFCDrawContext *c2 = [ctx copy];
    //FIXME:[c2 addOffset:WFCPoint( [self bounds].origin.x, [self bounds].origin.y)];
    NSUInteger c = [self componentCount];
    for( int i=0;i<c;++i) {
        [[self componentForIndex:i] draw:c2];
    }
    [c2 release];
}
@end

@implementation WFCLayouter
- (void)layoutComponents:(WFCContainer*)container {

}
@end

@implementation WFCFlowLayouter
@synthesize rcap;
@synthesize ccap;

- (id)init {
    if( self = [self initWithRowCap:1 columnCap:1]) {

    }
    return self;
}
- (id)initWithRowCap:(int)rcap_ columnCap:(int)ccap_{
    if( self = [super init]) {
        rcap = rcap_;
        ccap = ccap_;
    }
    return self;
}
- (void)layoutComponents:(WFCContainer*)container {
    struct WFCPoint np;
    np.x = rcap;np.y = ccap;
    int lmh = 0;
    const NSUInteger c = [container componentCount];
    for( int i=0;i<c;++i) {
        WFCControl *component = [container componentForIndex:i];
        struct WFCSize pSize = [component preferredSize];

        //NSLog( @"%.2f %.2f", np.x + pSize.w + rcap, [container bounds].w);
        if( np.x + pSize.w + rcap > [container bounds].size.w) {
            np.x = rcap;
            np.y += lmh + ccap;
        }
        [component setBounds:WFCRect( np.x, np.y, pSize.w, pSize.h)];
        np.x += pSize.w + rcap;

        if( pSize.h > lmh) lmh = pSize.h;
    }
}
@end

@implementation WFCGridLayouter
@synthesize rows;
@synthesize columns;
@synthesize rcap;
@synthesize ccap;

- (id)initWithRows:(int)rows_ columns:(int)columns_ rowCap:(int)rcap_ columnCap:(int)ccap_ {
    if( self = [self init]) {
        rcap = rcap_;
        ccap = ccap_;
        rows = rows_;
        columns = columns_;
    }
    return self;
}

- (void)layoutComponents:(WFCContainer*)container {
    const NSUInteger c = [container componentCount];
    const struct WFCRect siz = [container bounds];
    int cw = (siz.size.w - ccap - columns * ccap) / columns, ch = (siz.size.h - rcap - rows * rcap) / rows;
    int cc = 0, rc = 0;
    for( int i=0;i<c;++i) {
        if( cc >= columns) {
            rc += 1;
            cc = 0;
        }
        WFCControl *component = [container componentForIndex:i];
        [component setBounds:WFCRect( (cc + 1) * ccap + cc * cw, (rc + 1) * rcap + rc * ch, cw, ch )];
        ++cc;
    }
}
@end
