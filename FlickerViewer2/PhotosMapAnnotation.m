//
//  PhotosMapAnnotation.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/3/12.
//  Copyright (c) 2012  All rights reserved.
//
//  Pretty much straight from Stanford example, except for minor changes on my part
//  I did type all this in and not just copy it. 
//  

#import "PhotosMapAnnotation.h"
#import "FlickrFetcher.h"

@implementation PhotosMapAnnotation

@synthesize photo = _photo;

+(PhotosMapAnnotation *) annotationForPhoto:(NSDictionary *)photo
{
    PhotosMapAnnotation * annotation = [[PhotosMapAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}

#pragma mark MKAnnotation

- (NSString *) title
{
    NSString * photoName =  [self.photo valueForKey:FLICKR_PHOTO_TITLE];
   
    if (photoName.length > 0){
        return photoName;
    }
    
    return @"no name";
}

- (NSString *) subtitle
{
    NSString *photoDescription = [self. photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
   
    if (photoDescription.length > 0){
        return photoDescription;
    }
    
    return @"no description";
}

- (CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;   
}

@end
