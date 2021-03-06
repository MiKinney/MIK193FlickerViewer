//
//  PlacesTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/17/12.
//  Copyright (c) 2012 All rights reserved.
//

#import "PlacesTableViewController.h"
#import "PhotosTableViewController.h"
#import "MapViewController.h"
#import "PlacesMapAnnotation.h"
#import "MIKActivityIndicatorView.h"
#import "DTCustomColoredAccessory.h"

@interface PlacesTableViewController() <MapViewControllerDelegate, PhotosDataSourceDelegate>

@property (strong, nonatomic) NSArray *topPlaces;
@property (strong, nonatomic) NSDictionary *selectedTopPlace;

@end

@implementation PlacesTableViewController

@synthesize topPlaces = _topPlaces;
@synthesize selectedTopPlace = _selectedTopPlace;


// download from flicker  all the flicker top places in the world for photos for today
// 
- (void) refreshTopPlaces{
    
  //  __block NSArray * unsortedPlaces;
    
    __block typeof (self) bSelf = self; //  avoid memory leaks through retain cycle, see  // http://stackoverflow.com/questions/4352561/retain-cycle-on-self-with-blocks
    
    MIKActivityIndicatorView* spinner = [[MIKActivityIndicatorView alloc] initWithView:self.tableView];
    [spinner startAnimating];
    
    // 
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flicker Fetch", NULL);
    dispatch_async(downloadQueue, ^{
        
		 // do the download from flicker
	     //
         bSelf.topPlaces = [FlickrFetcher topPlaces];
		
        // the results are returned in order of top rated places...the following sort changes the order to alphabetical order
		// after using the app this way, I realized the results when alphabetical, you loose the visual 'top-rated' listing
		// 
        // Refactor - a switch to let user choose between sorted - alphavbetical and  unsorted - top rated
		/*
		 unsortedPlaces = [FlickrFetcher topPlaces];
		// sorting using a block
		//
        bSelf.topPlaces = [unsortedPlaces sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary * place1 = (NSDictionary *) obj1;
            NSString * place1Name = [place1 valueForKey:FLICKR_PLACE_NAME];
            if(!place1Name) {place1Name = [[NSString alloc] initWithString:@"place1Name"];}// no nil strings to comparator
            
            NSDictionary * place2 = (NSDictionary *) obj2;
            NSString * place2Name = [place2 valueForKey:FLICKR_PLACE_NAME];
            if(!place2Name) {place2Name = [[NSString alloc] initWithString:@"place2Name"];} // no nil strings to comparator
            
            return ([place1Name compare:place2Name options:NSCaseInsensitiveSearch]);
        }];
		 */
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // update table on main que
            [bSelf.tableView reloadData];
            [spinner stopAnimating];
            
        });
    });
    
    dispatch_release(downloadQueue);

}


// refresh button on places view...
// fetch top places again from flicker and update table
- (IBAction)refresh:(id)sender {
    // 
    [self refreshTopPlaces]; 
 }

// helper to build annotations for map, not part of a map delegate
// returns array of PlacesMapAnnotation objects
// refactor this out... 
- (NSArray *) mapAnnotations
{
    NSMutableArray * annotations = [[NSMutableArray alloc] initWithCapacity:self.topPlaces.count];
    for(NSDictionary * place in self.topPlaces)
    {
        [annotations addObject:[PlacesMapAnnotation annotationForPlace:place]];
    }
    
    return annotations;
}

#pragma mark MapViewControllerDelegate
// refactor this out....
- (NSDictionary *) mapViewController:(MapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation
{
    // flicker does not have images for the actual Place, only for the photos in that place.
    NSMutableDictionary * photoAndImage = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [photoAndImage setObject:[[NSNull alloc] init] forKey:@"photo"];
    [photoAndImage setObject:[[NSNull alloc] init] forKey:@"image"];
    
    return photoAndImage;


}

#pragma mark - Photos place datasource delgate

// provide the last place touched by user's in the table view
// this is the how photo controller get's the selectd place
// Refactor - maybe instead set this in the segue to the photo controller
- (NSDictionary *) place{
    return self.selectedTopPlace;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // number of rows in section is number of places
    //
    return self.topPlaces.count;
}

// poplulate the table, populate table rows with top place names and locations
// the data model is the topPlaces that have already been fetched from flicker
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Places Cell";
    
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
    
    // get dictionary item for this row from flicker place names we downloaded
    NSDictionary * place = (NSDictionary *) [self.topPlaces objectAtIndex:indexPath.row];  
    
    // get the city, state, province, whatever...Thanks 
    NSString * fullPlaceName = [place objectForKey:(FLICKR_PLACE_NAME)];
    
    // get the city name from the full name by finding index of first delim then getting the characters
    NSCharacterSet * delimCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@","];
    NSRange firstDelimRange = [fullPlaceName rangeOfCharacterFromSet:delimCharacterSet]; //
    NSString * cityName = [fullPlaceName substringToIndex:firstDelimRange.location]; // assuming there is always a city
    
    // the city's location is everything after the first delim, 
    NSString * cityLocation = [fullPlaceName substringFromIndex:firstDelimRange.location]; 
    // but note location included the delim, so let's get rid of that
    // interesting I can assign result of an immutable string by to itself, the immutable string.. compiler doing something here under the covers ?
    cityLocation = [cityLocation stringByTrimmingCharactersInSet:delimCharacterSet];
    // and then any whitespace
    cityLocation = [cityLocation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    cell.textLabel.text = cityName;
    cell.detailTextLabel.text = cityLocation;
    
    return cell;
}


#pragma mark - Table view delegate

// not used since we pick up the row  info in segue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
}

#pragma mark - segue
// nativation controller is about to swap view controllers... 
//
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    // we're in a table view, get the present selected row so we can set the place
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    // right now only PhotosTableViewController uses this, but setting it all the time
    self.selectedTopPlace = [self.topPlaces objectAtIndex:indexPath.row];
    
    // we may seque to another table controller or to our mapping controller 
    id destinationController = segue.destinationViewController;
    
    if ([destinationController isKindOfClass:[PhotosTableViewController class]]){
        PhotosTableViewController *tvc = (PhotosTableViewController *) destinationController;
        tvc.dataSourceDelegate = self;    
    } else if([destinationController isKindOfClass:[MapViewController class]]) {
        MapViewController * mvc = (MapViewController*) destinationController;
        mvc.delegate = self;
        mvc.annotations = [self mapAnnotations];
    }    
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
	// fetch topplaces from flicker
    // do this here and not on viewWillAppear, don't want to fetch from flicker everytime user tabs to this view
    // 
    [self refreshTopPlaces]; 
 
    // preserve selection between presentations.
	// user can tab away from top rated, example to recents or vacations, and our place selection is maintained
	self.clearsSelectionOnViewWillAppear = NO;
    
}

- (void)viewDidUnload
{
    self.topPlaces = nil;
    self.selectedTopPlace = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
