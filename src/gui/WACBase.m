#import "WACWindow.h"
#import "WACLang.h"

@implementation WACText
- (NSString*)value { // default implementation
    return @"{Default text in WACBase.m:5}";
}
@end

@implementation WACConstantText
- (id)initFromString:(NSString*)constant_ {
    if( self = [self init]) {
        self->constant = constant_;
    }
    return self;
}
+ (instancetype)textFromString:(NSString*)constant {
    id c = [WACConstantText alloc];
    c = [c initFromString:constant];
    return c;
}

- (NSString*)value {
    return constant;
}
@end

@implementation WACLangText
- (id)initFromString:(NSString*)lang_ {
    if( self = [self init]) {
        self->lang = lang_;
    }
    return self;
}
+ (instancetype)textFromString:(NSString*)lang {
    id l = [WACLangText alloc];
    l = [l initFromString:lang];
    return l;
}

- (NSString*)value {
    WACLangMgr *mgr = WACLangMgrContext();
    return [mgr valueOf:lang];
}
@end
