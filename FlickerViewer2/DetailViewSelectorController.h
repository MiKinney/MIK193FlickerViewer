//
//  DetailViewBuilderController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/19/12.
//  Copyright (c) 2012  All rights reserved.
// 
//  DetailViewBuilderController is the split view controllers detail view controller class. 
//
//  It is my own subclass of UITabBarController. Refactor : Different base class. 

//  The DetailViewBuilderController is a form of container controller
//
//  This DetailViewSelectorController class keeps in sync the photos displayed in the iPads detail view with 
//  the master, recents, favorites selection make in the master views tab bar, by switching view controllers 
//  
//  DetailViewSelectorController view controllers are of photo view, recent photo view, and vacation view controllers
//  (The iPad Storyboard graphically shows these relationships.)
//  when a user selects master, recents, or favorites, e.g. vacation tabs, in the master view
//  the master view sends a message to our implementation of UITabBarController didSelectViewController, which
//  this class use's to programmatically switch between the photo, recent or vacation views shown
//  in the detail view. 
// 
//  This is beyond the Stanford CS193P requirements. Assignments did not require this sync behavior. 
//  
//  

#import <UIKit/UIKit.h>

@class PhotoViewController;
@class VacationPhotoViewController;

// adapted from Apple example. My embedded controllers use this to show / hide popover buttons
//
@protocol SubstitutableDetailViewController
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end

//
@interface DetailViewSelectorController : UITabBarController

// access the view controllers that are managed by the embedded tab  bar controller
// 
- (PhotoViewController *) photoViewController;
- (PhotoViewController *) recentPhotoViewController; // same class type as photoViewController returns, different instance
- (VacationPhotoViewController *) vacationPhotoViewController;

@end
