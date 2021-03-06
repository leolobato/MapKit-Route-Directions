//
//  UICRouteAnnotation.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum UICRouteAnnotationType {
	UICRouteAnnotationTypeStart,
	UICRouteAnnotationTypeEnd,
	UICRouteAnnotationTypeWayPoint,
} UICRouteAnnotationType;

@interface UICRouteAnnotation : NSObject<MKAnnotation,NSCoding> {
	
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic) UICRouteAnnotationType annotationType;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord 
				   title:(NSString *)aTitle 
				subtitle:(NSString *)aSubtitle
		  annotationType:(UICRouteAnnotationType)type;

@end
