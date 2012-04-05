//
//  PlacesTableViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/17/12.
//  Copyright (c) 2012 All rights reserved.
//
//  Makes a request to flicker for top rated places, using GCD and blocks
//  top rated places displayed in a table view
//  also supports segueing to a map view and provides data for map view
//
//	The following is problem is just like the problem in PhotosTableViewController
//  
//  However, because the PlacesTableViewController has the dataModel
//  the MapViewController is coupled into this controller, which is very limiting   
//  to user navigation and what I can do with U.I.
//  Plus the MapViewController uses delegates to get MapAnnotation info from this controller
//
//  Refactor out datamodel PlacesTableViewController and break connection between the two controllers
//  Refactor - also look at container controller for places controller and map controller


#import <UIKit/UIKit.h>
#import "FlickrFetcher.h"


@interface PlacesTableViewController : UITableViewController


@end
