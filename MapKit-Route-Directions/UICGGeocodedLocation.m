//
//  UICGGeocodedLocation.m
//  MapDirections
//
//  Created by Leonardo Lobato on 5/16/12.
//  Copyright (c) 2012 Cliq Consulting. All rights reserved.
//

#import "UICGGeocodedLocation.h"

@implementation UICGGeocodedLocation

@synthesize coordinate, formattedAddress;

- (NSString *)description;
{
    return [NSString stringWithFormat:@"%@ %@", [super description], self.formattedAddress];
}

- (void)dealloc
{
    [formattedAddress release];
    [super dealloc];
}

+ (UICGGeocodedLocation *)geocodedLocationWithDictionaryRepresentation:(NSDictionary *)dictionary;
{
    UICGGeocodedLocation *geocodedLocation = [[[UICGGeocodedLocation alloc] initWithDictionaryRepresentation:dictionary] autorelease];
    return geocodedLocation;                                        
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;
{
    NSDictionary *geometryDict = [dictionary objectForKey:@"geometry"];
    NSDictionary *location = [geometryDict objectForKey:@"location"];
    NSNumber *latitude = [location objectForKey:@"lat"];
    NSNumber *longitude = [location objectForKey:@"lng"];
    
    if (latitude==nil || longitude==nil) {
        // Invalid coordinates, did not geocode.
        return nil;
    }        
    
    self = [super init];
    if (self) {
        formattedAddress = [[dictionary objectForKey:@"formatted_address"] copy];
        coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    }
    return self;
}


@end
