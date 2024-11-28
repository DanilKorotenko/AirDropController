//
//  AppDelegate.m
//  AirDropController
//
//  Created by Danil Korotenko on 11/28/24.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark -

- (IBAction)airDropStateControlDidClick:(id)sender
{
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    switch (segmentedControl.selectedSegment)
    {
        case 0: // Off
        {
            break;
        }
        case 1: // Contacts Only
        {
            break;
        }
        case 2: // Everyone
        {
            break;
        }
        default:
            break;
    }
}

#pragma mark -

@end
