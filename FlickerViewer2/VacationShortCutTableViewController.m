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
#import "DTCustomColoredAccessory.h"

@interface VacationShortCutTableViewController()

@end

@implementation VacationShortCutTableViewController

#define ITINERARY_ROW 0
#define TAGS_ROW 1
#define NUM_ROWS 2


// this controller loads and displays before the vacation was open
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

// manual segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  NSLog(@"%d", indexPath.row);
    if(indexPath.row == ITINERARY_ROW) {
        [self performSegueWithIdentifier:@"SEGUE TO ITINERARY TABLE" sender:self];        
    } else if(indexPath.row == TAGS_ROW) {
        [self performSegueWithIdentifier:@"SEGUE TO TAGS TABLE" sender:self]; 
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUM_ROWS;
}

// configure the cells manually, I need a cell in order to use DTCustomColoredAccessory
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // customize my static cells
    NSString * cellIndentifier; 
    UITableViewCell *cell;
    
    if(indexPath.row == ITINERARY_ROW)
    {
        cellIndentifier = [[NSString alloc] initWithString:@"My Vacation Itinerary Cell"];
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }
        cell.textLabel.text = @"Itinerary";
        cell.textLabel.textColor = [UIColor whiteColor];
        
    } else if(indexPath.row == TAGS_ROW) {
        
        cellIndentifier = [[NSString alloc] initWithString:@"My Vacation Tags Cell"];
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }
        cell.textLabel.text = @"Tags";
        cell.textLabel.textColor = [UIColor whiteColor];
        
    } else {
        NSLog(@"Error: %@ called with unsupported row %d", NSStringFromSelector(_cmd), indexPath.row);
    }
        
    // default accessory is black, which is invisible when I use blackbackground for cell
    // this control is a custom accessory that use's same color as text label text 
    //  
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.textLabel.textColor];
    accessory.highlightedColor = cell.textLabel.highlightedTextColor; 
    cell.accessoryView =accessory;

    return cell;
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
