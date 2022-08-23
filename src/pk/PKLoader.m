#define STB_IMAGE_IMPLEMENTATION
#import "stb_image.h"
#import "PKLoader.h"

const char *PKLoadImageFile( NSString *path, int *width, int *height, int *channels) {
    stbi_set_flip_vertically_on_load( YES);
    char *dat = (char*)stbi_load( [path UTF8String], width, height, channels, 0);
    return dat;
    //NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    //char *d = (char*)PKLoadImageFromData( data, width, height, channels);
    //[data release];
    //return d;
}

const char* PKLoadImageFromMemory( const char *mem, int length, int *width, int *height, int *channels) {
    stbi_set_flip_vertically_on_load( YES);
    char *dat = (char*)stbi_load_from_memory( (unsigned char*)mem, length, width, height, channels, 0);
    return dat;
}

const char* PKLoadImageFromData( NSData *dat, int *width, int *height, int *channels) {
    return PKLoadImageFromMemory( [dat bytes], [dat length], width, height, channels);
}

void PKFreeImageFile( const char *data) {
    stbi_image_free( (unsigned char*)data);
}
