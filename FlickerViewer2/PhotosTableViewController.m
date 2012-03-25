//
//  PhotosTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "MIKAppDelegate.h"
#import "DetailViewSelectorController.h"

#import "PhotosTableViewController.h"
#import "RecentPhotosTableViewController.h"
#import "MapViewController.h"
#import "PhotosMapAnnotation.h"

#import "FlickrFetcher.h"
#import "MIKActivityIndicatorView.h"
#import "DTCustomColoredAccessory.h"

@interface PhotosTableViewController() <MapViewControllerDelegate>


@end

#define MAX_PLACE_PHOTOS 50

@implementation PhotosTableViewController 

@synthesize dataSourceDelegate = _dataSourceDelegate;
@synthesize placePhotos = _placePhotos;
@synthesize selectedPhoto  = _selectedPhoto;


// view is a table of photo names and descriptions, user may select one
//
- (void) setSelectedPhoto:(NSDictionary *)selectedPhoto {
    
    _selectedPhoto = selectedPhoto;
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


// create a map annotation for every photo in this place - not part of map delegate
// annotation provides map pins name and lat and long. location.... 
- (NSArray *) mapAnnotations
{
    NSMutableArray * annotations = [[NSMutableArray alloc] initWithCapacity:self.placePhotos.count];
    for(NSDictionary * photo in self.placePhotos)
    {
        [annotations addObject:[PhotosMapAnnotation annotationForPhoto:photo]];
    }
    
    return annotations;    
}


#pragma mark MapViewControllerDelegate
// return the original photo dictionary item and the image retrieved, if any.
// accesses net, so should be called from a worked thread
// refactor, need to move the  dispatch queue for worker thread here... 
// refractor, but problem using NSDictionary * and input to a block, compiler errors.. try again when refactoring
//
- (NSDictionary *) mapViewController:(MapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation
{
    
    NSMutableDictionary * photoAndImage = [[NSMutableDictionary alloc] init];
    
    if(![annotation isKindOfClass:[PhotosMapAnnotation class]])
        return photoAndImage; 
    
    
    PhotosMapAnnotation *pma = (PhotosMapAnnotation *)annotation;
    
    [photoAndImage setObject:pma.photo forKey:@"photo"];
    
    NSURL *url = [FlickrFetcher urlForPhoto:pma.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data) {
        [photoAndImage setObject:[UIImage imageWithData:data] forKey:@"image"];   
    } else {
        [photoAndImage setObject:[[NSNull alloc] init] forKey:@"image"];
    }
     
    return photoAndImage;
    
}

- (MKCoordinateRegion) region;
{
    MKCoordinateRegion region;
    region.center.latitude = [[self.dataSourceDelegate.place objectForKey:FLICKR_LATITUDE] doubleValue];
    region.center.longitude = [[self.dataSourceDelegate.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return region;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return self.placePhotos.count; // 
}

// update photo name and photo description in the table for the given row
// 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // default accessory is black, which is invisible when I use blackbackground for cell
    // this control is a custom accessory that use's same color as text label text 
    //  
    DTCustomColoredAccessory *accessory = [DTCustomColoredAccessory accessoryWithColor:cell.textLabel.textColor];
    accessory.highlightedColor = cell.textLabel.highlightedTextColor; 
    cell.accessoryView =accessory;
    
    // get photo for this row
    NSDictionary *photo = [self.placePhotos objectAtIndex:indexPath.row];
    
    NSString *photoName =  [photo valueForKey:FLICKR_PHOTO_TITLE];
    NSString *photoDescription = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    // todo - refactor or not - other views than this one display the photoName and description, but without any processing...
    // 
    if (photoName.length > 0){
        cell.textLabel.text = [NSString stringWithFormat:@"%@", photoName];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", @"no name"];
    } 
    
    if (photoDescription.length > 0){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", photoDescription];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @"no description"];
    } 
    
    return cell;
}

#pragma mark - Table view delegate

// if iPad set the selected photo in the detail view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPhoto = [self.placePhotos objectAtIndex:indexPath.row]; // save user's selection

    DetailViewSelectorController * detailViewSelectorController = [(MIKAppDelegate *) [[UIApplication sharedApplication] delegate] detailViewSelectorController];
    
    if (detailViewSelectorController){ // we're on an ipad,
        PhotoViewController *pvc = [detailViewSelectorController photoViewController];
        // not using delegation in iPad, instead I use this method, which will update detail screen, 
        // is this best practice, or should I figure out a way to force detail to repaint and use it's protocol to update photo?
        pvc.photo = self.selectedPhoto; 
       [RecentPhotosTableViewController saveRecentPhoto:self.selectedPhoto];
    }   
    
}


#pragma mark segue
// 
// this handles iPhone and iPad
// the iPhone storyboard may segue into a photo view or map vieww
// in iPad,so far we only segue into map view, for displaying a selected photo, that is setup in didSelectRowAtIndexPath:
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    // get selected photo based on selected row
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    // used by the delegate
    self.selectedPhoto = [self.placePhotos objectAtIndex:indexPath.row];
    
    // we may seque to another table controller or to our mapping controller
    // no need to check if iPhone or iPad, just do it based on destination
    id destinationController = segue.destinationViewController;
    
    if ([destinationController isKindOfClass:[PhotoViewController class]]){
        // 
        PhotoViewController *pvc = segue.destinationViewController;
        pvc.photo = self.selectedPhoto;
        [RecentPhotosTableViewController saveRecentPhoto:self.selectedPhoto];
    } else if([destinationController isKindOfClass:[MapViewController class]]) {
        MapViewController * mvc = (MapViewController*) destinationController;
        mvc.delegate = self; // now we can callback into this code, via the delegate and it's procotol
        mvc.annotations = [self mapAnnotations]; // 
    }
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // this will not work because we reload the table everytime view appears
    self.clearsSelectionOnViewWillAppear = NO;
    
    // ok to call this on viewDidLoad rather than viewWillAppear, because the self.dataSourceDelegate.place value will not change unless we seque back to the
    // top rated places list. And by only loading photos in viewDidLoad we of course improve performance, 
    // but also loading photos here allows the clearsSelectionOnViewWillAppear = NO to work when we tab between photos and recents and vacations
    // for the given photosPlace,  get array of dictionaries of top x number photo descriptions and id's, and refresh table view to show 
    
    __block NSArray * unsortedPlacePhotos;
    
    __block typeof (self) bSelf = self; // avoid memory retain cycle
    
    // model - get the photosPlace first, from it, we get the photos collection  
    NSDictionary * photoPlace = self.dataSourceDelegate.place;
    
    
    MIKActivityIndicatorView* spinner = [[MIKActivityIndicatorView alloc] initWithView:self.tableView];
    [spinner startAnimating]; // do this outside the download que, as it's a UIKit call
    
    // now setup and go get the photos list    
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flicker Fetch", NULL);
    dispatch_async(downloadQueue, ^{
        
        
        // the results are returned in order of most tagged...     
        // bSelf.placePhotos = [FlickrFetcher photosInPlace:photoPlace maxResults:MAX_PLACE_PHOTOS];
        
        // but I'd rather see them in alphabetical order  - get top photos for this photoPlace from flicker
        unsortedPlacePhotos = [FlickrFetcher photosInPlace:photoPlace maxResults:MAX_PLACE_PHOTOS];
        
        // sort 
        bSelf.placePhotos = [unsortedPlacePhotos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary * place1 = (NSDictionary *) obj1;
            NSString * photo1Title = [place1 valueForKey:FLICKR_PHOTO_TITLE];
            if(!photo1Title) {photo1Title = [[NSString alloc] initWithString:@"photo1Title"];} // no nil strings to comparator
            
            NSDictionary * place2 = (NSDictionary *) obj2;
            NSString * photo2Title = [place2 valueForKey:FLICKR_PHOTO_TITLE];
            if(!photo2Title) {photo2Title = [[NSString alloc] initWithString:@"photo2Title"];} // no nil strings to comparator
            
            return ([photo1Title compare:photo2Title options:NSCaseInsensitiveSearch]);
        }];
        
        // now that we have the photos list, force view update and update title
        dispatch_async(dispatch_get_main_queue(),^{
            
            [bSelf.tableView reloadData];
            
            // we want the photoPlaces city name for the nav title
            // photoPlace name may include city, country, region    
            NSString *photoPlaceName = [photoPlace valueForKey:FLICKR_PLACE_NAME];
            // we just want the city name, to put in the title  
            NSCharacterSet * delimCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@","];
            NSRange firstDelimRange = [photoPlaceName rangeOfCharacterFromSet:delimCharacterSet]; //
            // don't display it until after we get the photos list belwow
            NSString * cityName = [photoPlaceName substringToIndex:firstDelimRange.location]; // assuming there is always a city
            
            // update nav title on screen
            bSelf.navigationItem.title = cityName;
            [spinner stopAnimating];
            
        });
        
    });
    
    dispatch_release(downloadQueue);
}

- (void)viewDidUnload
{
    
    self.placePhotos = nil;
    self.selectedPhoto = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
     [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
     
    
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
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
    
}

@end









