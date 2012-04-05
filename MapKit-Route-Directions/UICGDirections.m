//
//  UICGDirections.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGDirections.h"
#import "UICGRoute.h"
#import "JSON.h"

static UICGDirections *sharedDirections;

@implementation UICGDirections

@synthesize routes;
@synthesize geocodes;
@synthesize delegate;
@synthesize polyline;
@synthesize distance;
@synthesize duration;
@synthesize status;
@synthesize isInitialized;
@synthesize googleMapApiServices;

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
										  options:options.parameterized];
}

- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options
{
	[self.googleMapApiServices loadFromWaypoints:waypoints
										 options:options.parameterized];
}

- (void)googleMapsAPIDidGetObject:(NSNotification *)notification 
{
	NSDictionary *dictionary = (NSDictionary *)[notification object];
	NSArray *routeDics = [dictionary objectForKey:@"routes"];
	routes = [[NSMutableArray alloc] initWithCapacity:[routeDics count]];
	for (NSDictionary *routeDic in routeDics) {
		[(NSMutableArray *)routes addObject:[UICGRoute routeWithDictionaryRepresentation:routeDic]];
		self.polyline = [UICGPolyline polylineWithDictionaryRepresentation:[routeDic objectForKey:@"overview_polyline"]];
	}
	self.geocodes = [dictionary objectForKey:@"geocodes"];
	self.distance = [dictionary objectForKey:@"distance"];
	self.duration = [dictionary objectForKey:@"duration"];
	self.status = [dictionary objectForKey:@"status"];
	
	if ([self.delegate respondsToSelector:@selector(directionsDidUpdateDirections:)]) {
		[self.delegate directionsDidUpdateDirections:self];
	}
}

- (void)googleMapsAPIDidFail:(NSNotification *)notification 
{
	NSString *message = (NSString *)[notification object]; // TODO check error case
	
	if ([self.delegate respondsToSelector:@selector(directions:didFailWithMessage:)]) {
		[self.delegate directions:self didFailWithMessage:message];
	}
}

- (NSInteger)numberOfRoutes {
	return [routes count];
}

- (UICGRoute *)routeAtIndex:(NSInteger)index {
	return [routes objectAtIndex:index];
}

- (NSInteger)numberOfGeocodes {
	return [geocodes count];
}

- (NSDictionary *)geocodeAtIndex:(NSInteger)index {
	return [geocodes objectAtIndex:index];;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	
	[googleMapApiServices release];
	[routes release];
	[geocodes release];
	[polyline release];
	[distance release];
	[duration release];
	[status release];
	
	[super dealloc];
}

@end
