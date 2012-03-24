//
//  PhotosMapAnnotation.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PhotosMapAnnotation : NSObject <MKAnnotation>

+ (PhotosMapAnnotation*) annotationForPhoto:(NSDictionary *) photo;

@property (nonatomic, strong) NSDictionary* photo;
                                             
@end
