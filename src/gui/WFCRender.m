#import "WFCRender.h"
#import "../glad/glad.h"
#import <plutosvg.h>
#import <PKLoader.h>
#import <PKFont.h>
#import <mathc.h>

uint gStandardProgram, gTextProgram;
const char
    *gStandardVsSrc =
        "#version 330 core\n"
        "layout (location = 0) in vec3 inPos;\n"
        "layout (location = 1) in vec2 inCoord;\n"
        "layout (location = 2) in vec4 inColor;\n"
        "uniform mat4 uProjection;\n"

        "out VS_OUT {\n"
        "    vec2 texCoord;\n"
        "    vec4 color;\n"
        "} vs_out;\n"

        "void main() {\n"
        "    gl_Position = vec4( inPos, 1.0f) * uProjection;\n"
        "    vs_out.texCoord = inCoord;\n"
        "    vs_out.color = inColor;\n"
        "}\n",
    *gStandardFsSrc =
        "#version 330 core\n"

        "out vec4 outFragColor;\n"

        "in VS_OUT {\n"
        "    vec2 texCoord;\n"
        "    vec4 color;\n"
        "} fs_in;\n"

        "uniform sampler2D uTexture;\n"

        "void main() {\n"
        "    outFragColor = fs_in.color * texture( uTexture, fs_in.texCoord);\n"
        "}\n",
    *gTextVsSrc =
        "#version 330 core\n"

        "layout (location = 0) in vec3 inPos;\n"
        "layout (location = 1) in vec2 inCoord;\n"

        "uniform mat4 uProjection;\n"

        "out VS_OUT {\n"
        "    vec2 texCoord;\n"
        "} vs_out;\n"

        "void main() {\n"
        "    gl_Position = vec4( inPos, 1.0f) * uProjection;\n"
        "    vs_out.texCoord = inCoord;\n"
        "}\n",
    *gTextFsSrc =
        "#version 330 core\n"

        "out vec4 outFragColor;\n"

        "in VS_OUT {\n"
        "    vec2 texCoord;\n"
        "} fs_in;\n"

        "uniform sampler2D uTextTexture;\n"
        "uniform vec4 uBlendColor = vec4( 1);\n"

        "void main() {\n"
        "    vec4 textColor = uBlendColor;\n"
        "    textColor.a = texture( uTextTexture, fs_in.texCoord).r;\n"
            
        "    outFragColor = uBlendColor * textColor;\n"
        "}\n";


uint gVao, gRectVbo, gRectIbo, gGeneralVbo, gGeneralIbo;
WFCTexture *gWhite, *gMissing;

uint gSpriteVao, gSpriteVbo, gSpriteIbo;

typedef struct WFCVertex {
    float pos[3];
    float coord[2];
    float color[4];
} WFCVertex;

void configureStandardProgram() {
    glEnableVertexAttribArray( 0);
    glEnableVertexAttribArray( 1);
    glEnableVertexAttribArray( 2);

    glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, sizeof( WFCVertex), (void*)0);
    glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, sizeof( WFCVertex), (void*)(3*sizeof( float)));
    glVertexAttribPointer( 2, 4, GL_FLOAT, GL_FALSE, sizeof( WFCVertex), (void*)(5*sizeof( float)));
}

uint compileProgram( const char *vssrc, const char *fssrc) {
    uint
        vs = glCreateShader( GL_VERTEX_SHADER),
        fs = glCreateShader( GL_FRAGMENT_SHADER);
    
    glShaderSource( vs, 1, &vssrc, NULL);
    glShaderSource( fs, 1, &fssrc, NULL);
    glCompileShader( vs);
    glCompileShader( fs);
    uint p = glCreateProgram();
    glAttachShader( p, vs);
    glAttachShader( p, fs);
    glLinkProgram( p);

    glDeleteShader( vs);
    glDeleteShader( fs);
    return p;
}

