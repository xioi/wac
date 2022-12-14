#import <Foundation/Foundation.h>
#import <gtk/gtk.h>
#import <stdlib.h>
#import <librsvg/rsvg.h>
#import <plutosvg.h>
#import "i18n.h"

cairo_surface_t *vg_surface = NULL;

NSString* WACFormat( NSString *fmt, ...);
static gboolean canvas_draw( GtkWidget *canvas, cairo_t *cr, gpointer data) {
    guint width, height;
    GtkStyleContext *context;
    GdkRGBA color;

    context = gtk_widget_get_style_context( canvas);
    width = gtk_widget_get_allocated_width( canvas);
    height = gtk_widget_get_allocated_height( canvas);

    gtk_render_background( context, cr, 0, 0, width, height);

    cairo_set_source_surface( cr, vg_surface, 0, 0);
    cairo_paint( cr);

    cairo_arc( cr, width / 2.0, height / 2.0, MIN( width, height) / 2.0, 0, 2 * G_PI);

    gtk_style_context_get_color( context, gtk_style_context_get_state( context), &color);
    gdk_cairo_set_source_rgba( cr, &color);
    // cairo_fill( cr);
    cairo_stroke( cr);

    cairo_select_font_face( cr, "sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD);
    cairo_set_font_size( cr, 70.0);
    cairo_move_to( cr, 40.0, 80.0);
    cairo_show_text( cr, "Я а он ем яблоко.");
    cairo_move_to( cr, 70.0, 140.0);
    cairo_text_path( cr, "Waffle & Cookie");
    cairo_set_source_rgb( cr, 0.5, 0.5, 1);
    cairo_fill_preserve( cr);
    cairo_set_source_rgb( cr, 0, 0, 0);
    cairo_stroke( cr);
    return NO;
}

static void action_new( GSimpleAction *action, GVariant *param, gpointer app) {
    // printf( "new file\n");
}

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
    gtk_application_set_menubar( app, G_MENU_MODEL( gtk_builder_get_object( builder, "app_menu")));
    
    GtkWidget *canvas = GTK_WIDGET( gtk_builder_get_object( builder, "canvas"));
    g_signal_connect( canvas, "draw", G_CALLBACK( canvas_draw), NULL);

    GActionEntry app_entries[] = {
        { "new", action_new, NULL, NULL, NULL}
    };
    const gchar *new_file_accels[] = { "<Ctrl>N", NULL};
    g_action_map_add_action_entries( G_ACTION_MAP( app), app_entries, 1, NULL);
    gtk_application_set_accels_for_action( app, "app.new", new_file_accels);

    gtk_window_present( GTK_WINDOW( window));

    // Load svg
    g_autoptr( GFile) vg_file = g_file_new_for_path( "graphics/body.svg");
    RsvgHandle *handle = rsvg_handle_new_from_gfile_sync( vg_file, RSVG_HANDLE_FLAGS_NONE, NULL, &error);
    if( !handle) {
        NSLog( @"Svg load error: %s", error->message);
        exit( 1);
    }
    const int width = 400;
    const int height = 400;

    rsvg_handle_set_dpi( handle, 1);

    vg_surface = cairo_image_surface_create( CAIRO_FORMAT_ARGB32, width, height);
    cairo_t *cr = cairo_create( vg_surface);

    RsvgRectangle viewport = {
        .x = 0,
        .y = 0,
        .width = width,
        .height = height
    };
    if( !rsvg_handle_render_document( handle, cr, &viewport, &error)) {
        NSLog( @"Svg render error: %s", error->message);
        exit( 2);
    }
    cairo_destroy( cr);
    g_object_unref( handle);
}

int main( int argc, char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    int result = 0;
    g_autoptr( GtkApplication) app = gtk_application_new( "org.nopss.wac", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect( app, "activate", G_CALLBACK( activate), NULL);
    result = g_application_run( G_APPLICATION( app), argc, argv);
    [pool release];
    return result;
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
