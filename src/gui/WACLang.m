#import "WACLang.h"
#import <yaml.h>

@implementation WACLanguagePackage
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

- (void)addEntry:(NSString*)identity value:(NSString*)value {
    [data setObject:value forKey:identity];
}
- (NSString*)valueOf:(NSString*)identity {
    return data[identity];
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

- (void)loadLanguageFile:(NSString*)name {
    id old = [self getPackage:name];
    [name release];

    id new_one = [WACLanguagePackage new];
    [packages setObject:new_one forKey:name];
    // TODO:load yml file
    NSString *path = [NSString stringWithFormat:@"./lang/%@.yml", name];

    yaml_parser_t parser;
    yaml_event_t e;
    BOOL done = NO;
    yaml_parser_initialize( &parser);

    FILE *input = fopen( [path UTF8String], "rb");
    if( input == NULL) {
        NSLog( @"Failed to load file:%@", path);
        return;
    }
    yaml_parser_set_input_file( &parser, input);

    while( !done) {
        if( !yaml_parser_parse( &parser, &e)) {
            goto error;
        }

        done = (e.type == YAML_STREAM_END_EVENT);

        yaml_event_delete( &e);
    }

    yaml_parser_delete( &parser);
    fclose( input);
error:
    NSLog( @"Failed to parse lang file:%@", path);
    yaml_parser_delete( &parser);
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