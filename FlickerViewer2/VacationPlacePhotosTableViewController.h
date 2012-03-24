//
//  VacationPlacesTableViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface VacationPlacePhotosTableViewController : CoreDataTableViewController

// note this is a vacationPlace is different from vacationName
// managed documents defined by vacationName may have multiple vacationPlaces
@property (strong, nonatomic) NSString * vacationPlace;

@end
