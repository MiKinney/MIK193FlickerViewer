//
//  ItineraryTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationItineraryTableViewController.h"
#import "VacationPlacePhotosTableViewController.h"
#import "Place.h"
#import "Vacations.h"
#import "DTCustomColoredAccessory.h"

@interface VacationItineraryTableViewController()

@property (strong, nonatomic) VacationDocument * vacationDocument;
@property (strong, nonatomic) NSString * vacationPlace;
@end

@implementation VacationItineraryTableViewController

@synthesize vacationDocument = _vacationDocument;
@synthesize vacationPlace = _vacationPlace;

// setup fetching for ALL places for this specific vacation
//
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO selector:@selector(compare:)]];
    // no predicate because we want ALL the Places
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.vacationDocument.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

// 
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if([sender isKindOfClass:[UITableViewCell class]])
    {
        // vacations can have multiple places, get the user's selection
        NSIndexPath * indexPath = self.tableView.indexPathForSelectedRow;
        Place * place = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.vacationPlace = place.name; 
    }

    // seque to table list of all photos taken in this place
    id destinationController = [segue destinationViewController];
    if([destinationController isKindOfClass:[VacationPlacePhotosTableViewController class]]) {
        VacationPlacePhotosTableViewController * vc = (VacationPlacePhotosTableViewController * ) destinationController;
        vc.vacationPlace = self.vacationPlace;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}

- (void)viewDidUnload
{
    self.vacationDocument = nil;
    self.fetchedResultsController = nil;
    self.vacationPlace = nil;
    
    [super viewDidUnload];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // get VacationDocument managed document for this vacation and setup fetch request
    // do this everytime view appears, just in case selected vacation name changes
    // 
    self.vacationDocument = [Vacations getOpenManagedVacation];
    if(self.vacationDocument) {
        [self setupFetchedResultsController];
    }
    
   
    [self.navigationItem setTitle:@"Itinerary"];   
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

#pragma mark - Table view data source

// display name for every place in this vacations itinerary
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Itineary Place Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // default accessory is black, which is invisible when I use blackbackground for cell
    // this control is a custom accessory that use's same color as text label text 
    //  
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.textLabel.textColor];
    accessory.highlightedColor = cell.textLabel.highlightedTextColor; 
    cell.accessoryView =accessory;
    
    // 
    Place * place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // displace name for 
    cell.textLabel.text = place.name;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

@end
