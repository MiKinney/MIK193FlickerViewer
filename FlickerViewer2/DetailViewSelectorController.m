//
//  DetailViewBuilderController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/19/12.
//  Copyright (c) 2012 All rights reserved.
//  See header for class description

#import "DetailViewSelectorController.h"

@interface DetailViewSelectorController() <UITabBarControllerDelegate>

@property (weak, nonatomic) UIPopoverController *popoverController;    
@property (weak, nonatomic) UIBarButtonItem *rootPopoverButtonItem;

@end

@implementation DetailViewSelectorController

@synthesize popoverController = popoverController;
@synthesize rootPopoverButtonItem = _rootPopoverButtonItem;

// these must match the splitview controllers master view tabbarcontroller index as shown in Storyboard 
// changing  the tab order in the Storyboard during development, requires changing these indexes
#define PHOTO_CONTROLLER_INDEX 0 // Top Rated tab
#define RECENT_PHOTO_CONTROLLER_INDEX 1  // Recents tab
#define VACATION_PHOTO_CONTROLLER_INDEX 2 // vacation tab
 
// external access to our view controllers
// 
// these should each exist when called, as long as view is displayed at least once
// the views will display when didSelectViewController executes, when user touches a tab
//
// controller for top rated
- (PhotoViewController *) photoViewController {    
    return (PhotoViewController *) [self.viewControllers objectAtIndex:PHOTO_CONTROLLER_INDEX];    
}

// controller for recents, ame class type as above , different instance
- (PhotoViewController *) recentPhotoViewController {    
    return (PhotoViewController *) [self.viewControllers objectAtIndex:RECENT_PHOTO_CONTROLLER_INDEX];    
}

// controller for vacations
- (VacationPhotoViewController *) vacationPhotoViewController {
    return (VacationPhotoViewController *) [self.viewControllers objectAtIndex:VACATION_PHOTO_CONTROLLER_INDEX];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // want to know which view (Master, Recents, Vacation) the user selected
    // so we use the UITabBarControllerDelegate embedded in the split view controller's master view
    UITabBarController * masterViewTabBarController = [self.splitViewController.viewControllers objectAtIndex:0];
    masterViewTabBarController.delegate = self;
    
    // need to select something in this tab bar controller initially, 
    // cannot wait for  didSelectViewController message below to set it, because the split view controller calls it's delegates first, and we'd crash
    self.selectedIndex = PHOTO_CONTROLLER_INDEX; 
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark UITabBarControllerDelegate 

// the UITabBarControllerDelegate delegate is set in this class's viewDidLoad messsage 
//
- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    // find which tab bar button was selected by user in the Master view tab bar controller,
	// change the displayed controller
    // setting our DetailViewSelectorController's selectedIndex to tabBarController.selectedIndex keeps the detail views in sync with the selected view in the master view tab bar
    // 
    self.selectedIndex = tabBarController.selectedIndex; // we change detail views when the master view's tab bar buttons are touched
    
    // Configure the displayed controllers popover button (after the view has been displayed and its toolbar has been created).
    if (self.rootPopoverButtonItem != nil) {
        // have to remove the existing button (if any) from the toolbar first, otherwise as you keep touching a tab controller button in the master view, the button will walk across the toolbar !
        [[self.viewControllers objectAtIndex:self.selectedIndex] invalidateRootPopoverButtonItem:self.rootPopoverButtonItem];
        [[self.viewControllers objectAtIndex:self.selectedIndex] showRootPopoverButtonItem:self.rootPopoverButtonItem];
    }
    
}

#pragma mark UISplitViewControllerDelegate

// the UISplitViewControllerDelegate delegate is set in MIPAppDelegate.m's 
// control display of popover button when iPad is rotated between portrait and landscape modes
- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
    // apple example code, adapted for my usage
    // Keep references to the popover controller and the popover button, and tell our currently selected view controller to show the button.
    barButtonItem.title = @"Photos";
    self.popoverController = pc;
    self.rootPopoverButtonItem = barButtonItem;
    // the button is actually shown / hidden by our delegate implemented in the currently displayed controller
    // 
    id controller = [self.viewControllers objectAtIndex:self.selectedIndex]; 
    if(controller) {
        [controller showRootPopoverButtonItem:self.rootPopoverButtonItem];
    }
}

// control display of popover button when iPad is rotated between portrait and landscape modes

- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Nil out references to the popover controller and the popover button, and tell our currently selected view controller to hide the button.
    // the button is actually shown / hidden by our delegate implemented in the currently displayed controller
    // 
    id controller = [self.viewControllers objectAtIndex:self.selectedIndex];
    if(controller) {
        [controller invalidateRootPopoverButtonItem:self.rootPopoverButtonItem];       
        self.popoverController = nil;
        self.rootPopoverButtonItem = nil; 
    }
}


#pragma mark other

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
