#import "WFCRenderer.h"

@implementation WFCBaseRenderer
@synthesize clip;

+ (void)initialize {}
+ (void)cleanup {}

- (void)renderBegin {

}
- (void)renderEnd {

}
- (void)setDrawColor:(struct WFCColor)color {
    self->drawColor = color;
}
- (void)addVert:(struct vec3)position uv:(struct vec2)uv {

}
- (void)flush {

}
- (void)drawFilledRectAt:(struct vec2)pos size:(struct vec2)size color:(struct WFCColor)color {
    BOOL enabling = [self textureEnabling];
    if( enabling) {
        [self flush];
        [self setTextureEnabling:NO];
    }
    [self setDrawColor:color];

    [self addVert:svec3( pos.x, pos.y, 0.0f) uv:svec2( 0, 1)];
    [self addVert:svec3( pos.x + size.x, pos.y, 0.0f) uv:svec2( 1, 1)];
    [self addVert:svec3( pos.x + size.x, pos.y + size.y, 0.0f) uv:svec2( 1, 0)];

    [self addVert:svec3( pos.x, pos.y, 0.0f) uv:svec2( 0, 1)];
    [self addVert:svec3( pos.x, pos.y + size.y, 0.0f) uv:svec2( 0, 0)];
    [self addVert:svec3( pos.x + size.x, pos.y + size.y, 0.0f) uv:svec2( 1, 0)];
}
- (void)drawTexturedRectAt:(struct vec2)pos size:(struct vec2)size texture:(WFCTexture*)texture {
    BOOL enabling = [self textureEnabling];
    if( !enabling) {
        [self flush];
        [self setTextureEnabling:YES];
    }

    if( lastTexture != texture || !textureUsed) {
        [self flush];
    }
    [self bindTexture:texture];
    
    [self addVert:svec3( pos.x, pos.y, 0.0f) uv:svec2( 0, 1)];
    [self addVert:svec3( pos.x + size.x, pos.y, 0.0f) uv:svec2( 1, 1)];
    [self addVert:svec3( pos.x + size.x, pos.y + size.y, 0.0f) uv:svec2( 1, 0)];

    [self addVert:svec3( pos.x, pos.y, 0.0f) uv:svec2( 0, 1)];
    [self addVert:svec3( pos.x, pos.y + size.y, 0.0f) uv:svec2( 0, 0)];
    [self addVert:svec3( pos.x + size.x, pos.y + size.y, 0.0f) uv:svec2( 1, 0)];

    lastTexture = texture;
    textureUsed = YES;
}
- (void)drawText:(NSString*)text at:(struct vec2)pos font:(WFCFont*)font {
    NSUInteger length = [text length];
    struct vec2 curpos = pos;
    for( NSUInteger i=0;i<length;++i) {
        unichar c = [text characterAtIndex:i];
        float scale = [font size];
        float h = scale, w = scale / 2;

        if( c == 'f' || c == 'i' || c == 'j' || c == 'l' || c == 't') {
            w = scale / 3;
        }else if( c == 'm') {
            w = scale * 0.8;
        }else if( c == ' ') {
            w = scale;
        }else if( c == '\n') {
            curpos.y += [font size];
            curpos.x = pos.x;
            continue;
        }

        if( c != ' ') {
            [self drawFilledRectAt:curpos size:svec2( w, h) color:WFCColor( 0, 0, 0, 1)];
        }
        curpos.x += w + scale / 10;
    }
}
- (struct vec2)measureText:(NSString*)text font:(id)font {
    return svec2( 0, 0);
}

- (BOOL)textureEnabling {
    return self->textureEnabling;
}
// Overwrite it and call it after your code to switch the variable
- (void)setTextureEnabling:(BOOL)enabling {
    self->textureEnabling = enabling;
}
- (void)bindTexture:(WFCTexture*)texture {
    lastTexture = texture;
    textureUsed = YES;
}

- (void)setResolution:(struct WFCSize)resolution_ {
    self->resolution = resolution_;
}
- (void)setViewport:(struct WFCRect)viewport {}
- (BOOL)loadTexture:(WFCTexture*)txt { return NO;}
- (void)releaseTexture:(WFCTexture*)txt {}
- (BOOL)loadFont:(WFCFont*)font { return NO;}
- (void)releaseFont:(WFCFont*)font {}
- (WFCFont*)defaultFont { return NULL;}
- (void)clipBegin {}
- (void)clipEnd {}
@end

@implementation WFCTexture
@synthesize name;
@synthesize width;
@synthesize height;
@synthesize complete;
@synthesize data;
@end

@implementation WFCFont
@synthesize name;
@synthesize size;
@synthesize data;
@end

@implementation WFCPaintContext
@synthesize offset;
@synthesize renderer;

- (id)copyWithZone:(nullable NSZone *)zone {
    WFCPaintContext *ctx = [[[self class] alloc] initWithRenderer:self.renderer];
    ctx.offset = self.offset;
    return ctx;
}

+ (instancetype)paintContextWithRenderer:(WFCBaseRenderer*)renderer_ {
    WFCPaintContext *ctx = [[[self class] alloc] initWithRenderer:renderer_];
    return ctx;
}
- (id)initWithRenderer:(WFCBaseRenderer*)renderer_ {
    if( self = [super init]) {
        renderer = renderer_;
        offset = WFCPoint( 0, 0);
    }
    return self;
}

@end

struct WFCSize WFCSize( float w, float h) {
    struct WFCSize s;
    s.w = w;
    s.h = h;
    return s;
}
struct WFCPoint WFCPoint( float x, float y) {
    struct WFCPoint p;
    p.x = x;p.y = y;
    return p;
}
struct WFCRect WFCRect( float x, float y, float w, float h) {
    struct WFCRect r;
    r.origin = WFCPoint( x, y);
    r.size = WFCSize( w, h);
    return r;
}
struct WFCColor WFCColor( float r, float g, float b, float a) {
    struct WFCColor c;
    c.r = r;c.g = g;c.b = b;c.a = a;
    return c;
}
