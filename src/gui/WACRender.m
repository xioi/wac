#import "WACRender.h"
#import "../glad/glad.h"
#import <plutosvg.h>
#import <PKLoader.h>
#import <mathc.h>

#define WAC_MAX_DRAWCALLS 4096
#define WAC_MAX_VERTEXS 4096 * 4

uint gStandardProgram;
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
        "}\n";

uint gVao, gRectVbo, gRectIbo, gGeneralVbo, gGeneralIbo;
WACTexture *gWhite;

uint gSpriteVao, gSpriteVbo, gSpriteIbo;

typedef struct WACVertex {
    float pos[3];
    float coord[2];
    float color[4];
} WACVertex;

void configureStandardProgram() {
    glEnableVertexAttribArray( 0);
    glEnableVertexAttribArray( 1);
    glEnableVertexAttribArray( 2);

    glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, sizeof( WACVertex), (void*)0);
    glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, sizeof( WACVertex), (void*)(3*sizeof( float)));
    glVertexAttribPointer( 2, 4, GL_FLOAT, GL_FALSE, sizeof( WACVertex), (void*)(5*sizeof( float)));
}

void WACRenderSetup() {
    uint
        vs = glCreateShader( GL_VERTEX_SHADER),
        fs = glCreateShader( GL_FRAGMENT_SHADER);
    
    glShaderSource( vs, 1, &gStandardVsSrc, NULL);
    glShaderSource( fs, 1, &gStandardFsSrc, NULL);
    glCompileShader( vs);
    glCompileShader( fs);
    uint p = glCreateProgram();
    glAttachShader( p, vs);
    glAttachShader( p, fs);
    glLinkProgram( p);

    glDeleteShader( vs);
    glDeleteShader( fs);
    gStandardProgram = p;

    glGenVertexArrays( 1, &gVao);
    glGenVertexArrays( 1, &gSpriteVao);

    glGenBuffers( 1, &gRectVbo);
    glGenBuffers( 1, &gRectIbo);

    glGenBuffers( 1, &gGeneralVbo);
    glGenBuffers( 1, &gGeneralIbo);
   
    glGenBuffers( 1, &gSpriteVbo);
    glGenBuffers( 1, &gSpriteIbo);

    const char white_txt[] = { 255, 255, 255, 255};
    gWhite = [[WACTexture alloc] initFromRGBAImage:white_txt width:1 height:1];

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
void WACRenderCleanup() {
    [gWhite release];
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

WACFRect WACNewFRect( float x, float y, float w, float h) {
    WACFRect r;
    r.x = x;r.y = y; r.w = w;r.h = h;
    return r;
}
WACColor WACNewColor( float r, float g, float b, float a) {
    WACColor c;
    c.r = r;c.g = g;c.b = b;c.a = a;
    return c;
}
WACFPoint WACNewFPoint( float x, float y) {
    WACFPoint p;
    p.x = x; p.y = y;
    return p;
}

WACFRect transformFRectViaOffset( WACFRect);

void WACRenderBegin() {
}
void WACRenderEnd() { // = WACFrame
}
WACFPoint gOffset;
void WACSetOffset( WACFPoint offset) {
    gOffset = offset;
}

WACFSize gResolution;
struct mat4 gViewportOrthoMatrix, gProjectionMatrix;
void WACOnViewportResized( int w, int h) {
    gResolution.w = w;
    gResolution.h = h;

    glViewport( 0, 0, w, h);
    mat4_ortho( (mfloat_t*)&gViewportOrthoMatrix, 0, w, h, 0, -10.0f, 10.0f);
    gProjectionMatrix = gViewportOrthoMatrix;
}

void WACDrawArrays( float *vertexs, int from, int count, struct mat4 *projection);
void WACDrawElements( float *vertexs, int *indexs, int index_count, int vertex_count, struct mat4 *projection, WACTexture *texture);

struct mat4 smat4_translate_direct( struct vec3 offset) {
    struct mat4 o;
    mat4_zero( (mfloat_t*)&o);
    o.m11 = o.m22 = o.m33 = o.m44 = 1;
    return smat4_translate( o, offset);
}

void WACClear( float r, float g, float b, float a) {
    glClearColor( r, g, b, a);
    glClear( GL_COLOR_BUFFER_BIT);
}
void WACDrawRect( WACFRect rect, WACColor color) {
    WACFPoint p1, p2, p3, p4;
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

    WACDrawElements( dat1, dat1_indexs, 6, 4, &b, gWhite);
}

void WACDrawArrays( float *vertexs, int from, int count, struct mat4 *projection) {
    glUseProgram( gStandardProgram);
    glBindVertexArray( gVao);
    glBindBuffer( GL_ARRAY_BUFFER, gGeneralVbo);

    configureStandardProgram();
    glBufferData( GL_ARRAY_BUFFER, sizeof( WACVertex) * count, vertexs, GL_STREAM_DRAW);

    glUniformMatrix4fv( glGetUniformLocation( gStandardProgram, "uProjection"), 1, GL_TRUE, (float*)projection);
    glDrawArrays( GL_TRIANGLES, from, count);

    glBindBuffer( GL_ARRAY_BUFFER, 0);
    glBindVertexArray( 0);
}

void WACDrawElements( float *vertexs, int *indexs, int index_count, int vertex_count, struct mat4 *projection, WACTexture *texture) {
    glUseProgram( gStandardProgram);
    glBindVertexArray( gVao);
    glBindBuffer( GL_ARRAY_BUFFER, gGeneralVbo);
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, gGeneralIbo);

    configureStandardProgram();
    glBufferData( GL_ARRAY_BUFFER, sizeof( WACVertex) * vertex_count, vertexs, GL_STREAM_DRAW);
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof( int) * index_count, indexs, GL_STREAM_DRAW);

    glActiveTexture( GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D, [texture handle]);

    glUniformMatrix4fv( glGetUniformLocation( gStandardProgram, "uProjection"), 1, GL_TRUE, (float*)projection);
    glDrawElements( GL_TRIANGLES, index_count, GL_UNSIGNED_INT, 0);

    glBindBuffer( GL_ARRAY_BUFFER, 0);
    glBindVertexArray( 0);
}

