//
//  RecentPhotosTableViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/28/12.
//  Copyright (c) 2012 All rights reserved.
//
//  Persists and retrieves recent photo dictionaries
//  Overrides UITableView didSelectRowAtIndexPath to use stored photo dictionaries for table display
//  #defines max number of saved photos

#import "PhotosTableViewController.h"

@interface RecentPhotosTableViewController : PhotosTableViewController

+ (void) saveRecentPhoto: (NSDictionary *) photo;

@end
