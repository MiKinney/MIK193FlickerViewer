//
//  AllPhotosForOneTagTableViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  display all photo names associated with tagName in vacationName
//  allow user to select photo to see it displayed 

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface AllPhotosForOneTagTableViewController : CoreDataTableViewController

@property (strong, nonatomic) NSString * tagName;

@end