void WFCRenderSetup() {
    gStandardProgram = compileProgram( gStandardVsSrc, gStandardFsSrc);
    gTextProgram = compileProgram( gTextVsSrc, gTextFsSrc);

    glGenVertexArrays( 1, &gVao);
    glGenVertexArrays( 1, &gSpriteVao);

    glGenBuffers( 1, &gRectVbo);
    glGenBuffers( 1, &gRectIbo);

    glGenBuffers( 1, &gGeneralVbo);
    glGenBuffers( 1, &gGeneralIbo);
   
    glGenBuffers( 1, &gSpriteVbo);
    glGenBuffers( 1, &gSpriteIbo);

    const char
        white_txt[] = { 255, 255, 255, 255},
        missing_txt[] = {
            188, 0, 188, 255,
        };  // pure purple
    gWhite = [[WFCTexture alloc] initFromRGBAImage:white_txt width:1 height:1];
    gMissing = [[WFCTexture alloc] initFromRGBAImage:missing_txt width:1 height:1];

    float spriteData[] = {
        0, 0, 0, 0, 1, 1, 1, 1, 1, // higher left
        1, 0, 0, 1, 1, 1, 1, 1, 1, // higher right
        0, 1, 0, 0, 0, 1, 1, 1, 1, // lower left
        1, 1, 0, 1, 0, 1, 1, 1, 1  // lower right
    };

    int spriteDataIndexs[] = {
        0, 1, 2,
        1, 2, 3
    };

    glBindVertexArray( gSpriteVao);
    glBindBuffer( GL_ARRAY_BUFFER, gSpriteVbo);
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, gSpriteIbo);

    configureStandardProgram();
    glBufferData( GL_ARRAY_BUFFER, sizeof( spriteData), spriteData, GL_STATIC_DRAW);
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof( spriteDataIndexs), spriteDataIndexs, GL_STATIC_DRAW);

    glBindBuffer( GL_ARRAY_BUFFER, 0);
    glBindVertexArray( 0);
}
void WFCRenderCleanup() {
    [gWhite release];
    [gMissing release];
    glDeleteProgram( gStandardProgram);
    glDeleteVertexArrays( 1, &gVao);
    glDeleteVertexArrays( 1, &gSpriteVao);

    glDeleteBuffers( 1, &gRectVbo);
    glDeleteBuffers( 1, &gRectIbo);

    glDeleteBuffers( 1, &gGeneralVbo);
    glDeleteBuffers( 1, &gGeneralIbo);

    glDeleteBuffers( 1, &gSpriteVbo);
    glDeleteBuffers( 1, &gSpriteIbo);
}

WFCFRect WFCNewFRect( float x, float y, float w, float h) {
    WFCFRect r;
    r.x = x;r.y = y; r.w = w;r.h = h;
    return r;
}
WFCColor WFCNewColor( float r, float g, float b, float a) {
    WFCColor c;
    c.r = r;c.g = g;c.b = b;c.a = a;
    return c;
}
WFCFPoint WFCNewFPoint( float x, float y) {
    WFCFPoint p;
    p.x = x; p.y = y;
    return p;
}
WFCFSize WFCNewFSize( float w, float h) {
    WFCFSize s;
    s.w = w; s.h = h;
    return s;
}

WFCFRect transformFRectViaOffset( WFCFRect);

void WFCRenderBegin() {
}
void WFCRenderEnd() { // = WFCFrame
}
WFCFPoint gOffset;
void WFCSetOffset( WFCFPoint offset) {
    gOffset = offset;
}

WFCFSize gResolution;
struct mat4 gViewportOrthoMatrix, gProjectionMatrix;
void WFCOnViewportResized( int w, int h) {
    gResolution.w = w;
    gResolution.h = h;

    glViewport( 0, 0, w, h); // update gl viewport
    mat4_ortho( (mfloat_t*)&gViewportOrthoMatrix, 0, w, h, 0, -10.0f, 10.0f);
    gProjectionMatrix = gViewportOrthoMatrix; // update projection matrix
}

