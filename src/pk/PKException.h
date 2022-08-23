// P'an Ku Library
// PKException.h
#import <Foundation/Foundation.h>

void PKThrowError( NSString *reason, NSString *info);
void PKExit( int status);
void PKAbort();

#define PKFormat( fmt, ...) [NSString stringWithFormat:(fmt),##__VA_ARGS__]
#define PKRuntimeError( fmt, ...) PKThrowError( @"Runtime Error", ( PKFormat( (fmt),##__VA_ARGS__)))
#define PKLogicError( fmt, ...) PKThrowError( @"Logic Error", ( PKFormat( (fmt),##__VA_ARGS__)))
#define PKIOError( fmt, ...) PKThrowError( @"IO Error", ( PKFormat( (fmt),##__VA_ARGS__)))
