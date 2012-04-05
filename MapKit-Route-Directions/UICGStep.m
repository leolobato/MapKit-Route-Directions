//
//  UICGStep.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGStep.h"

@interface UICGStep ()

@property (nonatomic, retain) NSString *travelMode;
@property (nonatomic, retain) CLLocation *startLocation;
@property (nonatomic, retain) CLLocation *endLocation;
@property (nonatomic, retain) UICGPolyline *polyline;
@property (nonatomic, retain) NSDictionary *duration;
@property (nonatomic, retain) NSString *htmlInstructions;
@property (nonatomic, retain) NSDictionary *distance;

@end


@implementation UICGStep

@synthesize travelMode, startLocation, endLocation, polyline, duration;
@synthesize htmlInstructions, distance;

+ (UICGStep *)stepWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGStep *step = [[UICGStep alloc] initWithDictionaryRepresentation:dictionary];
	return [step autorelease];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		self.travelMode = [dictionary objectForKey:@"travel_mode"];
		NSDictionary *startLocationDict = [dictionary valueForKeyPath:@"bounds.southwest"];
		CLLocationDegrees longitudeS = [[startLocationDict objectForKey:@"lat"] doubleValue];
		CLLocationDegrees latitudeS  = [[startLocationDict objectForKey:@"lng"] doubleValue];							 
		self.startLocation = [[[CLLocation alloc] initWithLatitude:latitudeS longitude:longitudeS]autorelease];
		NSDictionary *endLocationDict = [dictionary valueForKeyPath:@"bounds.northeast"];
		CLLocationDegrees longitudeE = [[endLocationDict objectForKey:@"lat"] doubleValue];
		CLLocationDegrees latitudeE  = [[endLocationDict objectForKey:@"lng"] doubleValue];							 
		self.endLocation = [[[CLLocation alloc] initWithLatitude:latitudeE longitude:longitudeE]autorelease];
		self.polyline = [UICGPolyline polylineWithDictionaryRepresentation:[dictionary objectForKey:@"polyline"]];
		self.duration = [dictionary objectForKey:@"duration"];
		self.htmlInstructions = [dictionary objectForKey:@"html_instructions"];
		self.distance = [dictionary objectForKey:@"distance"];
	}
	return self;
}

- (void)dealloc {
	[travelMode release];
	[startLocation release];
	[endLocation release];
	[polyline release];
	[duration release];
	[htmlInstructions release];
	[distance release];
	
	[super dealloc];
}

@end
