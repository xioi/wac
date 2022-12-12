#ifdef __APPLE__
#   import <AppKit/AppKit.h>
#endif

#import "i18n.h"

void setup_cocoa() { // test menu
#ifdef __APPLE__
    NSMenuItem* menuBarItem = [[NSMenuItem alloc]

                        initWithTitle:@( _( "Custom")) action:NULL keyEquivalent:@""];
    // title localization is omitted for compactness
    NSMenu* newMenu = [[NSMenu alloc] initWithTitle:@"Custom"];
    [menuBarItem setSubmenu:newMenu];
    [[NSApp mainMenu] insertItem:menuBarItem atIndex:2];
    NSMenuItem* newItem;

    newItem = [[NSMenuItem alloc]

                initWithTitle:@( _( "Custom Item 1"))

                action:@selector(menuItem1Action:)

                keyEquivalent:@""];
    //[newItem setView: myView1];
    //[newItem setTarget:self];
    [newMenu addItem:newItem];
    newItem = [[NSMenuItem alloc]
                initWithTitle:@"Custom Item 2"

                action:@selector(menuItem2Action:)

                keyEquivalent:@""];

    //[newItem setView: myView2];

    //[newItem setTarget:self];

    [newMenu addItem:newItem];
#endif
}