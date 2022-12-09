#import <Foundation/Foundation.h>
#import <renderers/WFCRenderer.h>

typedef NS_ENUM( NSUInteger, CKCLegacyCharacterVersion) {
    CKCLegacyCharacterVersionCreateSwf3_39,
    CKCLegacyCharacterVersionCreateSwfExtended3_4
};

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
@interface CKCLegacyCharacter : NSObject {
    @protected
    CKCLegacyCharacterVersion version;
    NSString *name;
    float scale;
    NSUInteger hat;
    NSUInteger head;
    NSUInteger body;
    NSUInteger arm;
    NSUInteger shoe;
    NSUInteger eye;
    NSUInteger mouth;
    NSUInteger item;
    NSUInteger accessory;
    NSUInteger wing;

    struct WFCColor hairColor;
    struct WFCColor skinColor;

    NSUInteger unknownField;
}
@property (readwrite) CKCLegacyCharacterVersion version;
@property (readwrite, copy) NSString *name;
@property (readwrite) float scale;
@property (readwrite) NSUInteger hat;
@property (readwrite) NSUInteger head;
@property (readwrite) NSUInteger body;
@property (readwrite) NSUInteger arm;
@property (readwrite) NSUInteger shoe;
@property (readwrite) NSUInteger eye;
@property (readwrite) NSUInteger mouth;
@property (readwrite) NSUInteger item;
@property (readwrite) NSUInteger accessory;
@property (readwrite) NSUInteger wing;

@property (readwrite) struct WFCColor hairColor;
@property (readwrite) struct WFCColor skinColor;

@property (readwrite) NSUInteger unknownField;

- (id)initWithVersion:(CKCLegacyCharacterVersion)version;
- (id)initWithDNA:(NSString*)dna;
+ (instancetype)legacyCharacterFromDNA:(NSString*)dna;

- (NSString*)dna;
@end

// WAC Character model
@interface CKCCharacter : NSObject {
    @protected

}
@end