#import "CKCCharacter.h"
#import "CKCWalfasDNA.h"

@implementation CKCLegacyCharacter 
@synthesize version;
@synthesize name;
@synthesize scale;
@synthesize hat;
@synthesize head;
@synthesize body;
@synthesize arm;
@synthesize shoe;
@synthesize eye;
@synthesize mouth;
@synthesize item;
@synthesize accessory;
@synthesize wing;

@synthesize hairColor;
@synthesize skinColor;

@synthesize unknownField;

- (id)initWithVersion:(CKCLegacyCharacterVersion)version_ {
    if( self = [self init]) {
        self.version = version_;
    }
    return self;
}
- (id)initWithDNA:(NSString*)dna {
    if( self = [self init]) {
        BOOL success = CKCDecodeDNAIntoLegacyCharacter( dna, self);
        if( !success) {
            // TODO: tackle errors
            // But let it go may be another way to warn users.
        }
    }
    return self;
}
+ (instancetype)legacyCharacterFromDNA:(NSString*)dna {
    id obj = [[[self class] alloc] initWithDNA:dna];
    return obj;
}

- (NSString*)dna {
    return CKCEncodeLegacyCharacterIntoDNA( self, self.version);
}

@end