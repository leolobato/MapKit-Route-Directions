//
//  UICRouteAnnotation.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICRouteAnnotation.h"

@implementation UICRouteAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize annotationType;

- (NSString *)description;
{
    return [NSString stringWithFormat:@"%@ %@ [%@]", [super description], self.title, self.subtitle];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord 
				   title:(NSString *)aTitle 
				subtitle:(NSString *)aSubtitle
		  annotationType:(UICRouteAnnotationType)type {
	self = [super init];
	if (self != nil) {
		coordinate = coord;
		title = [aTitle retain];
		subtitle = [aSubtitle retain];
		annotationType = type;
	}
	return self;
}

- (void)dealloc {
	[subtitle release];
	[title release];	
	
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.coordinate.latitude forKey:@"coordinate_latitude"];
    [encoder encodeDouble:self.coordinate.longitude forKey:@"coordinate_longitude"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.subtitle forKey:@"subtitle"];
    [encoder encodeInteger:(NSInteger)self.annotationType forKey:@"annotationType"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        double latitude = [decoder decodeDoubleForKey:@"coordinate_latitude"];
        double longitude = [decoder decodeDoubleForKey:@"coordinate_longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        title = [[decoder decodeObjectForKey:@"title"] retain];
        subtitle = [[decoder decodeObjectForKey:@"title"] retain];
        self.annotationType = (UICRouteAnnotationType)[decoder decodeIntegerForKey:@"annotationType"];
    }
    return self;
}

@end
