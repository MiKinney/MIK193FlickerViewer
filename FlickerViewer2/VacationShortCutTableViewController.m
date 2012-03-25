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

// it's possible this controller loaded and displayed before the vacation was open
// call this method to reflect any changes
-(void) vacationOpenedUpdate {
    
    VacationDocument * document = [Vacations getOpenManagedVacation];
    if(document) {
        [self.navigationItem setTitle:document.vacationName];
        // also enable ability to interact with table view
        self.tableView.allowsSelection = YES;
    } else {
        // not open, don't display misleading titles
        [self.navigationItem setTitle:@""];
        // also disable ability to interact with table view
        self.tableView.allowsSelection = NO;
    }
}

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
    
    [self vacationOpenedUpdate]; // everything we appear, in case something changed
    
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
