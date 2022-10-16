#import "../WFCRenderer.h"
#define WFC_GL_MAX_VERTEXS 2048

typedef struct WFCGLVertex {
    float x, y, z;
    float u, v;
    float r, g, b, a;
} WFCGLVertex;

@interface WFCGLRenderer : WFCBaseRenderer {
    @private
    WFCGLVertex vertexs[WFC_GL_MAX_VERTEXS];
    int vertexNum;
    
    struct mat4 projectionMatrix;
    unsigned int vao, vbo, standardProgram, fontProgram;
}
@end