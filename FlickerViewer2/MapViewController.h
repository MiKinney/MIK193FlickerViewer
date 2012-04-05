//
//  MapViewController.h
//  FlickerViewer
//
//  Created by Michael Kinney on 3/2/12.
//  Copyright (c) 2012  All rights reserved.
//  
//  Displays pin annotations for places or photos
//  photo annotations include thumbnails
//  Seques when user touches pin 
//
//  Must have an object that implements MapViewControllerDelegate
//
//  Refactor - so we can seque directly to photo map from places map
//			   this returns refactor of data model in places table view controller 
//
//  Refactor - map and photo / place controllers are too tightly coupled. 
//

#import <UIKit/UIKit.h>
#import <MapKit/mapKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

// dictionary has keys 'photo' and 'image' 
// where value for 'photo' is same as in annotation 
// and value for 'image' is displayable image
// since map view recylces pins using dictionary to keep photo and image in sync, 
- (NSDictionary *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
@optional
- (MKCoordinateRegion) region;
@end


@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;

@end
