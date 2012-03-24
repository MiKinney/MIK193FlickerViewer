//
//  VacationPhotoViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "PhotoViewController.h"

@interface VacationPhotoViewController : PhotoViewController

// note photoURL is an absolute string, it's a string rather than NSURL to support Core Data
// 
- (void) setPhoto:(Photo*) photo;

@end
