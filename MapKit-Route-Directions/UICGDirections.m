//
//  UICGDirections.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGDirections.h"
#import "UICGRoute.h"
#import "UICGGeocodedLocation.h"
#import "SBJson.h"

@interface UICGDirections ()

@property (nonatomic) NSInteger numberOfRoutes;

@end


static UICGDirections *sharedDirections;

@implementation UICGDirections

@synthesize status, routes, delegate, googleMapApiServices, numberOfRoutes, geocodedLocations;

+ (UICGDirections *)sharedDirections {
	if (!sharedDirections) {
		sharedDirections = [[UICGDirections alloc] init];
	}
	return sharedDirections;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter]addObserver:self 
												selector:@selector(googleMapsAPIDidGetObject:) 
													name:GoogleMapDirectionsApiNotificationDidSucceed 
												  object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self 
												selector:@selector(googleMapsAPIDidFail:) 
													name:GoogleMapDirectionsApiNotificationDidFailed
												  object:nil];
		self.googleMapApiServices = [[[GoogleMapApiServices alloc]init]autorelease];
	}
	return self;
}

- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options
{
	[self.googleMapApiServices loadWithStartPoint:startPoint
										 endPoint:endPoint 
										  options:options];
}

- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options
{
	[self.googleMapApiServices loadFromWaypoints:waypoints
										 options:options];
}

- (void)googleMapsAPIDidGetObject:(NSNotification *)notification 
{
    if (notification.object!=self.googleMapApiServices) {
        return;
    }
    
	NSDictionary *dictionary = (NSDictionary *)[[notification userInfo] objectForKey:GoogleMapDirectionsKey];
    [status release];
	status = [[dictionary objectForKey:@"status"]retain]; 
	
	NSArray *routesDict = [dictionary objectForKey:@"routes"];
    [routes release];
    routes = nil;
    if (routesDict.count>0) {
        routes = [[NSMutableArray arrayWithCapacity:[routesDict count]]retain];
        for (NSDictionary *routeDict in routesDict) {
            [(NSMutableArray *)self.routes addObject:[UICGRoute routeWithDictionaryRepresentation:routeDict]];
        }	
    }
	self.numberOfRoutes = self.routes.count;
    
    NSArray *locationsDict = [dictionary objectForKey:@"results"];
    [geocodedLocations release];
    geocodedLocations = nil;
    if (locationsDict.count>0) {
        geocodedLocations = [[NSMutableArray arrayWithCapacity:[locationsDict count]]retain];
        for (NSDictionary *locationDict in locationsDict) {
            [(NSMutableArray *)self.geocodedLocations addObject:[UICGGeocodedLocation geocodedLocationWithDictionaryRepresentation:locationDict]];
        }	
    }
	
	if ([self.delegate respondsToSelector:@selector(directionsDidUpdateDirections:)]) {
		[self.delegate directionsDidUpdateDirections:self];
	}
}

- (void)googleMapsAPIDidFail:(NSNotification *)notification 
{
    if (notification.object!=self.googleMapApiServices) {
        return;
    }
    
    NSError *error = [[notification userInfo] objectForKey:GoogleMapDirectionsErrorKey];
	NSString *message = error.localizedDescription;
	
	if ([self.delegate respondsToSelector:@selector(directions:didFailWithMessage:)]) {
		[self.delegate directions:self didFailWithMessage:message];
	}
}

- (UICGRoute *)routeAtIndex:(NSInteger)index {
	if (index >= self.routes.count) {
		return nil;
	}
	
	return [self.routes objectAtIndex:index];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	
    [geocodedLocations release];
	[googleMapApiServices release];
	[routes release];
	[status release];
	
	[super dealloc];
}

@end
