#import <Foundation/Foundation.h>

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