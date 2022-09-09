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
- (WFCFSize)perferredSize {
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

// hb test
hb_buffer_t *buf;
hb_blob_t *blob;
hb_face_t *face;
hb_font_t *font;

FT_Library ft_library;
FT_Face ft_face;

uint glyph_txts[256];
struct {
    int width;
    int height;
    int by;
    int xadvance;
} glyph_infos[256];
NSMutableDictionary *glyph_index;

extern uint gTextProgram;
static uint tvao, tbs[2];
const char text[] =
    "I can eat glass and it doesn't hurt me.\n"
    "我能吞下玻璃而不伤身体。\n"
    "我能吞下玻璃而不傷身體。\n"
    "私はガラスを食べられます。それは私を傷つけません。\n"
    "나는 유리를 먹을 수 있어요. 그래도 아프지 않아요\n";       // CJK
    //"Я могу есть стекло, оно мне не вредит.\n"
    //"ຂອ້ຍກິນແກ້ວໄດ້ໂດຍທີ່ມັນບໍ່ໄດ້ເຮັດໃຫ້ຂອ້ຍເຈັບ.\n";
    //"Tôi có thể ăn thủy tinh mà không hại gì.\n";
NSString *text2;

extern struct mat4 gProjectionMatrix;

@implementation WFCWindow
@synthesize state;
@synthesize width;
@synthesize height;

- (id)init {
    if( self = [super init]) {
        state = WFCFreeWindow;
        txt = [WFCTexture imageForPath:@"./tewi.png"];

        assert( !FT_Init_FreeType( &ft_library));

        assert( !FT_New_Face( ft_library, "./Arial Unicode.ttf", 0, &ft_face));
        assert( !FT_Set_Char_Size( ft_face, 0, 32, 0, 0));
        assert( !FT_Set_Pixel_Sizes( ft_face, 0, 1));

        text2 = [NSString stringWithUTF8String:text];
        buf = hb_buffer_create();
        hb_buffer_add_utf8( buf, text, -1, 0, -1);

        hb_buffer_set_direction( buf, HB_DIRECTION_LTR);
        hb_buffer_set_script( buf, HB_SCRIPT_HAN);
        hb_buffer_set_language( buf, hb_language_from_string( "zh", -1));

        face = hb_ft_face_create( ft_face, NULL);
        font = hb_ft_font_create( ft_face, NULL);

        hb_shape( font, buf, NULL, 0);

        assert( !FT_Set_Pixel_Sizes( ft_face, 0, 32));

        glGenTextures( 256, glyph_txts);
        int c = 0;
        glyph_index = [NSMutableDictionary new];
        for( int i=0;i<[text2 length];++i) {
            NSNumber *item = [glyph_index objectForKey:@([text2 characterAtIndex:i])];
            if( item == NULL) {
                item = @(c);
                [glyph_index setObject:item forKey:@([text2 characterAtIndex:i])];

                FT_Load_Char( ft_face, [text2 characterAtIndex:i], FT_LOAD_RENDER);
                const FT_Bitmap *bitmap = &(ft_face->glyph->bitmap);

                glyph_infos[c].width = bitmap->width;
                glyph_infos[c].height = bitmap->rows;
                glyph_infos[c].by = ft_face->glyph->bitmap_top;
                glyph_infos[c].xadvance = ft_face->glyph->advance.x;

                glBindTexture( GL_TEXTURE_2D, glyph_txts[c]);
                glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexImage2D( GL_TEXTURE_2D, 0, GL_RED, bitmap->width, bitmap->rows, 0, GL_RED, GL_UNSIGNED_BYTE, bitmap->buffer);
                glGenerateMipmap( GL_TEXTURE_2D);
                ++c;
            }
        }

        glGenVertexArrays( 1, &tvao);
        glGenBuffers( 2, tbs);
    }
    return self;
}

- (id)initFrom:(SDL_Window*)window {
    if( self = [self init]) {
        mount = window;
        ctx = [[WFCDrawContext alloc] initFromWindow:self];
    }
    return self;
}
- (void)dealloc {
    hb_buffer_destroy(buf);
    hb_font_destroy(font);
    hb_face_destroy(face);
    //hb_blob_destroy(blob);
    FT_Done_Face( ft_face);
    FT_Done_FreeType( ft_library);

    glDeleteTextures( 256, glyph_txts);
    [glyph_index release];

    [ctx release];
    [txt release];
    [super dealloc];
}

- (void)draw {
    WFCRenderBegin();
    WFCClear( 1, 1, 1, 1);
    [container draw:ctx];
    WFCDrawRect( WFCNewFRect( 20, 20, 200, 200), WFCNewColor( 1, 0, 0, 1));
    [txt drawAt:WFCNewFPoint( 240, 20) width:200 height:200 angle:t];
    t += 1.0 * M_PI / 180;

    uint glyph_count;
    hb_glyph_info_t *g_info = hb_buffer_get_glyph_infos( buf, &glyph_count);
    hb_glyph_position_t *g_pos = hb_buffer_get_glyph_positions( buf, &glyph_count);

    hb_position_t sx = 20, sy = 300;
    hb_position_t tx = sx, ty = sy;
    for( uint i=0;i<glyph_count;++i) {
        if( [text2 characterAtIndex:i] == '\n') {
            ty += 32;
            tx = sx;
            continue;
        }

        hb_codepoint_t glphyid = g_info[i].codepoint;
        hb_position_t xoffset = g_pos[i].x_offset;
        hb_position_t yoffset = g_pos[i].y_offset;
        hb_position_t xadvance = g_pos[i].x_advance;
        hb_position_t yadvance = g_pos[i].y_advance;

        //NSLog( @"[%d %d] [%d %d] [%d %d]", tx, ty, xoffset, yoffset, xadvance, yadvance);
        int i2 = [((NSNumber*)[glyph_index objectForKey:@([text2 characterAtIndex:i])]) intValue];
        uint ttt = glyph_txts[i2];

        glUseProgram( gTextProgram);

        glBindVertexArray( tvao);
        glBindBuffer( GL_ARRAY_BUFFER, tbs[0]);
        glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, tbs[1]);
        int tindexs[] = {
            0, 1, 2,
            1, 2, 3
        };

        float ddd[] = {
            tx + xoffset, ty - glyph_infos[i2].by + yoffset, 0, 0, 0,
            tx + glyph_infos[i2].width + xoffset, ty - glyph_infos[i2].by + yoffset, 0, 1, 0,
            tx + xoffset, ty + glyph_infos[i2].height - glyph_infos[i2].by + yoffset, 0, 0, 1,
            tx + glyph_infos[i2].width + xoffset, ty + glyph_infos[i2].height - glyph_infos[i2].by + yoffset, 0, 1, 1
        };
        glEnableVertexAttribArray( 0);
        glEnableVertexAttribArray( 1);
        glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, sizeof( float) * 5, (void*)0);
        glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, sizeof( float) * 5, (void*)(3*sizeof( float)));

        glActiveTexture( GL_TEXTURE0);
        glBindTexture( GL_TEXTURE_2D, ttt);

        glBufferData( GL_ARRAY_BUFFER, sizeof( ddd), ddd, GL_STREAM_DRAW);
        glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof( tindexs), tindexs, GL_STREAM_DRAW);

        glUniformMatrix4fv( glGetUniformLocation( gTextProgram, "uProjection"), 1, GL_TRUE, (float*)&gProjectionMatrix);
        struct vec4 vvv = svec4( 0, 0, 0, 1);
        glUniform4fv( glGetUniformLocation( gTextProgram, "uBlendColor"), 1, (float*)&vvv);
        glDrawElements( GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

        glBindBuffer( GL_ARRAY_BUFFER, 0);
        glBindVertexArray( 0);

        //tx += (glyph_infos[i2].xadvance >> 6);
        tx += xadvance >> 1;
        //ty += yadvance;
    }

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

- (void)updateWindowStatus {
    SDL_GetWindowSize( mount, &width, &height);
}
@end

@implementation WFCView
- (void)draw:(WFCDrawContext*)ctx {
    // default method
}
@end

@implementation WFCSingleViewContainer
- (id)initWithParent:(WFCView*)parent_ {
    if( self = [self init]) {
        parent = parent_;
    }
    return self;
}
- (void)draw:(WFCDrawContext*)ctx {
    //[ctx drawFilledRect:]
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
    }
    return self;
}
- (instancetype)clone {
    return [[WFCDrawContext alloc] initFromContext:self];
}

- (void)setOffset:(WFCFPoint)offset {
    WFCSetOffset( offset);
}
- (void)drawFilledRect:(WFCFRect)rect color:(WFCColor)col {
    WFCDrawRect( rect, col);
}
- (void)drawImage:(WFCTexture*)txt at:(WFCFPoint)pos {
    // TODO:add a more general method

}
@end
