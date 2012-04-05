//
//  PhotosTableViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/21/12.
//  Copyright (c) 2012 All rights reserved.
//  
//  This class grew in complexity as I need more and more assignments so want to refactor
//  
//  PhotosTableViewController should just show a table of all photos for a selected place
//  To do that, it needs the place, then fetches, over the net, photo info (not the images) for the place
//  Then when user touches a table entry, the select photo info is sent to photoViewController for display
//
//  
//  However, because the PhotosTableViewController has the dataModel
//  the MapViewController is coupled into this controller, which is very limiting   
//  I have to segue from this PhotosTableViewController to show a Map of all the photos in one place,
//  This is very limiting to user navigation and what I can do with U.I.
//  Plus the MapViewController uses delegates to get MapAnnotation info from this controller
//
//  Refactor out datamodel PhotosTableViewController and break connection between the two controllers
//  Refactor - also look at container controller for photo controller and map controller

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"

@protocol PhotosDataSourceDelegate 

- (NSDictionary *) place;

@end

@interface PhotosTableViewController : UITableViewController 
@property (strong, nonatomic) NSArray *placePhotos;
@property (strong, nonatomic) NSDictionary *selectedPhoto;

@property (nonatomic,weak) id <PhotosDataSourceDelegate> dataSourceDelegate;

@end
