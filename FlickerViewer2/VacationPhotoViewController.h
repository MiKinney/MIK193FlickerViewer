//
//  VacationPhotoViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/19/12.
//  Copyright (c) 2012 All rights reserved.
//  Subclasses PhotoViewController becuase the super class uses dictionaries from flicker to get photo info 
//  where as VacationPhotoViewController uses photo info from CoreData
//  also in visit button behavior is different in this subclass

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "PhotoViewController.h"

@interface VacationPhotoViewController : PhotoViewController

// note photoURL is an absolute string, it's a string rather than NSURL to support Core Data
// 
- (void) setPhoto:(Photo*) photo;

@end
