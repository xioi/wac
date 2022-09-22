#import "WFCWindow.h"
#import "WFCLang.h"

@implementation WFCText
- (NSString*)value {    // default implementation
    return @"{Default text in WFCBase.m:6}";
}
- (NSString*)remake {
    return [self value];
}
@end

@implementation WFCConstantText
- (id)initFromString:(NSString*)constant_ {
    if( self = [self init]) {
        self->constant = constant_;
    }
    return self;
}
+ (instancetype)textFromString:(NSString*)constant {
    id c = [WFCConstantText alloc];
    c = [c initFromString:constant];
    return c;
}

- (NSString*)value {
    return constant;
}
@end

// @"AAA$WFC.ui.file$BBBB$WFC.ui.edit$CCC"
// -> @"AAAFileBBBBEditCCC"
@implementation WFCLangText
- (id)initFromString:(NSString*)lang_ {
    if( self = [self init]) {
        self->text = [self parse:lang_];
        self->cache = NULL;
    }
    return self;
}
+ (instancetype)textFromString:(NSString*)lang {
    id l = [WFCLangText alloc];
    l = [l initFromString:lang];
    return l;
}

- (NSString*)langValue:(NSString*)item {
    WFCLangMgr *mgr = WFCLangMgrContext();
    NSString *v = [mgr valueOf:[NSString stringWithFormat:@"content.%@", item]];
    if( v != NULL) return v;
    return [NSString stringWithFormat:@"[UNKNOWN ENTRY:%@]", item];
}

- (NSMutableArray*)parse:(NSString*)str {
    NSMutableArray *arr = [NSMutableArray array];
    const int length = [str length];
    int last = 0;
    for( int i=0;i<length;++i) {
        if( [str characterAtIndex:i] == '$') {
            [arr addObject:[str substringWithRange:NSMakeRange( last, i-last)]];
            last = i;
            i += 1;
            while( [str characterAtIndex:i] != '$') {
                i += 1;
            }
            [arr addObject:[str substringWithRange:NSMakeRange( last, i-last)]];
            i += 1;
            last = i;
        }else if( [str characterAtIndex:i] == '\\') {   // maybe \$
            if( i != length - 1) {  // not the last character
                if( [str characterAtIndex:(i+1)] == '$') {
                    i += 2;
                    continue;
                }
            }
        }
    }
    if( last != length) {
        [arr addObject:[str substringWithRange:NSMakeRange( last, length-last)]];
    }

    return arr;
}

- (NSString*)generate {
    if( text == NULL) return NULL;
    NSMutableString *ret = [NSMutableString string];
    int count = [text count];
    for( int i=0;i<count;++i) {
        NSString *current = [text objectAtIndex:i];
        char ch = [current characterAtIndex:0];
        if( ch == '$' || ch == '\\') { // TODO:完善$的不显示机制
            [ret appendString:[self langValue:[current substringFromIndex:1]]];
        }else {
            [ret appendString:current];
        }
    }
    return ret;
}

- (NSString*)value {
    if( cache != NULL) return cache;
    cache = [self generate];
    return cache;
}

- (NSString*)remake {
    cache = [self generate];
    return cache;
}
@end
