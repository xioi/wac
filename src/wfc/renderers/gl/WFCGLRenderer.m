#import "WFCGLRenderer.h"
#import <PKLoader.h>
#import <glad/glad.h>
#import <SDL.h>
#import <malloc/malloc.h>

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
        "uniform bool uEnableTexture;\n"

        "void main() {\n"
        "   if( uEnableTexture) {\n"
        "       outFragColor = fs_in.color * texture( uTexture, fs_in.texCoord);\n"
        "   }else {\n"
        "       outFragColor = fs_in.color;\n"
        "   }\n"
        "}\n";

unsigned int compileProgram( const char *vssrc, const char *fssrc) {
    unsigned int
        vs = glCreateShader( GL_VERTEX_SHADER),
        fs = glCreateShader( GL_FRAGMENT_SHADER);
    
    glShaderSource( vs, 1, &vssrc, NULL);
    glShaderSource( fs, 1, &fssrc, NULL);
    glCompileShader( vs);
    glCompileShader( fs);
    unsigned int p = glCreateProgram();
    glAttachShader( p, vs);
    glAttachShader( p, fs);
    glLinkProgram( p);

    glDeleteShader( vs);
    glDeleteShader( fs);
    return p;
}

struct WFCGLTextureData {
    unsigned int id;
};

struct WFCGLFontData {

};

@implementation WFCGLRenderer
+ (void)initialize {
    SDL_Init( SDL_INIT_EVERYTHING);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, WFC_OPENGL_VERSION_MAJOR);
    SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, WFC_OPENGL_VERSION_MINOR);
}
+ (void)cleanup {
    SDL_Quit();
}

- (id)init {
    if( self = [super init]) {
        vertexNum = 0;
        glGenVertexArrays( 1, &vao);
        glGenBuffers( 1, &vbo);
        [self setResolution:WFCSSize( 800, 600)];
        standardProgram = compileProgram( gStandardVsSrc, gStandardFsSrc);
    }
    return self;
}
- (void)dealloc {
    glDeleteProgram( standardProgram);
    glDeleteVertexArrays( 1, &vao);
    glDeleteBuffers( 1, &vbo);
    [super dealloc];
}

- (void)renderBegin {
    glEnable( GL_BLEND);
    glDisable( GL_DEPTH_TEST);
    glPixelStorei( GL_UNPACK_ALIGNMENT, 1);
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // FIXME:delete debug code below
    glClearColor( 0, 1, 0, 1);
    glClear( GL_COLOR_BUFFER_BIT);
}
- (void)renderEnd {
    [self flush];
}
- (BOOL)loadTexture:(WFCTexture*)txt {
    NSString *path = txt->name;
    int width, height, channels;
    const char *data = PKLoadImageFile( path, &width, &height, &channels);
    struct WFCGLTextureData *tex_data;
    unsigned int t;
    if( !txt->complete) {
        glGenTextures( 1, &t);
        tex_data = malloc( sizeof( struct WFCGLTextureData));
    }else {
        t = ((struct WFCGLTextureData*)txt->data)->id;
        tex_data = (struct WFCGLTextureData*)txt->data;
    }
    glBindTexture( GL_TEXTURE_2D, t);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA16F, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glGenerateMipmap( GL_TEXTURE_2D);
    glBindTexture( GL_TEXTURE_2D, 0);
    PKFreeImageFile( data);
    tex_data->id = t;

    txt->width = width;
    txt->height = height;
    txt->data = tex_data;
    txt->complete = YES;
    return YES;
}
- (void)releaseTexture:(WFCTexture *)txt {
    if( txt->data != NULL) {
        glDeleteTextures( 1, &((struct WFCGLTextureData*)txt->data)->id);

        free( txt->data);
        txt->data = NULL;
        txt->complete = NO;
    }
}
- (BOOL)loadFont:(WFCFont*)font {
    
    return YES;
}
- (void)addVert:(struct vec3)position uv:(struct vec2)uv {
    vertexs[vertexNum].x = position.x;
    vertexs[vertexNum].y = position.y;
    vertexs[vertexNum].z = position.z;

    vertexs[vertexNum].u = uv.x;
    vertexs[vertexNum].v = uv.y;

    vertexs[vertexNum].r = drawColor.r;
    vertexs[vertexNum].g = drawColor.g;
    vertexs[vertexNum].b = drawColor.b;
    vertexs[vertexNum].a = drawColor.a;

    ++vertexNum;
}
- (void)flush {
    if( vertexNum == 0) return;

    glUseProgram( standardProgram);
    glUniformMatrix4fv( glGetUniformLocation( standardProgram, "uProjection"), 1, GL_TRUE, (float*)&projectionMatrix);

    if( textureEnabling) {
        glActiveTexture( GL_TEXTURE0);
        glBindTexture( GL_TEXTURE_2D, ((struct WFCGLTextureData*)lastTexture->data)->id);
        glUniform1i( glGetUniformLocation( standardProgram, "uEnableTexture"), 1);
    }else {
        glUniform1i( glGetUniformLocation( standardProgram, "uEnableTexture"), 0);
    }

    glBindVertexArray( vao);
    glBindBuffer( GL_ARRAY_BUFFER, vbo);
    glEnableVertexAttribArray( 0);
    glEnableVertexAttribArray( 1);
    glEnableVertexAttribArray( 2);
    glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, sizeof( WFCGLVertex), (void*)0);
    glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, sizeof( WFCGLVertex), (void*)(3*sizeof( float)));
    glVertexAttribPointer( 2, 4, GL_FLOAT, GL_FALSE, sizeof( WFCGLVertex), (void*)(5*sizeof( float)));
    
    glBufferData( GL_ARRAY_BUFFER, sizeof( WFCGLVertex) * vertexNum, vertexs, GL_STREAM_DRAW);
    glDrawArrays( GL_TRIANGLES, 0, vertexNum);
    glBindVertexArray( 0);

    vertexNum = 0;
}
- (void)drawText:(NSString*)text at:(struct vec2)pos font:(id)font {

}
- (struct vec2)measureText:(NSString*)text font:(id)font {
    // TODO:
    return svec2( 0, 0);
}
- (void)setResolution:(WFCSize)resolution_ {
    [super setResolution:resolution_];
    [self updateProjectionMatrix];
}
- (void)updateProjectionMatrix {
    //struct mat4 mat;
    mat4_ortho( (mfloat_t*)&projectionMatrix, 0, resolution.w, resolution.h, 0, -10, 10);
}
- (void)setViewport:(WFCRect)viewport {
    viewport.origin.y = resolution.h - viewport.origin.y;
    glViewport( (int)viewport.origin.x, (int)viewport.origin.y, (int)viewport.size.w, (int)viewport.size.h);
}
@end
