#import <Foundation/Foundation.h>
#import <gtk/gtk.h>
#import <stdlib.h>
#import "i18n.h"

NSString* WACFormat( NSString *fmt, ...);
static void activate( GtkApplication *app, gpointer data) {
    GtkBuilder *builder;
    GError *error = NULL;
    GObject *window;
    builder = gtk_builder_new();
    if( gtk_builder_add_from_file( builder, "ui/wac.ui", &error) == 0) {
        NSLog( @"Error %s", error->message);
        g_clear_error( &error);
        exit( 1);
    }
    window = gtk_builder_get_object( builder, "wac_window");
    gtk_window_set_application( GTK_WINDOW( window), app);

    GMenu *gmenu;// = g_menu_new();
    gmenu = G_MENU( gtk_builder_get_object( builder, "app_menu"));

    // GMenu *app_menu, *section1;
    // app_menu = G_MENU( gtk_application_get_app_menu( app));
    
    // section1 = g_menu_new();
    // g_menu_append( section1, _( "_New"), "win.new");
    // g_menu_prepend_section( app_menu, _( "_File"), G_MENU_MODEL( section1));
    // g_menu_append_submenu( gmenu, _( "_File"), G_MENU_MODEL( section1));
    gtk_application_set_menubar( app, G_MENU_MODEL( gmenu));

    gtk_widget_hide( GTK_WIDGET( gtk_builder_get_object( builder, "wac_menubar")));

    // gtk_application_set_app_menu( app, G_MENU_MODEL( app_menu));
    // NSLog( @"%lld", (long long)(gtk_application_get_app_menu( app)));
}

int main( int argc, char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    GtkApplication *app = gtk_application_new( "org.nopss.wac", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect( app, "activate", G_CALLBACK( activate), NULL);
    int result = g_application_run( G_APPLICATION( app), argc, argv);
    g_object_unref( app);
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
