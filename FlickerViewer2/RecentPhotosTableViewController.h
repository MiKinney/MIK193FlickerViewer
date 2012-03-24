//
//  RecentPhotosTableViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosTableViewController.h"

@interface RecentPhotosTableViewController : PhotosTableViewController

+ (void) saveRecentPhoto: (NSDictionary *) photo;

@end
