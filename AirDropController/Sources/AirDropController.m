//
//  AirDropController.m
//  AirDropController
//
//  Created by Danil Korotenko on 11/28/24.
//

#import "AirDropController.h"

@interface AirDropController ()

@property (strong) dispatch_source_t source;
@property (strong) dispatch_queue_t queue;

@property (assign) int fileDescriptor;

@end

@implementation AirDropController

@synthesize state = _state;
@synthesize enabled = _enabled;

+ (AirDropController *)shared
{
    static AirDropController *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        shared = [[AirDropController alloc] init];
        [shared startMonitoringSharingDPreferences];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.queue = dispatch_queue_create("AirDropController.Queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    if (self.source)
    {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }

    if (self.fileDescriptor)
    {
        close(self.fileDescriptor);
    }
}

#pragma mark -

- (AirDropState)state
{
    return [AirDropController stringToState:[self sharingDDiscoverableMode]];
}

- (void)setState:(AirDropState)aState
{
    _state = aState;
    [self syncroniseAirDropState];
}

- (BOOL)enabled
{
    return [self networkBrowserDisableAirDrop];
}

- (void)setEnabled:(BOOL)anEnabled
{
    _enabled = anEnabled;
    [self synchroniseEnabled];
}

#pragma mark -

- (void)startMonitoringSharingDPreferences
{
    NSString *sharingDPreferencesFile = [NSString
        stringWithFormat:@"%@/Library/Preferences/com.apple.sharingd.plist", NSHomeDirectory()];

    self.fileDescriptor = open(sharingDPreferencesFile.UTF8String, O_EVTONLY);
    if (self.fileDescriptor == -1)
    {
        return;
    }

    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, self.fileDescriptor,
        DISPATCH_VNODE_DELETE |
        DISPATCH_VNODE_WRITE |
        DISPATCH_VNODE_EXTEND |
        DISPATCH_VNODE_ATTRIB |
        DISPATCH_VNODE_LINK |
        DISPATCH_VNODE_RENAME |
        DISPATCH_VNODE_REVOKE |
        DISPATCH_VNODE_FUNLOCK,
        self.queue);

    if (self.source)
    {
        // Install the event handler to process the name change
        dispatch_source_set_event_handler(self.source,
        ^{
            dispatch_source_vnode_flags_t event = dispatch_source_get_data(self.source);

            if (((event | DISPATCH_VNODE_DELETE) == DISPATCH_VNODE_DELETE) ||
                ((event | DISPATCH_VNODE_RENAME) == DISPATCH_VNODE_RENAME) ||
                ((event | DISPATCH_VNODE_REVOKE) == DISPATCH_VNODE_REVOKE))
            {
                // Close the existing file descriptor
                close(self.fileDescriptor);

                // Stop the current dispatch source
                dispatch_source_cancel(self.source);
                self.source = nil;

                if (self.delegate)
                {
                    [self.delegate airDropStateDidUpdate];
                }

                [self startMonitoringSharingDPreferences];
            }
            else
            {
                if (self.delegate)
                {
                    [self.delegate airDropStateDidUpdate];
                }
            }
        });

        // Install a cancellation handler to free the descriptor
        // and the stored string.
        dispatch_source_set_cancel_handler(self.source,
        ^{
            close(self.fileDescriptor);
            [self startMonitoringSharingDPreferences];
        });
 
        // Start processing events.
        dispatch_resume(self.source);
    }
    else
    {
        close(self.fileDescriptor);
    }
}

- (void)syncroniseAirDropState
{
    NSUserDefaults *sharingDPreferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.sharingd"];
    NSString *stateString = [AirDropController stateToString:_state];

    [sharingDPreferences setObject:stateString forKey:@"DiscoverableMode"];
    [sharingDPreferences synchronize];

    [self restartSharingd];
}

- (void)restartSharingd
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/killall"];

    [task setArguments:@[@"sharingd"]];

    [task launch];
    [task waitUntilExit];
}

- (NSString *)sharingDDiscoverableMode
{
    NSUserDefaults *sharingDPreferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.sharingd"];
    NSString *result = [sharingDPreferences stringForKey:@"DiscoverableMode"];
    return result;
}

+ (NSString *)stateToString:(AirDropState)aState
{
    switch (aState)
    {
        case AirDropStateOff:           { return @"Off"; }
        case AirDropStateContactsOnly:  { return @"Contacts Only";}
        case AirDropStateEveryone:      { return @"Everyone";}
    }
    return nil;
}

+ (AirDropState)stringToState:(NSString *)aStateString
{
    if ([aStateString isEqualToString:@"Contacts Only"])
    {
        return AirDropStateContactsOnly;
    }
    else if ([aStateString isEqualToString:@"Everyone"])
    {
        return AirDropStateEveryone;
    }
    return AirDropStateOff;
}

#pragma mark -

- (BOOL)networkBrowserDisableAirDrop
{
    NSUserDefaults *preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.NetworkBrowser"];
    BOOL result = ![preferences boolForKey:@"DisableAirDrop"];
    return result;
}

- (void)restartFinder
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/killall"];

    [task setArguments:@[@"Finder"]];

    [task launch];
    [task waitUntilExit];
}

- (void)synchroniseEnabled
{
    NSUserDefaults *preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.NetworkBrowser"];

    [preferences setBool:!_enabled forKey:@"DisableAirDrop"];
    [preferences synchronize];

    [self restartFinder];
    [self restartSharingd];
}

@end
