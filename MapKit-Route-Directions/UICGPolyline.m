//
//  UICGPolyline.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGPolyline.h"

@implementation UICGPolyline

@synthesize dictionaryRepresentation;
@synthesize routePoints;
@synthesize vertexCount;
@synthesize length;

+ (UICGPolyline *)polylineWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGPolyline *polyline = [[UICGPolyline alloc] initWithDictionaryRepresentation:dictionary];
	return [polyline autorelease];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		dictionaryRepresentation = [dictionary retain];
		
		//NSString *levels = [dictionaryRepresentation valueForKey:@"levels"];
		NSString *points = [dictionaryRepresentation valueForKey:@"points"];
		
		routePoints = [NSMutableArray arrayWithCapacity:0];
		
		// inspired by http://iphonegeeksworld.wordpress.com/2010/09/08/drawing-routes-onto-mkmapview-using-unofficial-google-maps-directions-api/
		NSInteger len = [points length];
		NSInteger index = 0;
		NSInteger lat=0;
		NSInteger lng=0;
		while (index < len) {
			NSInteger b;
			NSInteger shift = 0;
			NSInteger result = 0;
			do {
				b = [points characterAtIndex:index++] - 63;
				result |= (b & 0x1f) << shift;
				shift += 5;
			} while (b >= 0x20);
			NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
			lat += dlat;
			shift = 0;
			result = 0;
			do {
				b = [points characterAtIndex:index++] - 63;
				result |= (b & 0x1f) << shift;
				shift += 5;
			} while (b >= 0x20);
			NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
			lng += dlng;
			NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
			NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
			printf("[%f,", [latitude doubleValue]);
			printf("%f]", [longitude doubleValue]);
			CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
			[routePoints addObject:loc];
		}
        
        vertexCount = [routePoints count];
	}
	return self;
}

- (void)dealloc {
	[dictionaryRepresentation release];
	[super dealloc];
}

- (CLLocation *)vertexAtIndex:(NSInteger)index {
	return [routePoints objectAtIndex:index];
}

@end
