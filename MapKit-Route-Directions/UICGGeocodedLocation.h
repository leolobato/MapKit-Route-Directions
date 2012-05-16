//
//  UICGGeocodedLocation.h
//  MapDirections
//
//  Created by Leonardo Lobato on 5/16/12.
//  Copyright (c) 2012 Cliq Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UICGGeocodedLocation : NSObject {
    
}

@property (nonatomic, readonly) NSString *formattedAddress;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (UICGGeocodedLocation *)geocodedLocationWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

@end
