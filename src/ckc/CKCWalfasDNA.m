#import "CKCWalfasDNA.h"
#import <string.h>

NSString* CKCEncodeGdkRGBA( GdkRGBA color) {
    unsigned char r, g, b;
    r = color.red * 256;
    g = color.green * 256;
    b = color.blue * 256;
    char buf[10];
    sprintf( buf, "%02X%02X%02X", r, g, b);
    return [[NSString stringWithUTF8String:buf] autorelease];
}

BOOL CKCTryDecodeGdkRGBA( NSString *src, GdkRGBA *color) {
    if( [src length] != 6) return NO;
    unsigned int rr, gg, bb;
    sscanf( [src UTF8String], "%02X%02X%02X", &rr, &gg, &bb);
    rr = rr & 0xFF;
    gg = gg & 0xFF;
    bb = bb & 0xFF;
    color->red = rr / 255.0f;
    color->green = gg / 255.0f;
    color->blue = bb / 255.0f;
    return YES;
}

// XXX: to be tested
NSString* CKCEncodeLegacyCharacterIntoDNA( CKCLegacyCharacter *source, CKCLegacyCharacterVersion target) {
    const char *createSwf = "3.39", *createSwfExtended = "3.4";
    NSString *result = NULL;
    switch( target) {
        case CKCLegacyCharacterVersionCreateSwf3_39:
            result = [NSString stringWithFormat:@"%s:%@:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%@",
                        createSwf, source.name, (unsigned long)source.scale,
                        source.hat,
                        source.head,
                        source.body,
                        source.arm,
                        source.shoe,
                        source.eye,
                        source.mouth,
                        source.item,
                        source.accessory,
                        source.wing,
                        CKCEncodeGdkRGBA( source.hairColor)];
            break;
        case CKCLegacyCharacterVersionCreateSwfExtended3_4:
            result = [NSString stringWithFormat:@"%s:%@:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%lu:%@:%@:0",
                        createSwfExtended, source.name, (unsigned long)source.scale,
                        source.hat,
                        source.head,
                        source.body,
                        source.arm,
                        source.shoe,
                        source.eye,
                        source.mouth,
                        source.item,
                        source.accessory,
                        source.wing,
                        CKCEncodeGdkRGBA( source.hairColor),
                        CKCEncodeGdkRGBA( source.skinColor)];
            break;
    }
    if( result == NULL) return NULL; // ?!?
    return [result autorelease];
}
BOOL CKCDecodeDNAIntoLegacyCharacter( NSString *source, CKCLegacyCharacter *target) {

}
