#import <string.h>
#import "CKCCharacter.h"

NSString* CKCEncodeLegacyCharacterIntoDNA( CKCLegacyCharacter *source, CKCLegacyCharacterVersion target);
BOOL CKCDecodeDNAIntoLegacyCharacter( NSString *source, CKCLegacyCharacter *target);