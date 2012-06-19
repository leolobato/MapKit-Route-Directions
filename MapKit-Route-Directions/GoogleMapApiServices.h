#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "UICGDirectionsOptions.h"

#define GoogleMapDirectionsApiNotificationDidSucceed @"GoogleMapDirectionsApiNotificationDidSucceed"
#define GoogleMapDirectionsApiNotificationDidFailed @"GoogleMapDirectionsApiNotificationDidFailed"

@interface GoogleMapApiServices : NSObject {

}

- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options;
- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options;
- (void)cancelAll;


@end
