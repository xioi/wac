#import <Foundation/Foundation.h>

typedef NS_ENUM( NSUInteger, CKCCharacterPartType) {
    CKCCharacterPartTypeNone = 0,
    CKCCharacterPartTypeHat = 1,
    CKCCharacterPartTypeHead,
    CKCCharacterPartTypeBody,
    CKCCharacterPartTypeArm,
    CKCCharacterPartTypeShoe,
    CKCCharacterPartTypeEye,
    CKCCharacterPartTypeMouth,
    CKCCharacterPartTypeItem,
    CKCCharacterPartTypeAccessory,
    CKCCharacterPartTypeWing
};

// Any type of apperance
// such as body parts, toys, items etc.
@interface CKCBaseComponent : NSObject
@end

// Character parts
@interface CKCCharacterPart : NSObject
@end

// Character model for Create.swf & Create.swf Extended
// (For importing purpose)
@interface CKCLegacyCharacter : NSObject
@end

// WAC Character model
@interface CKCCharacter : NSObject {
    @protected

}
@end