//
//  AirDropController.h
//  AirDropController
//
//  Created by Danil Korotenko on 11/28/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AirDropState)
{
    AirDropStateOff = 0,
    AirDropStateContactsOnly,
    AirDropStateEveryone,
};

@interface AirDropController : NSObject

+ (AirDropController *)shared;

@property(readwrite) AirDropState state;

@end

NS_ASSUME_NONNULL_END