void WFCDrawArrays( float *vertexs, int from, int count, struct mat4 *projection);
void WFCDrawElements( float *vertexs, int *indexs, int index_count, int vertex_count, struct mat4 *projection, WFCTexture *texture);

struct mat4 smat4_translate_direct( struct vec3 offset) {
    struct mat4 o;
    mat4_zero( (mfloat_t*)&o);
    o.m11 = o.m22 = o.m33 = o.m44 = 1;
    return smat4_translate( o, offset);
}

void WFCClear( float r, float g, float b, float a) {
    glClearColor( r, g, b, a);
    glClear( GL_COLOR_BUFFER_BIT);
}
void WFCDrawRect( WFCFRect rect, WFCColor color) {
    WFCFPoint p1, p2, p3, p4;
    p1.x = rect.x;p1.y = rect.y;
    p2.x = rect.x + rect.w;p2.y = rect.y;
    p3.x = rect.x;p3.y = rect.y + rect.h;
    p4.x = p2.x;p4.y = p3.y;

    struct mat4 offsetMatrix = smat4_translate_direct( svec3( gOffset.x, gOffset.y, 0)), b;
    mat4_multiply( (mfloat_t*)&b, (mfloat_t*)&gProjectionMatrix, (mfloat_t*)&offsetMatrix);

    float dat1[] = {
        p1.x, p1.y, 0, 0, 0, color.r, color.g, color.b, color.a,
        p2.x, p2.y, 0, 0, 0, color.r, color.g, color.b, color.a,
        p3.x, p3.y, 0, 0, 0, color.r, color.g, color.b, color.a,
        p4.x, p4.y, 0, 0, 0, color.r, color.g, color.b, color.a
    };

    int dat1_indexs[] = {
        0, 1, 2,
        3, 2, 1
    };

    WFCDrawElements( dat1, dat1_indexs, 6, 4, &b, gWhite);
}

void WFCDrawArrays( float *vertexs, int from, int count, struct mat4 *projection) {
    glUseProgram( gStandardProgram);
    glBindVertexArray( gVao);
    glBindBuffer( GL_ARRAY_BUFFER, gGeneralVbo);

    configureStandardProgram();
    glBufferData( GL_ARRAY_BUFFER, sizeof( WFCVertex) * count, vertexs, GL_STREAM_DRAW);

    glUniformMatrix4fv( glGetUniformLocation( gStandardProgram, "uProjection"), 1, GL_TRUE, (float*)projection);
    glDrawArrays( GL_TRIANGLES, from, count);

    glBindBuffer( GL_ARRAY_BUFFER, 0);
    glBindVertexArray( 0);
}

void WFCDrawElements( float *vertexs, int *indexs, int index_count, int vertex_count, struct mat4 *projection, WFCTexture *texture) {
    glUseProgram( gStandardProgram);
    glBindVertexArray( gVao);
    glBindBuffer( GL_ARRAY_BUFFER, gGeneralVbo);
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, gGeneralIbo);

    configureStandardProgram();
    glBufferData( GL_ARRAY_BUFFER, sizeof( WFCVertex) * vertex_count, vertexs, GL_STREAM_DRAW);
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof( int) * index_count, indexs, GL_STREAM_DRAW);

    glActiveTexture( GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D, [texture handle]);

    glUniformMatrix4fv( glGetUniformLocation( gStandardProgram, "uProjection"), 1, GL_TRUE, (float*)projection);
    glDrawElements( GL_TRIANGLES, index_count, GL_UNSIGNED_INT, 0);

    glBindBuffer( GL_ARRAY_BUFFER, 0);
    glBindVertexArray( 0);
}

WFCFRect transformFRectViaOffset( WFCFRect r) {
    WFCFRect rrr = r;
    rrr.x += gOffset.x;
    rrr.y += gOffset.y;
    return rrr;
}

NSMutableDictionary *gCachedImageDictionary;

@implementation WFCTexture
@synthesize handle;
@synthesize width;
@synthesize height;

