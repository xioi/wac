#import <Foundation/Foundation.h>

typedef NS_ENUM( NSUInteger, CKCEditorFieldType) {
    CKCStringField = 0,
    CKCIntField,
    CKCFloatField,
    CKCVec2Field
};

typedef NS_OPTIONS( NSUInteger, CKCEditorFieldOptions) {
    CKCEditorNormalField        = 0,
    CKCEditorDisabledField      = 1 << 0,
    CKCEditorRangedNumberField  = 1 << 1
};

@interface CKCEditorField : NSObject {
    @protected
    CKCEditorFieldType type;
    CKCEditorFieldOptions options;
}
@property (readwrite) CKCEditorFieldType type;
@property (readwrite) CKCEditorFieldOptions options;
@end

@interface CKCEditorArgumentModel : NSObject {
    @protected
    
}
@end