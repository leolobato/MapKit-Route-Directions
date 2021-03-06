#import "GoogleMapApiServices.h"
#import "SBJson.h"

@interface GoogleMapApiServices ()

@property (nonatomic, readonly) ASINetworkQueue *networkQueue;
- (ASIHTTPRequest *)requestWithUrl:(NSString *)url;
- (void)parseDirections:(ASIHTTPRequest *)request;

@end

@implementation GoogleMapApiServices

@synthesize networkQueue;

#pragma mark -
#pragma mark Requests

#define GOOGLE_DIRECTIONS_PATH @"http://maps.googleapis.com/maps/api/directions/json?"
#define GOOGLE_GEOCODE_PATH @"http://maps.googleapis.com/maps/api/geocode/json?"

- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options
{
    // TODO: use options string
//    NSString *optionsString = [options parameterized];
    
	NSString *url = [NSString stringWithFormat:@"%@origin=%@&destination=%@&sensor=false",
					 GOOGLE_DIRECTIONS_PATH,
					 startPoint, 
					 endPoint
//					 (optionsString.length > 0) ? [NSString stringWithFormat:@"&%@", optionsString] : @""
					 ];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	ASIHTTPRequest *request = [self requestWithUrl:url];
	request.delegate = self;
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
}

- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options
{
    NSString *url = nil;
    
    // Escape waypoints to be used as parameter
    NSMutableArray *escapedWaypoints = [NSMutableArray arrayWithCapacity:waypoints.count];
    for (NSString *waypoint in waypoints) {
        NSString *escapedWaypoint = [self escapedString:waypoint];
        [escapedWaypoints addObject:escapedWaypoint];
    }
    
    if (waypoints.count==1) {
        url = [NSString stringWithFormat:@"%@address=%@&sensor=false", 
               GOOGLE_GEOCODE_PATH,
               [escapedWaypoints firstObject]
               ];
    } else if (waypoints.count>=2) {
        // TODO: use options string
//        NSString *optionsString = [options parameterized];
        NSString *origin = [escapedWaypoints firstObject];
        NSString *destination = [escapedWaypoints lastObject];
        [escapedWaypoints removeLastObject];
        [escapedWaypoints removeObjectAtIndex:0];
        
        NSString *params = nil;
        if (escapedWaypoints.count>0) {
            params = [NSString stringWithFormat:@"origin=%@&destination=%@&waypoints=%@%@&sensor=false",
                      origin,
                      destination,
                      (options.optimizeWaypoints ? @"optimize:true|" : @""),
                      [escapedWaypoints componentsJoinedByString:@"|"]
                      ];
        } else {
            params = [NSString stringWithFormat:@"origin=%@&destination=%@&sensor=false",
                      origin,
                      destination
                      ];
        }
        
        url = [NSString stringWithFormat:@"%@%@",
               GOOGLE_DIRECTIONS_PATH,
               [params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    if (url) {
        ASIHTTPRequest *request = [self requestWithUrl:url];
        request.delegate = self;
        
        [self.networkQueue addOperation:request];
        [self.networkQueue go];
    }
}

- (NSString *)escapedString:(NSString *)string;
{
    // API has a URL limit of 2000 chars after encoded.
    NSString *escapedString = [string stringByReplacingOccurrencesOfString:@", " withString:@","];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    escapedString = [escapedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return escapedString;
}

#pragma mark -
#pragma mark Parsing

- (void)parseDirections:(ASIHTTPRequest *)request
{
	NSString *responseString = [request responseString];
	if ([responseString length] != 0 && request.responseStatusCode == 200)  {
		NSError *error = nil;
		
		SBJsonParser *json = [[[SBJsonParser alloc]init] autorelease];
		
		
		NSDictionary *directionsDict = (NSDictionary *)[json objectWithString:responseString error:&error];
		if (!error && directionsDict && ![directionsDict isKindOfClass:[NSNull class]]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:directionsDict forKey:GoogleMapDirectionsKey];
			[[NSNotificationCenter defaultCenter] postNotificationName:GoogleMapDirectionsApiNotificationDidSucceed
                                                                object:self
                                                              userInfo:userInfo];
		} else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:responseString forKey:GoogleMapDirectionsKey];
			[[NSNotificationCenter defaultCenter] postNotificationName:GoogleMapDirectionsApiNotificationDidFailed
                                                                object:self
                                                              userInfo:userInfo];
		}
	} else {
        NSDictionary *userInfo = nil;
        if (request.error) {
            userInfo = [NSDictionary dictionaryWithObject:request.error forKey:GoogleMapDirectionsErrorKey];
        }
		[[NSNotificationCenter defaultCenter] postNotificationName:GoogleMapDirectionsApiNotificationDidFailed
                                                            object:self
                                                          userInfo:userInfo];
	}
	
}

#pragma mark -
#pragma mark Boilerplate

- (ASIHTTPRequest *)requestWithUrl:(NSString *)url
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 1;
	request.timeOutSeconds = 45.0;
	
	request.allowCompressedResponse = TRUE;
	
	return request;
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate + Network Queue

- (ASINetworkQueue *)networkQueue
{
	if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];
		if ([self respondsToSelector:@selector(fetchCompleted:)]) {
			[networkQueue setRequestDidFinishSelector:@selector(fetchCompleted:)];
		}
		if ([self respondsToSelector:@selector(fetchFailed:)]) {
			[networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
		}
		
		[networkQueue setDelegate:self];
	}
	
	return networkQueue;
}

- (void)fetchCompleted:(ASIHTTPRequest *)request
{
	[self parseDirections:request];
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = nil;
    if (request.error) {
        userInfo = [NSDictionary dictionaryWithObject:request.error forKey:GoogleMapDirectionsErrorKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:GoogleMapDirectionsApiNotificationDidFailed
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)cancelAll;
{
    for (ASIHTTPRequest *request in [networkQueue operations]) {
        [request cancel];
    }
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
    [networkQueue setDelegate:nil];
    for (ASIHTTPRequest *request in [networkQueue operations]) {
        [request setDelegate:nil];
        [request cancel];
    }
	[networkQueue release];
	
    [super dealloc];
}


@end
