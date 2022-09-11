#import "WFCWindow.h"
#import "WFCRender.h"

#import <ft2build.h>
#import FT_FREETYPE_H
#import <hb.h>
#import <hb-ft.h>
#import <../glad/glad.h>
#import <mathc.h>

WFCTexture *txt;
float t = 0;

@implementation WFCComponent
- (WFCFSize)preferredSize {
    return WFCNewFSize( 1, 1);
}

- (void)setLocation:(WFCFPoint)location {
    [self setBounds:WFCNewFRect( location.x, location.y, bounds.w, bounds.h)];
}

- (void)setSize:(WFCFSize)size {
    [self setBounds:WFCNewFRect( bounds.x, bounds.y, size.w, size.h)];
}

- (void)setBounds:(WFCFRect)bounds_ {
    bounds = bounds_;
}

- (WFCFRect)bounds {
    return bounds;
}

- (void)draw:(WFCDrawContext*)ctx {
    [ctx drawFilledRect:bounds color:WFCNewColor( 0.7, 0, 0.7, 1)];
}
@end

@interface WFCInternalComponent : NSObject {
    @private
    WFCComponent *component;
    NSInteger attribute;
}

@property (readwrite, assign) WFCComponent *component;
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

- (void)addComponent:(WFCComponent*)component {
    [self addComponent:component attribute:-1];
}
- (void)addComponent:(WFCComponent*)component attribute:(NSInteger)addition {
    WFCInternalComponent *ic = [WFCInternalComponent new];
    [ic setComponent:component];
    [ic setAttribute:addition];
    [components addObject:ic];
    [ic release];

    // XXX: Always re-layout as long as a new component is inserted?
    [layouter layoutComponents:self];
}

