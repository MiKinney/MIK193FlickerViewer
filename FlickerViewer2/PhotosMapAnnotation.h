//
//  PhotosMapAnnotation.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/3/12.
//  Copyright (c) 2012 All rights reserved.
//
//  implements MKAnnotation - how the mapView get's the title and subtitle and coordinates for the annotations
//  
//  

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PhotosMapAnnotation : NSObject <MKAnnotation>

// factory to create annotation and store the associated photo
// 
+ (PhotosMapAnnotation*) annotationForPhoto:(NSDictionary *) photo;

@property (nonatomic, strong) NSDictionary* photo;
                                             
@end
