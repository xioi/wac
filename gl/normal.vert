#version 330 core

layout (location = 0) in vec3 inPos;
layout (location = 1) in vec2 inCoord;
layout (location = 2) in vec4 inColor;

uniform mat4 uProjection;

out VS_OUT {
    vec2 texCoord;
    vec4 color;
} vs_out;

void main() {
    gl_Position = vec4( inPos, 1.0f) * uProjection;
    vs_out.texCoord = inCoord;
    vs_out.color = inColor;
}