#import "WACLang.h"
#import <yaml.h>

@implementation WACLanguagePackage
@synthesize identity;
@synthesize author;

- (id)init {
    if( self = [super init]) {
        data = [NSMutableDictionary new];
    }
    return self;
}
- (void)dealloc {
    [data release];
    [super dealloc];
}

- (void)addEntry:(NSString*)identity_ value:(NSString*)value {
    [data setObject:value forKey:identity_];
}
- (NSString*)valueOf:(NSString*)identity_ {
    return data[identity_];
}
@end

@implementation WACLangMgr
- (id)init {
    if( self = [super init]) {
        packages = [NSMutableDictionary new];
        [self loadLanguageFile:@"zh-cn"]; // 默认加载zh-cn
        current = [self getPackage:@"zh-cn"];
    }
    return self;
}
- (void)dealloc {
    [packages release];
    [super dealloc];
}

- (void)loadLanguageFile:(NSString*)name { // load language file
    [[self getPackage:name] release]; // release the old one

    id pak = [WACLanguagePackage new];
    [packages setObject:pak forKey:name];
    NSString *path = [NSString stringWithFormat:@"./lang/%@.yml", name];

    yaml_parser_t parser;
    yaml_token_t token;
    BOOL done = NO;
    yaml_parser_initialize( &parser);

    NSData *data = [[NSData alloc] initWithContentsOfFile:path];            // load file into memory via NSData
    if( [data bytes] == NULL) goto error;
    yaml_parser_set_input_string( &parser, [data bytes], [data length]);

    NSMutableArray *stack = [NSMutableArray arrayWithArray:@[@""]];         // prefix stack
    BOOL new_key = NO, in_content = NO, toppest = YES;
    NSString *last_one = NULL, *base = @"";
    do {
        yaml_parser_scan( &parser, &token);
        switch( token.type) {
            case YAML_KEY_TOKEN:
                new_key = YES;
                break;
            case YAML_VALUE_TOKEN:
                break;
            case YAML_SCALAR_TOKEN:
                if( new_key) {
                    last_one = [NSString stringWithUTF8String:(const char*)token.data.scalar.value];
                    new_key = NO;
                }else {
                    NSString *val = [NSString stringWithUTF8String:(const char*)token.data.scalar.value];
                    NSString *now_key = toppest ? last_one : [NSString stringWithFormat:@"%@.%@", base, last_one];
                    [pak addEntry:now_key value:val];
                }
                break;
            case YAML_BLOCK_MAPPING_START_TOKEN:
                if( last_one != NULL) {
                    base = toppest ? last_one : [NSString stringWithFormat:@"%@.%@", base, last_one];
                    [stack addObject:base];
                    toppest = NO;
                }
                break;
            case YAML_BLOCK_END_TOKEN:
                [stack removeLastObject];
                base = [stack lastObject];
                toppest = [stack count] == 1;
                break;
            default:
                break;
        }

        if( token.type != YAML_STREAM_END_TOKEN) {
            yaml_token_delete( &token);
        }
    } while( token.type != YAML_STREAM_END_TOKEN);

    [pak setIdentity:[pak valueOf:@"lang"]];
    [pak setAuthor:[pak valueOf:@"author"]];

    yaml_token_delete( &token);
    yaml_parser_delete( &parser);
    [data release];
    [stack release];
    return;
error:
    NSLog( @"Failed to parse lang file:%@", path);
    yaml_parser_delete( &parser);
    [data release];
}
- (void)switchLanguagePackage:(NSString*)languageName {
    id n = [self getPackage:languageName];
    if( n != NULL) {
        current = n;
    }
}
- (NSString*)valueOf:(NSString*)identity {
    return [current valueOf:identity];
}
- (WACLanguagePackage*)getPackage:(NSString*)language {
    return [packages valueForKey:language];
}
@end

static WACLangMgr *gContext = NULL;
WACLangMgr* WACLangMgrContext() { // 单例
    if( gContext == NULL) {
        gContext = [WACLangMgr new];
        //[gContext loadLanguageFile:@"zh-cn"];
    }
    return gContext;
}