+ (instancetype)imageForPath:(NSString*)path {
    //if( gCachedImageDictionary == NULL) {
    //    gCachedImageDictionary = [[NSMutableDictionary alloc] init];
    //}

    WFCTexture *txt;
    //txt = [gCachedImageDictionary valueForKey:path];
    //if( txt != NULL) {
    //    return txt;
    //}
    txt = [[WFCTexture alloc] initFromFile:path];
    //[gCachedImageDictionary setValue:txt forKey:path];
    return txt;
}
- (id)init {
    if( self = [super init]) {
        glGenTextures( 1, &handle);
        complete = NO;
    }
    return self;
}
- (id)initFromFile:(NSString*)path {
    if( self = [self init]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        if( [data bytes] == NULL) {
            [data release];
            return self; // error
        }
        // DONE:使用PanKu加载
        int w, h, channels;
        const char *d = PKLoadImageFromData( data, &w, &h, &channels);
        self = [self initFromRGBAImage:d width:w height:h];
        PKFreeImageFile( d);
        [data release];
    }
    return self;
}
- (id)initFromSvg:(char*)data width:(NSUInteger)width_ height:(NSUInteger)height_ {
    if( self = [self init]) {
        // TODO:加载svg图像
    }
    return self;
}
- (id)initFromRGBAImage:(const char*)data width:(NSUInteger)width_ height:(NSUInteger)height_ {
    if( self = [self init]) {
        glBindTexture( GL_TEXTURE_2D, handle);
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA16F, width_, height_, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
        glGenerateMipmap( GL_TEXTURE_2D);
        glBindTexture( GL_TEXTURE_2D, 0);

        width = width_;
        height = height_;

        complete = YES;
    }
    return self;
}
- (void)dealloc {
    glDeleteTextures( 1, &handle);
    [super dealloc];
}

- (void)drawAt:(WFCFPoint)pos {
    [self drawAt:pos xscale:1 yscale:1 angle:0];
}
- (void)drawAt:(WFCFPoint)pos xscale:(float)xscale yscale:(float)yscale {
    [self drawAt:pos xscale:xscale yscale:yscale angle:0];
}
- (void)drawAt:(WFCFPoint)pos width:(float)ww height:(float)hh {
    [self drawAt:pos width:ww height:hh angle:0];
}
- (void)drawAt:(WFCFPoint)pos angle:(float)angle {
    [self drawAt:pos xscale:1 yscale:1 angle:angle];
}
- (void)drawAt:(WFCFPoint)pos width:(float)ww height:(float)hh angle:(float)angle {
    int w, h;
    float xs, ys;
    if( !complete) {
        xs = ww;
        ys = hh;
    }else {
        xs = ww / [self width];
        ys = hh / [self height];
    }
    [self drawAt:pos xscale:xs yscale:ys angle:angle];
}
- (void)drawAt:(WFCFPoint)pos xscale:(float)xscale yscale:(float)yscale angle:(float)angle {
    if( !complete) {
        [gMissing drawAt:pos xscale:xscale yscale:yscale angle:angle];
        return;
    }

    glUseProgram( gStandardProgram);
    glBindVertexArray( gSpriteVao);

    glActiveTexture( GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D, [self handle]);

    float xs = [self width] * xscale, ys = [self height] * yscale;

    struct mat4 mat;
    mat4_zero( (mfloat_t*)&mat);
    mat.m11 = mat.m22 = mat.m33 = mat.m44 = 1;
    mat = smat4_scale( mat, svec3( xs, ys, 1));
    mat = smat4_multiply( smat4_rotation_axis( svec3( 0, 0, 1), angle), mat);
    mat = smat4_translate( mat, svec3( pos.x, pos.y, 0));
    mat = smat4_multiply( gProjectionMatrix, mat);

    glUniformMatrix4fv( glGetUniformLocation( gStandardProgram, "uProjection"), 1, GL_TRUE, (float*)&mat);
    glDrawElements( GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

    glBindVertexArray( 0);
}
@end