WACFRect transformFRectViaOffset( WACFRect r) {
    WACFRect rrr = r;
    rrr.x += gOffset.x;
    rrr.y += gOffset.y;
    return rrr;
}

NSMutableDictionary *gCachedImageDictionary;

@implementation WACTexture
@synthesize handle;
@synthesize width;
@synthesize height;

+ (instancetype)imageForPath:(NSString*)path {
    if( gCachedImageDictionary == NULL) {
        gCachedImageDictionary = [[NSMutableDictionary alloc] init];
    }

    WACTexture *txt = [gCachedImageDictionary valueForKey:path];
    if( txt != NULL) {
        return txt;
    }
    txt = [[WACTexture alloc] initFromFile:path];
    [gCachedImageDictionary setValue:txt forKey:path];
    return txt;
}
- (id)init {
    if( self = [super init]) {
        glGenTextures( 1, &handle);
    }
    return self;
}
- (id)initFromFile:(NSString*)path {
    if( self = [self init]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        // DONE:使用PanKu加载
        int w, h, channels;
        const char *d = PKLoadImageFromData( data, &w, &h, &channels);
        self = [self initFromRGBAImage:d width:w height:h];
        PKFreeImageFile( d);
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
    }
    return self;
}
- (void)dealloc {
    glDeleteTextures( 1, &handle);
    [super dealloc];
}

- (void)drawAt:(WACFPoint)pos {
    [self drawAt:pos xscale:1 yscale:1 angle:0];
}
- (void)drawAt:(WACFPoint)pos xscale:(float)xscale yscale:(float)yscale {
    [self drawAt:pos xscale:xscale yscale:yscale angle:0];
}
- (void)drawAt:(WACFPoint)pos angle:(float)angle {
    [self drawAt:pos xscale:1 yscale:1 angle:angle];
}
- (void)drawAt:(WACFPoint)pos xscale:(float)xscale yscale:(float)yscale angle:(float)angle {
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
