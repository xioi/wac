#import <Foundation/Foundation.h>

@interface WFCText : NSObject
- (NSString*)value;
- (NSString*)remake;
@end

@interface WFCConstantText : WFCText {
    @private
    NSString *constant;
}
- (id)initFromString:(NSString*)constant;
+ (instancetype)textFromString:(NSString*)constant;
@end

@interface WFCLangText : WFCText {
    @private
    NSMutableArray *text;
    NSString *cache;
}
- (id)initFromString:(NSString*)lang;
+ (instancetype)textFromString:(NSString*)lang;
@end

@interface WFCLanguagePackage : NSObject {
    @private
    NSMutableDictionary *data;
    //NSString *name, *identity, *author, *version;
    NSString *identity, *author;
}
@property (readwrite, copy) NSString *identity;
@property (readwrite, copy) NSString *author;

- (void)addEntry:(NSString*)identity value:(NSString*)value;
- (NSString*)valueOf:(NSString*)identity;
@end

@interface WFCLangMgr : NSObject {
    @private
    NSMutableDictionary *packages;
    WFCLanguagePackage *current;
}
- (void)loadLanguageFile:(NSString*)name;
- (void)switchLanguagePackage:(NSString*)languageName;
- (NSString*)valueOf:(NSString*)identity;
- (WFCLanguagePackage*)getPackage:(NSString*)language;
@end

WFCLangMgr* WFCLangMgrContext();