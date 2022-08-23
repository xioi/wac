#import "./PKException.h"
#import <execinfo.h>

static void printStackTrace() {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    void *returnAddresses[500];
    int depth = backtrace( returnAddresses, sizeof returnAddresses / sizeof *returnAddresses);
    NSLog( @"Now print Stack Frames...Stack depth = %d\n", depth);
    char **symbols = backtrace_symbols( returnAddresses, depth);
    for (int i = 0; i < depth; ++i) {
        printf( "%s\n", symbols[i]);
    }
    free(symbols);
    [pool release];
}

void PKThrowError( NSString *reason, NSString *info) {
    NSLog( @"[Error][%@]%@", reason, info);
    printStackTrace();
}

void PKExit( int status) { exit( status);}
void PKAbort() { abort();}
