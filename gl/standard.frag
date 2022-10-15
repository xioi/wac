#version 330 core

out vec4 outFragColor;

in VS_OUT {
    vec2 texCoord;
    vec4 color;
} fs_in;

uniform sampler2D uTexture;
uniform bool uEnableTexture;

void main() {
    if( uEnableTexture) {
        outFragColor = fs_in.color * texture( uTexture, fs_in.texCoord);
    }else {
        outFragColor = fs_in.color;
    }
}
