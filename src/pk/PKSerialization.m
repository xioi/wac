#import "PKSerialization.h"
#import <yaml.h>
#import <objc/runtime.h>

/* static const char *getPropertyType( objc_property_t property) {
    const char *attributes = property_getAttributes( property);
    char buffer[1 + strlen( attributes)];
    strcpy( buffer, attributes);
    char *state = buffer, *attribute;
    while( ( attribute = strsep( &state, ",")) != NULL) {
        if( attribute[0] == 'T') {
            if( strlen(attribute) <= 4) {
                break;
            }
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes]; // XXX: may causes memory leaks??
        }
    }
    return "@";
}

NSData* PKMarshalYAML( id object) {
    NSMutableData *dat = [NSMutableData new];

}

BOOL PKUnmarshalYAML( id object, NSData *src) {
    Class cls = [object class];
    uint pCount;
    objc_property_t *properties = class_copyPropertyList( cls, &pCount);
    NSLog( @"[%@]Property Count: %d", cls, pCount);
    for( int i=0;i<pCount;++i) {
        objc_property_t p = properties[i];
        const char *name = property_getName( p);
        const char *attr = property_getAttributes( p);
        const char *type = getPropertyType( p);
        NSLog( @"%s %s", name, type);
    }
} */
