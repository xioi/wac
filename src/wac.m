#import <stdlib.h>
#import <unistd.h>
#import <libgen.h>
#import <librsvg/rsvg.h>
#import <CKCScene.h>
#import "WACEditor.h"
#import "i18n.h"

cairo_surface_t *vg_surface = NULL;
WACEditorProxy *editor;

static gboolean canvas_draw( GtkWidget *canvas, cairo_t *cr, gpointer data) {
    guint width, height;
    GtkStyleContext *context;
    GdkRGBA color;

    context = gtk_widget_get_style_context( canvas);
    width = gtk_widget_get_allocated_width( canvas);
    height = gtk_widget_get_allocated_height( canvas);

    gtk_render_background( context, cr, 0, 0, width, height);

    CKCRenderContext ctx = {
        .width = width,
        .height = height,
        .cr = cr
    };

    [editor renderWithContext:&ctx];
    return NO;
}

static void action_new( GSimpleAction *action, GVariant *param, gpointer app) {}

static void do_press( GtkWidget *panel, GdkEventButton *event, gpointer data) {
    [editor pointerDidPressAtX:event->x y:event->y button:event->button modifier:event->state];
}

static void do_release( GtkWidget *panel, GdkEventButton *event, gpointer data) {
    [editor pointerDidReleaseAtX:event->x y:event->y button:event->button modifier:event->state];
}

static gboolean motion( GtkWidget *self, GdkEventMotion *event, gpointer d) {
    [editor pointerDidMoveToX:event->x y:event->y];
    return YES;
}

static gboolean logical_frame( gpointer data) {
    [editor update];
    return YES;
}

static gboolean redraw( gpointer data) {
    gtk_widget_queue_draw( GTK_WIDGET( data));
    return YES;
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
    // Window setting
    window = gtk_builder_get_object( builder, "wac_window");
    gtk_window_set_application( GTK_WINDOW( window), app);
    gtk_application_set_menubar( app, G_MENU_MODEL( gtk_builder_get_object( builder, "app_menu")));
    /// Main canvas
    GtkWidget *canvas = GTK_WIDGET( gtk_builder_get_object( builder, "canvas"));
    gtk_widget_add_events( canvas, GDK_POINTER_MOTION_MASK | GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK);

    g_signal_connect( canvas, "draw", G_CALLBACK( canvas_draw), NULL);
    g_signal_connect( canvas, "button-press-event", G_CALLBACK( do_press), NULL);
    g_signal_connect( canvas, "button-release-event", G_CALLBACK( do_release), NULL);
    g_signal_connect( canvas, "motion-notify-event", G_CALLBACK( motion), NULL);

    g_timeout_add( 1000 / 30, (GSourceFunc)logical_frame, NULL);
    g_timeout_add( 1000 / 30, (GSourceFunc)redraw, (gpointer)canvas); // force canvas to redraw
    /// App menu
    GActionEntry app_entries[] = {
        { "new", action_new, NULL, NULL, NULL}
    };
    const gchar *new_file_accels[] = { "<Ctrl>N", NULL};
    g_action_map_add_action_entries( G_ACTION_MAP( app), app_entries, 1, NULL);
    gtk_application_set_accels_for_action( app, "app.new", new_file_accels);

    // gtk_window_present( GTK_WINDOW( window));
}

int main( int argc, char **argv) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    chdir( dirname( argv[0])); // change the current working directory
    editor = [[WACEditorProxy new] autorelease];
    int result = 0;
    g_autoptr( GtkApplication) app = gtk_application_new( "org.wac.animator", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect( app, "activate", G_CALLBACK( activate), NULL);
    result = g_application_run( G_APPLICATION( app), argc, argv);
    [pool release];
    return result;
}

@interface TCVariable : NSObject
- (void)interpolateBetween:(id)first and:(id)second with:(float)x;
@end

@interface TCFloatVariable : TCVariable {
    @private
    float value;
}
@end

@interface TCVec2Variable : TCVariable {
    @private
    float x, y;
}
@property float x;
@property float y;
@end

@interface TCAnimatableObject : NSObject
@end

@interface TCTestObject : TCAnimatableObject {
    @private
    TCFloatVariable *alpha;
    TCVec2Variable *position;
}
@property (readwrite, copy) TCFloatVariable *alpha;
@property (readwrite, copy) TCVec2Variable *position;
@end

#import <objc/runtime.h>

// int main( int argc, char **argv) {
//     NSAutoreleasePool *pool = [NSAutoreleasePool new];
//     TCTestObject *obj1 = [[TCTestObject new] autorelease];
//     id pro1 = [obj1 valueForKey:@"position"];
//     NSLog( @"\"position\": %@", NSStringFromClass( [pro1 class]));
//     [pool release];
//     return 0;
// }

@implementation TCVariable
- (void)interpolateBetween:(id)first and:(id)second with:(float)x {}
@end

@implementation TCFloatVariable
- (void)interpolateBetween:(id)first and:(id)second with:(float)x {
    // dummy
}
@end

@implementation TCVec2Variable
@synthesize x;
@synthesize y;

- (id)copyWithZone:(NSZone*)zone {
    TCVec2Variable *n = [[[self class] allocWithZone:zone] init];
    [n setX:x];
    [n setY:y];
    return n;
}
@end

@implementation TCAnimatableObject
@end

@implementation TCTestObject
@synthesize position;
@synthesize alpha;

- (id)init {
    if( self = [super init]) {
        position = [TCVec2Variable new];
        alpha = [TCFloatVariable new];
    }
    return self;
}
@end
