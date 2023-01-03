#import "CKCScene.h"
#import <librsvg/rsvg.h>

@implementation CKCSceneSprite
@synthesize x;
@synthesize y;
@synthesize angle;
@synthesize scalex;
@synthesize scaley;
@synthesize orignx;
@synthesize origny;

- (NSString*)identity {
    return identity;
}
- (void)setIdentity:(NSString*)identity_ {
    if( identity != identity_) {
        if( ![identity_ isEqualTo:identity]) {
            reloadFlag = YES; // have to reload
        }
        [identity release];
        identity = [identity_ copy];
    }
}

- (id)init {
    if( self = [super init]) {
        reloadFlag = YES;
        scalex = scaley = 1;
        x = y = 0;
        angle = 0;
        orignx = origny = 0;
        // Platform
        surface = NULL;
    }
    return self;
}

- (void)platformCreateImageWithIdentity:(NSString*)path forSurface:(cairo_surface_t**)surface_ {
    // supported format: ( png, svg)
    // 1. find the extension hand by hand
    NSUInteger ei = [path length] - 1;
    NSString *extension = nil;
    while( ei > 0) {
        if( [path characterAtIndex:ei] == '.') {
            extension = [path substringFromIndex:(ei + 1)];
            break;
        }else {
            ei -= 1;
        }
    }
    if( ei == 0) { // it doesn't have extension 
        return;
    }
    
    // 2. try to match the extension
    if( [extension isEqualTo:@"png"]) { // try to load png
        *surface_ = cairo_image_surface_create_from_png( [path UTF8String]);
    }else if( [extension isEqualTo:@"svg"]) { // try to load svg
        GError *error = NULL;
        GFile *file = g_file_new_for_path( [path UTF8String]);
        RsvgHandle *handle = rsvg_handle_new_from_gfile_sync( file, RSVG_HANDLE_FLAGS_NONE, NULL, &error);
        g_object_unref( file);
        if( !handle) {
            // error: failed to load svg
            NSLog( @"error: failed to load svg, %s", error->message);
            return;
        }
        RsvgRectangle rect;
        rsvg_handle_get_geometry_for_element( handle, NULL, NULL, &rect, &error);
        cairo_surface_t *target = cairo_image_surface_create( CAIRO_FORMAT_ARGB32, rect.width, rect.height);
        cairo_t *cr = cairo_create( target);
        *surface_ = target;

        // set our orign...no, "rsvg_handle_get_geometry_for_element" cannot help us to cacluate the origin point
        // orignx = -rect.x;
        // origny = -rect.y;

        if( !rsvg_handle_render_document( handle, cr, &rect, &error)) {
            cairo_destroy( cr);
            cairo_surface_destroy( target);
            g_object_unref( handle);
            *surface_ = NULL;
            // error: failed to render
            NSLog( @"error: failed to render, %s", error->message);
            return;
        }
        cairo_destroy( cr);
        g_object_unref( handle);
    }else { // failed to match
        // bad extension
    }
}

- (void)forceLoad {
    // Platform
    // Step1. try releasing previous image resource
    if( surface != NULL) {
        cairo_surface_destroy( surface);
    }
    // Step2. load next image
    [self platformCreateImageWithIdentity:identity forSurface:&surface];
    // Step3. we don't need to reload image
    reloadFlag = NO;
}

- (void)renderWithContext:(CKCRenderContext*)ctx {
    // reload the surface if is needed
    if( reloadFlag) {
        [self forceLoad];
    }

    if( scalex == 0 || scaley == 0) {
        // no need to paint
        return;
    }
    cairo_t *cr = ctx->cr;
    // save the status
    cairo_save( cr);
    cairo_translate( cr, x, y);
    cairo_scale( cr, scalex, scaley);
    cairo_rotate( cr, angle);
    // to draw this image
    cairo_set_source_surface( cr, surface, orignx, origny);
    cairo_paint( cr);
    cairo_restore( cr);
}
@end

@implementation CKCScene
- (id)init {
    if( self = [super init]) {
        objects = [NSMutableArray new];
    }
    return self;
}
- (void)addObject:(CKCSceneObject*)object {
    [objects addObject:object];
}
- (void)enumerateObjectsUsingBlock:(nonnull void (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
    [objects enumerateObjectsUsingBlock:block];
}
- (void)renderWithContext:(CKCRenderContext*)ctx {
    // enumerate every object to render each
    [objects enumerateObjectsUsingBlock:^( CKCSceneObject *obj, NSUInteger i, BOOL *stop) {
        [obj renderWithContext:ctx];
    }];
}
@end

@implementation CKCSceneObject
@synthesize x;
@synthesize y;
@synthesize angle;

- (id)init {
    if( self = [super init]) {
        x = y = angle = 0;
        scene = nil;
    }
    return self;
}
- (void)didAddToScene:(CKCScene*)scene_ {
    [scene release];
    scene = [scene_ retain];
}
- (void)didRemoveFromScene {
    [scene release];
}
- (void)renderWithContext:(CKCRenderContext*)ctx {
    // Empty
}
@end

@implementation CKCStaticObject
- (NSString*)identity {
    return identity;
}
- (void)setIdentity:(NSString*)v {
    if( v != identity) {
        if( ![v isEqualTo:identity]) {
            reloadFlag = YES;
        }
        [identity release];
        identity = [v retain];
    }
}
- (instancetype)initWithIdentity:(NSString*)identity_ {
    if( self = [self init]) {
        identity = identity_;
        reloadFlag = YES;
    }
    return self;
}
- (void)renderWithContext:(CKCRenderContext*)ctx {
    // TODO: use sprite to render
}
@end
