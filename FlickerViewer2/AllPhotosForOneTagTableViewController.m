//
//  AllPhotosForOneTagTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "DTCustomColoredAccessory.h"
#import "DetailViewSelectorController.h"
#import "Tag.h"
#import "AllPhotosForOneTagTableViewController.h"
#import "VacationPhotoViewController.h"
#import "Vacations.h"


@interface AllPhotosForOneTagTableViewController()

@property (strong, nonatomic) VacationDocument * vacationDocument;
@property (strong, nonatomic) NSMutableArray * taggedPhotos;



@end

@implementation AllPhotosForOneTagTableViewController


@synthesize vacationDocument = _vacationDocument;
@synthesize tagName = tagName;
@synthesize taggedPhotos = _taggedPhotos;

- (NSMutableArray *) taggedPhotos {
    if(!_taggedPhotos) {
        _taggedPhotos = [[NSMutableArray alloc] init];
    }
    
    return _taggedPhotos;
}

// setup fetching for all photos for one specific tag
//
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
     // this is wrong, instead of using Tag table, should use Photo table and do something like whatTags.nam for the prdicate, but that's blowing up.
      
     NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    
     request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)]];
     // note how whatTag.name is part of entity-relationship between this a Photo object and the Tag object, the 'whatTags' and the Tag class name property, the .name, thus whatTag.name 
     // is used here to limit the results of the Photo objects returned, those Tag  names match predict, self.tagName. It's a filter. 
     // 
     request.predicate = [NSPredicate predicateWithFormat:@"name = %@", self.tagName];
     
     // this is our connection between the underlying core data model and our view display. It's maybe like a Bridge pattern ? 
     // this will have the results of our request above. 
     self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                         managedObjectContext:self.vacationDocument.managedObjectContext
                                                                           sectionNameKeyPath:nil
                                                                                    cacheName:nil];   
}

// 


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
    
    // get VacationDocument managed document for this vacation and setup fetch request
    self.vacationDocument = [Vacations getOpenManagedVacation];
    if(self.vacationDocument) { // make sure it's open
        [self setupFetchedResultsController];
    }
    
    // local display
    self.navigationItem.title = self.tagName;
    
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

// overriding the super class CoreDataTableViewController method so we return the number of photos in this tag
// otherwise the default behavior is to return the number of tags, which is just one.
// this is a hack till I learn how to define precidates for fetch controller correctly..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    int rows = 0;
    // Refactor - fragile code here, assuming tag exists and is at index 0
    // todo - this crashed when removing photos that removed tags... 
    // crashed becaused trying to hack around this fetched results controller
    id fetchedObjects = [self.fetchedResultsController fetchedObjects];
    if (fetchedObjects) {
        Tag *tag = [fetchedObjects objectAtIndex:0];
        
        NSSet * taggedPhotosSet = tag.whichPhotos;
        
        // hack - creating my own local collection of photos ... till I can figure out how to do predicate correctly
        for(Photo * photo in taggedPhotosSet) {
            [self.taggedPhotos addObject:photo];
        }
         rows = tag.whichPhotos.count; // 
    }
    
    // NSInteger photosForTag = tag.whichPhotos.count;
                         
    // NSLog(@"%@ num photos for tag is %d", NSStringFromSelector(_cmd), photosForTag );
   
    return rows;
   
}

// display photo names 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Photo Cell";
    
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
    
   // hack - using my own locally created collection of photos 
   Photo *photo = [self.taggedPhotos objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = photo.title;
    
    return cell;
}

#pragma mark - Table view delegate

// get selected photo and display it !
// this is iPad support
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // hack - using my own locally created collection of photos 

    Photo *photo = [self.taggedPhotos objectAtIndex:[indexPath row]];
	
	DetailViewSelectorController *  detailViewSelectorController = [self.splitViewController.viewControllers lastObject];
    
    if (detailViewSelectorController){ // we're on an ipad,
        VacationPhotoViewController *pvc = [detailViewSelectorController vacationPhotoViewController];
        // note photoURL is a NSString, it's coming from core data
        // NSString * title = [[NSString alloc] initWithFormat:@"Viewing Vacation Photo : %@", photo.title];
        [pvc setPhoto:photo]; 
    }   
}


@end
