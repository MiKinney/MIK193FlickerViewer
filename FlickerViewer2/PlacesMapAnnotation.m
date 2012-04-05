//
//  PlacesMapAnnotation.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/3/12.
//  Copyright (c) 2012 All rights reserved.
//

#import "PlacesMapAnnotation.h"
#import "FlickrFetcher.h"

@implementation PlacesMapAnnotation

@synthesize place = _place;

+ (PlacesMapAnnotation *) annotationForPlace:(NSDictionary *)place
{
    PlacesMapAnnotation * annotation = [[PlacesMapAnnotation alloc] init];
    // note now that we have an object, we can set the instance variable of this object
    // from inside this class method, sweet
    annotation.place = place;
    return annotation;
}

#pragma mark MKAnnotation
// map delegate calls into us for info to update it's annotation for this object
// title is place's city name
- (NSString*) title
{
    NSString * fullPlaceName = [self.place objectForKey:(FLICKR_PLACE_NAME)];
    
    // get the city name from the full name by finding index of first delim then getting the characters
    NSCharacterSet * delimCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSRange firstDelimRange = [fullPlaceName rangeOfCharacterFromSet:delimCharacterSet]; //
    NSString * cityName = [fullPlaceName substringToIndex:firstDelimRange.location]; // assuming there is always a city
    
    return cityName;
    
}

// subtitle is location, example state, country
- (NSString *) subtitle
{
    NSString * fullPlaceName = [self.place objectForKey:(FLICKR_PLACE_NAME)];
    NSCharacterSet * delimCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSRange firstDelimRange = [fullPlaceName rangeOfCharacterFromSet:delimCharacterSet]; //
    // the city's location is everything after the first delim, 
    NSString * cityLocation = [fullPlaceName substringFromIndex:firstDelimRange.location]; 
    // but note location included the delim, so let's get rid of that
    // interesting I can assign result of an immutable string by to itself, the immutable string.. compiler doing something here under the covers ?
    cityLocation = [cityLocation stringByTrimmingCharactersInSet:delimCharacterSet];
    // and then any whitespace
    cityLocation = [cityLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return cityLocation;
    
}

// coordinates for the map
- (CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
                            
}

@end
