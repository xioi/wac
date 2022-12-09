#import "CKCWalfasDNA.h"
#import <string.h>

NSString* CKCEncodeWFCColor( struct WFCColor color) {
    unsigned char r, g, b;
    r = color.r * 256;
    g = color.g * 256;
    b = color.b * 256;
    char buf[10];
    sprintf( buf, "%02X%02X%02X", r, g, b);
    return [[NSString stringWithUTF8String:buf] autorelease];
}

BOOL CKCTryDecodeWFCColor( NSString *src, struct WFCColor *color) {
    if( [src length] != 6) return NO;
    unsigned int rr, gg, bb;
    sscanf( [src UTF8String], "%02X%02X%02X", &rr, &gg, &bb);
    rr = rr & 0xFF;
    gg = gg & 0xFF;
    bb = bb & 0xFF;
    color->r = rr / 255.0f;
    color->g = gg / 255.0f;
    color->b = bb / 255.0f;
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
                        CKCEncodeWFCColor( source.hairColor)];
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
                        CKCEncodeWFCColor( source.hairColor),
                        CKCEncodeWFCColor( source.skinColor)];
            break;
    }
    if( result == NULL) return NULL; // ?!?
    return [result autorelease];
}
BOOL CKCDecodeDNAIntoLegacyCharacter( NSString *source, CKCLegacyCharacter *target) {

}
