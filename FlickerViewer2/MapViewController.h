//
//  MapViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/mapKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>
- (NSDictionary *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
@optional
- (MKCoordinateRegion) region;
@end


@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;

@end
