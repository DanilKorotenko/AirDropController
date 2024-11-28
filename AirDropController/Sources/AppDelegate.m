//
//  AppDelegate.m
//  AirDropController
//
//  Created by Danil Korotenko on 11/28/24.
//

#import "AppDelegate.h"
#import "AirDropController.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSSegmentedControl *airDropStateControl;

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

- (void)awakeFromNib
{
    switch ([AirDropController shared].state)
    {
        case AirDropStateOff:
        {
            self.airDropStateControl.selectedSegment = 0;
            break;
        }
        case AirDropStateContactsOnly:
        {
            self.airDropStateControl.selectedSegment = 1;
            break;
        }
        case AirDropStateEveryone:
        {
            self.airDropStateControl.selectedSegment = 2;
            break;
        }
    }
}

#pragma mark -

- (IBAction)airDropStateControlDidClick:(id)sender
{
    switch (self.airDropStateControl.selectedSegment)
    {
        case 0: // Off
        {
            [AirDropController shared].state = AirDropStateOff;
            break;
        }
        case 1: // Contacts Only
        {
            [AirDropController shared].state = AirDropStateContactsOnly;
            break;
        }
        case 2: // Everyone
        {
            [AirDropController shared].state = AirDropStateEveryone;
            break;
        }
        default:
            break;
    }
}

#pragma mark -

@end
