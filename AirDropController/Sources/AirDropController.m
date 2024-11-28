//
//  AirDropController.m
//  AirDropController
//
//  Created by Danil Korotenko on 11/28/24.
//

#import "AirDropController.h"

@implementation AirDropController

+ (AirDropController *)shared
{
    static AirDropController *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        shared = [[AirDropController alloc] init];
    });
    return shared;
}

- (AirDropState)state
{
    return AirDropStateOff;
}

- (void)setState:(AirDropState)state
{

}

#pragma mark -

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

@end
