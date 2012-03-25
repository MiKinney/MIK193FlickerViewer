//
//  VacationPlacesTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MIKAppDelegate.h"
#import "VacationPlacePhotosTableViewController.h"
#import "Vacations.h"
#import "VacationPhotoViewController.h"
#import "DTCustomColoredAccessory.h"

@interface VacationPlacePhotosTableViewController() 

@property (strong, nonatomic) VacationDocument * vacationDocument;

@end

@implementation VacationPlacePhotosTableViewController

@synthesize vacationPlace = _vacationPlace;
@synthesize vacationDocument = _vacationDocument;


#pragma mark - View lifecycle

// fetch all photos taken in this vacationPlace
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)]];
    // note how whereTook.name is part of entity-relationship between this a Photo object and the Place object, the 'whereTook' and the Places class name property, the .name, thus wheretook.name 
    // is used here to limit the results of the Photo objects returned, those Place taken names match predict, self.vacationPlace. It's a filter. 
    // refactor : extend.  to U.I. where user can specify the place to search for photos, and that selection sets self.vacationPlace !!!
    request.predicate = [NSPredicate predicateWithFormat:@"whereTook.name = %@", self.vacationPlace];

    // this is our connection between the underlying core data model and our view display. It's maybe like a Bridge pattern ? 
    // this will have the results of our request above. 
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.vacationDocument.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


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
    
    // do this here rather than viewDidLoad, becuase we want the photos in this vacation place to auto update, while it's in view,  as user visits / unvisits vacations
    self.vacationDocument = [Vacations getOpenManagedVacation];
    if(self.vacationDocument) {
        [self setupFetchedResultsController];
        [self.navigationItem setTitle:self.vacationPlace];
    }
    
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

// display photo names
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Photo Cell";
    
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
        
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    
    return cell;
}


#pragma mark - Table view delegate

// get selected photo and display it !
// this is iPad support
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    DetailViewSelectorController * detailViewSelectorController = [(MIKAppDelegate *) [[UIApplication sharedApplication] delegate] detailViewSelectorController];
    
    if (detailViewSelectorController){ // we're on an ipad,
        //  write the detail property directly, because, rather than making detail use it's PhotoViewControllerDelegate photo
        
            VacationPhotoViewController *pvc = [detailViewSelectorController vacationPhotoViewController];
            // 
            [pvc setPhoto:photo]; 
            
       
    }   
}

@end
