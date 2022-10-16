#import "WFCRenderer.h"

@implementation WFCBaseRenderer
+ (void)initialize {}
+ (void)cleanup {}

- (void)renderBegin {

}
- (void)renderEnd {

}
- (void)setDrawColor:(WFCColor)color {
    self->drawColor = color;
}
- (void)addVert:(struct vec3)position uv:(struct vec2)uv {

}
- (void)flush {

}
- (void)drawFilledRectAt:(struct vec2)pos size:(struct vec2)size color:(WFCColor)color {
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
        float scale = font->size;
        float h = scale, w = scale / 2;

        if( c == 'f' || c == 'i' || c == 'j' || c == 'l' || c == 't') {
            w = scale / 3;
        }else if( c == 'm') {
            w = scale * 0.8;
        }else if( c == ' ') {
            w = scale;
        }else if( c == '\n') {
            curpos.y += font->size;
            curpos.x = pos.x;
            continue;
        }

        if( c != ' ') {
            [self drawFilledRectAt:curpos size:svec2( w, h) color:WFCSColor( 0, 0, 0, 1)];
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

- (void)setResolution:(WFCSize)resolution_ {
    self->resolution = resolution_;
}
- (void)setViewport:(WFCRect)viewport {}
- (BOOL)loadTexture:(WFCTexture*)txt { return NO;}
- (void)releaseTexture:(WFCTexture*)txt {}
- (BOOL)loadFont:(WFCFont*)font { return NO;}
- (void)releaseFont:(WFCFont*)font {}
@end

@implementation WFCTexture
@end

@implementation WFCFont
@end

WFCSize WFCSSize( float w, float h) {
    WFCSize s;
    s.w = w;
    s.h = h;
    return s;
}
WFCPoint WFCSPoint( float x, float y) {
    WFCPoint p;
    p.x = x;p.y = y;
    return p;
}
WFCRect WFCSRect( float x, float y, float w, float h) {
    WFCRect r;
    r.origin = WFCSPoint( x, y);
    r.size = WFCSSize( w, h);
}
WFCColor WFCSColor( float r, float g, float b, float a) {
    WFCColor c;
    c.r = r;c.g = g;c.b = b;c.a = a;
    return c;
}
