//
//  DetailViewBuilderController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  This class keeps in synce the photos displayed in the iPads detail view with the 
//  master, recents, favorites selection make in the master views tab bar
//  This is the split view controllers detail view class
//  This is a subclass of UITabBarController
//  It's view controllers are of photo view, recent photo view, and vacation view controllers
//  This class is also the delegate of the split view controllers master view tab bar controller
//  when a user selects master, recents, for favorites, e.g. vacation tabs, in the master view
//  the master view sends a message to our implementation of didSelectViewController, which
//  this class use's to programmatically switch between the photo, recent or vacation views shown
//  in the detail view
//  
//  

#import <UIKit/UIKit.h>

@class PhotoViewController;
@class VacationPhotoViewController;

// example directly from apple
@protocol SubstitutableDetailViewController
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end

// my stuff
@interface DetailViewSelectorController : UITabBarController

// access the view controllers that are managed by the embedded tab  bar controller
// 
- (PhotoViewController *) photoViewController;
- (PhotoViewController *) recentPhotoViewController; // same class type as photoViewController returns, different instance
- (VacationPhotoViewController *) vacationPhotoViewController;

@end
