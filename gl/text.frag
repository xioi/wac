#version 330 core

out vec4 outFragColor;

in VS_OUT {
    vec2 texCoord;
} fs_in;

uniform sampler2D uTextTexture;
uniform vec4 uBlendColor = vec4( 1);

void main() {
    outFragColor = uBlendColor * texture( uTextTexture, fs_in.texCoord);
}
