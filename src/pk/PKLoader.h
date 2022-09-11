#import "PanKu.h"

const char* PKLoadImageFile( NSString *path, int *width, int *height, int *channels);
const char* PKLoadImageFromMemory( const char *mem, int length, int *width, int *height, int *channels);
const char* PKLoadImageFromData( NSData *dat, int *width, int *height, int *channels);
void PKFreeImageFile( const char *data);