//
//  MIKAppDelegate.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewSelectorController.h"

@interface MIKAppDelegate : UIResponder <UIApplicationDelegate>

// debug only - (void) postLaunch;

@property (strong, nonatomic) UIWindow *window;

// returns valid object when on iPad, otherwise nil
// table controllers for photos, recents, vacations,  use this to access the 
// the corresponding detail view controller contained in the DetailViewSelectorController
- (DetailViewSelectorController *) detailViewSelectorController;

@end
