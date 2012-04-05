//
//  UICGRoute.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGRoute.h"

@implementation UICGRoute

@synthesize dictionaryRepresentation;
@synthesize numerOfSteps;
@synthesize steps;
@synthesize distance;
@synthesize duration;
@synthesize summaryHtml;
@synthesize startGeocode;
@synthesize endGeocode;
@synthesize endLocation;

+ (UICGRoute *)routeWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGRoute *route = [[UICGRoute alloc] initWithDictionaryRepresentation:dictionary];
	return [route autorelease];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		dictionaryRepresentation = [dictionary retain];
		NSArray *legs = [dictionaryRepresentation valueForKey:@"legs"];
		if (legs.count > 0) {
			NSDictionary *leg = [legs objectAtIndex:0];
			NSArray *stepDics = [leg objectForKey:@"steps"];
			numerOfSteps = [stepDics count];
			steps = [[NSMutableArray alloc] initWithCapacity:numerOfSteps];
			for (NSDictionary *stepDic in stepDics) {
				[(NSMutableArray *)steps addObject:[UICGStep stepWithDictionaryRepresentation:stepDic]];
			}
			
			endGeocode = [leg objectForKey:@"end_location"];
			startGeocode = [leg objectForKey:@"start_location"];
			
			distance = [leg objectForKey:@"distance"];
			duration = [leg objectForKey:@"duration"];
			CLLocationDegrees longitude = [[endGeocode objectForKey:@"lat"] doubleValue];
			CLLocationDegrees latitude  = [[endGeocode objectForKey:@"lng"] doubleValue];
			endLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
			summaryHtml = [dictionaryRepresentation objectForKey:@"summary"];
		}
       
	}
	return self;
}

- (void)dealloc {
	[dictionaryRepresentation release];
	[steps release];
	[distance release];
	[duration release];
	[summaryHtml release];
	[startGeocode release];
	[endGeocode release];
	[endLocation release];
	[super dealloc];
}

- (UICGStep *)stepAtIndex:(NSInteger)index {
	return [steps objectAtIndex:index];;
}

@end
