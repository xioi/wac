#import <Foundation/Foundation.h>
#import <gtk/gtk.h>
#import "i18n.h"

NSString* WACFormat( NSString *fmt, ...);

int main( int argc, char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    GtkBuilder *builder;
    GError *error = NULL;
    GObject *window;
    gtk_init( &argc, &argv);
    builder = gtk_builder_new();
    if( gtk_builder_add_from_file( builder, "ui/wac.ui", &error) == 0) {
        NSLog( @"Error %s", error->message);
        g_clear_error( &error);
        return 1;
    }
    window = gtk_builder_get_object( builder, "wac_window");
    g_signal_connect( window, "destroy", G_CALLBACK( gtk_main_quit), NULL);

    gtk_main();
    [pool release];
    return 0;
}

// NSLog( @"%@", WACFormat( @"{0} {1} {0}", @"0", @"1")); ---> "0 1 0"
NSString* WACFormat( NSString *fmt, ...) {
    NSString *args[128], *now;
    int i=0;
    va_list l;
    va_start( l, fmt);
    while( (now = va_arg( l, NSString*)) != 0) {
        args[i] = now;
        ++i;
    }
    va_end( l);
    NSMutableString *r = [NSMutableString new];
    unsigned int begin = 0, ptr = 0, end = [fmt length];
    while( ptr < end) {
        unsigned int fw = ptr;
        while( fw <= end) {
            if( fw == end) {
                [r appendString:[fmt substringWithRange:NSMakeRange( ptr - begin, fw - ptr)]];
                break;
            }
            if( [fmt characterAtIndex:fw] == '{') {
                [r appendString:[fmt substringWithRange:NSMakeRange( ptr - begin, fw - ptr)]];
                ++fw;
                unsigned int value = 0;
                while( [fmt characterAtIndex:fw] != '}') {
                    value *= 10;
                    value += [fmt characterAtIndex:fw] - '0';
                    ++fw;
                }
                // unsafe
                [r appendString:args[value]];
                ++fw;
                break;
            }
            ++fw;
        }
        ptr = fw;
    }
    return r;
}
