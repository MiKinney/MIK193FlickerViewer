//
//  PlacesMapAnnotation.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/3/12.
//  Copyright (c) 2012 . All rights reserved.
//
// basically a wrapper 'place' that map uses to get annotation display info

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PlacesMapAnnotation : NSObject <MKAnnotation>

+ (PlacesMapAnnotation*) annotationForPlace:(NSDictionary*) place;

@property (strong, nonatomic) NSDictionary * place;

@end
