//
//  VacationTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationShortCutTableViewController.h"
#import "VacationItineraryTableViewController.h"
#import "VacationTagsTableViewController.h"
#import "Vacations.h"

@interface VacationShortCutTableViewController()

@end

@implementation VacationShortCutTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];  
}

- (void)viewDidUnload
{   
    [super viewDidUnload];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // for display purposes
    // call getSelectedVacationName each time view will appear, 
    // rather than on ViewDidLoad, because selection can change
    [self.navigationItem setTitle:[Vacations getSelectedVacationName]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{   
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for everything except upside down iPhone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


@end
