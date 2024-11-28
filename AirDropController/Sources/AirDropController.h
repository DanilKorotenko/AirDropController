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

@protocol AirDropControllerDelegate <NSObject>

@required
- (void)airDropStateDidUpdate;

@end

@interface AirDropController : NSObject

+ (AirDropController *)shared;

@property(readwrite) AirDropState state;
@property(readwrite) BOOL enabled;

@property(weak) id<AirDropControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
