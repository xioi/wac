#version 330 core

out vec4 outFragColor;

in VS_OUT {
    vec2 texCoord;
    vec4 color;
} fs_in;

uniform sampler2D uTexture;

void main() {
    outFragColor = fs_in.color * texture( uTexture, fs_in.texCoord);
}
