//
//  UICGDirections.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICGDirectionsOptions.h"
#import "UICGRoute.h"
#import "UICGPolyline.h"
#import "GoogleMapApiServices.h"

@class UICGDirections;

@protocol UICGDirectionsDelegate<NSObject>
@optional
- (void)directionsDidUpdateDirections:(UICGDirections *)directions;
- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message;
@end

@interface UICGDirections : NSObject {

}

@property (nonatomic, assign) id<UICGDirectionsDelegate> delegate;
@property (nonatomic, retain) NSArray *routes;
@property (nonatomic, retain) NSArray *geocodes;
@property (nonatomic, retain) UICGPolyline *polyline;
@property (nonatomic, retain) NSDictionary *distance;
@property (nonatomic, retain) NSDictionary *duration;
@property (nonatomic, retain) NSDictionary *status;
@property (nonatomic, readonly) BOOL isInitialized;

+ (UICGDirections *)sharedDirections;
- (id)init;

@property (nonatomic, retain) GoogleMapApiServices *googleMapApiServices;

@property (nonatomic, readonly) NSInteger numberOfRoutes;
- (UICGRoute *)routeAtIndex:(NSInteger)index;
@property (nonatomic, readonly) NSInteger numberOfGeocodes;
- (NSDictionary *)geocodeAtIndex:(NSInteger)index;

- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options;
- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options;

@end
