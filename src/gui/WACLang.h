#import <Foundation/Foundation.h>

@interface WACLanguagePackage : NSObject {
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

@interface WACLangMgr : NSObject {
    @private
    NSMutableDictionary *packages;
    WACLanguagePackage *current;
}
- (void)loadLanguageFile:(NSString*)name;
- (void)switchLanguagePackage:(NSString*)languageName;
- (NSString*)valueOf:(NSString*)identity;
- (WACLanguagePackage*)getPackage:(NSString*)language;
@end

WACLangMgr* WACLangMgrContext();