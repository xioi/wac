#version 330 core

layout (location = 0) in vec4 inPos;
layout (location = 1) in vec2 inCoord;

uniform mat4 uProjection;
uniform mat4 uTransform;

out VS_OUT {
    vec2 texCoord;
} vs_out;

void main() {
    gl_Position = inPos * uProjection * uTransform;
    vs_out.texCoord = inCoord;
}
