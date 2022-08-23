#import "WACRender.h"
#import "../glad/glad.h"
#import <plutosvg.h>
#import <PKLoader.h>
#import <mathc.h>

#define WAC_MAX_DRAWCALLS 4096
#define WAC_MAX_VERTEXS 4096 * 4

uint gNormalProgram;
const char
    *gNormalVsSrc =
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
    *gNormalFsSrc =
        "#version 330 core\n"

        "out vec4 outFragColor;\n"

        "in VS_OUT {\n"
        "    vec2 texCoord;\n"
        "    vec4 color;\n"
        "} fs_in;\n"

        "uniform sampler2D uTexture;\n"

        "void main() {\n"
        "    outFragColor = fs_in.color;// * texture( uTexture, fs_in.texCoord);\n"
        "}\n";

uint gVao, gRectVbo, gRectIbo;
WACTexture *gWhite;

void WACRenderSetup() {
    uint
        vs = glCreateShader( GL_VERTEX_SHADER),
        fs = glCreateShader( GL_FRAGMENT_SHADER);
    
    glShaderSource( vs, 1, &gNormalVsSrc, NULL);
    glShaderSource( fs, 1, &gNormalFsSrc, NULL);
    glCompileShader( vs);
    glCompileShader( fs);
    uint p = glCreateProgram();
    glAttachShader( p, vs);
    glAttachShader( p, fs);
    glLinkProgram( p);

    glDeleteShader( vs);
    glDeleteShader( fs);
    gNormalProgram = p;

    glGenVertexArrays( 1, &gVao);
    glGenBuffers( 1, &gRectVbo);
    glGenBuffers( 1, &gRectIbo);

    const char white_txt[] = { 255, 255, 255, 255};
    gWhite = [[WACTexture alloc] initFromRGBAImage:white_txt width:1 htight:1];
}
void WACRenderCleanup() {
    [gWhite release];
    glDeleteProgram( gNormalProgram);
    glDeleteVertexArrays( 1, &gVao);
    glDeleteBuffers( 1, &gRectVbo);
    glDeleteBuffers( 1, &gRectIbo);
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

WACFRect transformFRectViaOffset( WACFRect);

typedef struct WACVertex {
    float pos[3];
    float coord[2];
    float color[4];
} WACVertex;

WACVertex gVertexs[WAC_MAX_VERTEXS];
int gIndexs[WAC_MAX_VERTEXS];
uint gVertexCounter = 0, gIndexCounter = 0;

void WACRenderBegin() {
}
void WACRenderEnd() { // = WACFrame
}
WACFPoint gOffset;
void WACSetOffset( WACFPoint offset) {
    gOffset = offset;
}

void addVertex( uint index, float x, float y, float z, float u, float v, WACColor color) {
    // WARNING: gVertexCounter不会自增，为了使addTriangle更加易用
    // addTriangle后需要手动增加gVertexCounter
    WACVertex *vv = &gVertexs[index + gVertexCounter + 1];
    vv->pos[0] = x;vv->pos[1] = y;vv->pos[2] = z;
    vv->coord[0] = u;vv->coord[1] = v;
    vv->color[0] = color.r,vv->color[1] = color.g;vv->color[2] = color.b;vv->color[3] = color.a;
}
void addTriangle( uint index1, uint index2, uint index3) {
    uint off = gVertexCounter + 1;
    uint first = off + index1, second = off + index2, third = off + index3;
    gIndexs[gIndexCounter++] = first;
    gIndexs[gIndexCounter++] = second;
    gIndexs[gIndexCounter++] = third;
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

void configureNormalProgram() {
    glEnableVertexAttribArray( 0);
    glEnableVertexAttribArray( 1);
    glEnableVertexAttribArray( 2);

    glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, sizeof( WACVertex), (void*)0);
    glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, sizeof( WACVertex), (void*)(3*sizeof( float)));
    glVertexAttribPointer( 2, 4, GL_FLOAT, GL_FALSE, sizeof( WACVertex), (void*)(5*sizeof( float)));
}

void WACClear( float r, float g, float b, float a) {
    glClearColor( r, g, b, a);
    glClear( GL_COLOR_BUFFER_BIT);
}
void WACDrawRect( WACFRect rect, WACColor color) {
    glUseProgram( gNormalProgram);
    glBindVertexArray( gVao);
    glBindBuffer( GL_ARRAY_BUFFER, gRectVbo);
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, gRectIbo);

    WACFRect r2 = transformFRectViaOffset( rect);
    WACFPoint p1, p2, p3, p4;
    p1.x = r2.x;p1.y = r2.y;
    p2.x = r2.x + r2.w;p2.y = r2.y;
    p3.x = r2.x;p3.y = r2.y + r2.h;
    p4.x = p2.x;p4.y = p3.y;

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

    configureNormalProgram();
    glBufferData( GL_ARRAY_BUFFER, sizeof( dat1), dat1, GL_STREAM_DRAW);
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof( dat1_indexs), dat1_indexs, GL_STREAM_DRAW);

    float matProjection[] = {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    };
    glUniformMatrix4fv( glGetUniformLocation( gNormalProgram, "uProjection"), 1, GL_TRUE, (float*)&gProjectionMatrix);
    glDrawElements( GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

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
        // FIXME:使用其他加载文件的方法
        /*
        FILE *fp = fopen( [path UTF8String], "rb");
        fseek( fp, 0, SEEK_END);
        unsigned long len = ftell( fp);
        fseek( fp, 0, SEEK_SET);
        char *data = malloc( len);
        fread( data, len, 1, fp);
        fclose( fp);
        */
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];

        // TODO:使用stbi加载
    }
    return self;
}
- (id)initFromSvg:(char*)data width:(NSUInteger)width_ height:(NSUInteger)height_ {
    if( self = [self init]) {

    }
    return self;
}
- (id)initFromRGBAImage:(const char*)data width:(NSUInteger)width_ htight:(NSUInteger)height_ {
    if( self = [self init]) {
        glBindTexture( GL_TEXTURE_2D, handle);
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA16F, width_, height_, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
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

}
@end
