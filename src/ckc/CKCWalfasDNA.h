#import <string.h>
#import "CKCCharacter.h"

NSString* CKCEncodeLegacyCharacterIntoDNA( CKCLegacyCharacter *source, CKCLegacyCharacterTarget mode);
BOOL CKCDecodeDNAIntoLegacyCharacter( NSString *source, CKCLegacyCharacter *target);