- (void)removeComponent:(WFCComponent*)component {
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
- (WFCComponent*)componentForIndex:(NSUInteger)index {
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
- (void)draw:(WFCDrawContext*)ctx {
    WFCDrawContext *c2 = [ctx clone];
    [c2 addOffset:WFCNewFPoint( [self bounds].x, [self bounds].y)];
    NSUInteger c = [self componentCount];
    for( uint i=0;i<c;++i) {
        [[self componentForIndex:c] draw:c2];
    }
    [c2 release];
}
@end

// // hb test
// hb_buffer_t *buf;
// hb_blob_t *blob;
// hb_face_t *face;
// hb_font_t *font;

// FT_Library ft_library;
// FT_Face ft_face;

// uint glyph_txts[256];
// struct {
//     int width;
//     int height;
//     int by;
//     int xadvance;
// } glyph_infos[256];
// NSMutableDictionary *glyph_index;

extern uint gTextProgram;
// static uint tvao, tbs[2];
// const char text[] =
//     "I can eat glass and it doesn't hurt me.\n"
//     "我能吞下玻璃而不伤身体。\n"
//     "我能吞下玻璃而不傷身體。\n"
//     "私はガラスを食べられます。それは私を傷つけません。\n"
//     "나는 유리를 먹을 수 있어요. 그래도 아프지 않아요\n";       // CJK
//     //"Я могу есть стекло, оно мне не вредит.\n"
//     //"ຂອ້ຍກິນແກ້ວໄດ້ໂດຍທີ່ມັນບໍ່ໄດ້ເຮັດໃຫ້ຂອ້ຍເຈັບ.\n";
//     //"Tôi có thể ăn thủy tinh mà không hại gì.\n";
// NSString *text2;

extern struct mat4 gProjectionMatrix;

@implementation WFCWindow
@synthesize state;
@synthesize width;
@synthesize height;

- (id)init {
    if( self = [super init]) {
        state = WFCFreeWindow;
        container = [WFCSingleViewContainer new];
    }
    return self;
}

- (void)load {
    // glGenVertexArrays( 1, &tvao);
    // glGenBuffers( 2, tbs);
}

+ (instancetype)windowWithTitle:(NSString*)title width:(NSUInteger)w height:(NSUInteger)h flags:(WFCWindowFlags)f {
    return [[WFCWindow alloc] initWithTitle:title width:w height:h flags:f];
}

- (id)initWithTitle:(NSString*)title width:(NSUInteger)w height:(NSUInteger)h flags:(WFCWindowFlags)f {
    Uint32 flags = SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL;

    if( f & WFCResizable) {
        flags |= SDL_WINDOW_RESIZABLE;
    }
    if( f & WFCBorderLess) {
        flags |= SDL_WINDOW_BORDERLESS;
    }

    SDL_Window *wnd = SDL_CreateWindow( [title UTF8String],
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        w, h, flags);
    
    if( self = [self initFrom:wnd]) {
    }else {
        if( wnd != NULL) {
            SDL_DestroyWindow( wnd);
        }
        return NULL;
    }
    return self;
}
- (id)initFrom:(SDL_Window*)window {
    if( self = [self init]) {
        mount = window;
        ctx = [[WFCDrawContext alloc] initFromWindow:self];
        glContext = SDL_GL_CreateContext( window);

        [self didChangeSizeWithPreviousWidth:0 andHeight:0];
    }
    return self;
}
- (void)dealloc {
    // hb_buffer_destroy(buf);
    // hb_font_destroy(font);
    // hb_face_destroy(face);
    // //hb_blob_destroy(blob);
    // FT_Done_Face( ft_face);
    // FT_Done_FreeType( ft_library);

    // glDeleteTextures( 256, glyph_txts);
    // [glyph_index release];

    [ctx release];
    [txt release];
    [super dealloc];
}

- (void)draw {
    WFCRenderBegin();
    WFCClear( 1, 1, 1, 1);
    [ctx setOffset:WFCNewFPoint( 0, 0)];
    [container draw:ctx];
    WFCRenderEnd();
    SDL_GL_SwapWindow( mount);
}
- (BOOL)processEvent:(SDL_Event*)e {
    uint wnd_id = SDL_GetWindowID( mount);

    switch( e->type) {
        case SDL_QUIT:
            return NO;
        case SDL_WINDOWEVENT_SIZE_CHANGED: { // FIXME: 事件无效
            //int w = e->window.data1, h = e->window.data2;
            //WFCOnViewportResized( w, h);
            break;
        }
        case SDL_MOUSEBUTTONDOWN: { // 处理鼠标按下事件
            if( e->button.windowID == wnd_id) {
                // TODO:
                // * 判断焦点
                // * dispatch消息
                //NSLog( @"Mouse Button Down %d in [%d,%d]", e->button.button, e->button.x, e->button.y);
            }
            break;
        }
        case SDL_KEYDOWN: { // 处理键盘按下事件
            if( e->key.windowID == wnd_id) {
                SDL_Keysym sym =  e->key.keysym;
                NSLog( @"Key down of %c Shift?:%d", sym.sym, sym.mod & KMOD_SHIFT);
            }
            break;
        }
    }

    return YES;
}

- (void)didChangeSizeWithPreviousWidth:(int)pw andHeight:(int)ph {
    NSLog( @"%d %d", width, height);
    [container setBounds:WFCNewFRect( 10, 10, width - 20, height - 20)];
}

- (void)updateWindowStatus {
    int previousw = width, previoush = height;
    SDL_GetWindowSize( mount, &width, &height);

    if( previousw != width || previoush != height) {
        [self didChangeSizeWithPreviousWidth:previousw andHeight:previoush];
    }
}

- (void)makeCurrentGLWindow {
    SDL_GL_MakeCurrent( mount, glContext);
}
@end

@implementation WFCSingleViewContainer
- (id)initWithParent:(WFCContainer*)parent_ {
    if( self = [self init]) {
        parent = parent_;
    }
    return self;
}
- (void)draw:(WFCDrawContext*)ctx {
    // WFCDrawContext *c2 = [ctx clone];
    // [c2 addOffset:WFCNewFPoint( [self bounds].x, [self bounds].y)];
    // [c2 drawFilledRect:];
    // [c2 release];
    [ctx drawFilledRect:[self bounds] color:WFCNewColor( 1, 0.1, 0.1, 1)];
    [super draw:ctx];
}
@end

@implementation WFCDrawContext
@synthesize area;

- (id)initFromWindow:(WFCWindow*)wnd {
    if( self = [self init]) {
        self->target = wnd;
    }
    return self;
}
- (id)initFromContext:(WFCDrawContext*)ctx {
    if( self = [self init]) {
        self->target = ctx->target;
        self->area = ctx->area;
    }
    return self;
}
- (instancetype)clone {
    return [[WFCDrawContext alloc] initFromContext:self];
}

- (void)setOffset:(WFCFPoint)offset_2 {
    WFCSetOffset( offset_2);
    offset_ = offset_2;
}
- (void)addOffset:(WFCFPoint)addition {
    offset_.x += addition.x;
    offset_.y += addition.y;
    [self setOffset:offset_];
}
- (WFCFPoint)offset {
    return offset_;
}

- (void)drawFilledRect:(WFCFRect)rect color:(WFCColor)col {
    WFCDrawRect( rect, col);
}
- (void)drawImage:(WFCTexture*)txt at:(WFCFPoint)pos {
    // TODO:add a more general method

}
@end
