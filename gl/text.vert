#version 330 core

layout (location = 0) in vec3 inPos;
layout (location = 1) in vec2 inCoord;

uniform mat4 uProjection;

out VS_OUT {
    vec2 texCoord;
} vs_out;

void main() {
    gl_Position = vec4( inPos, 1.0f) * uProjection;
    vs_out.texCoord = inCoord;
}
