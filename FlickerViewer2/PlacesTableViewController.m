//
//  PlacesTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "PhotosTableViewController.h"
#import "MapViewController.h"
#import "PlacesMapAnnotation.h"
#import "MIKActivityIndicatorView.h"


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
    
    __block typeof (self) bSelf = self; //  avoid memory leaks through retain cycle, see  // http://stackoverflow.com/questions/4352561/retain-cycle-on-self-with-blocks
    
    MIKActivityIndicatorView* spinner = [[MIKActivityIndicatorView alloc] initWithView:self.tableView];
    [spinner startAnimating];
    
    // 
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flicker Fetch", NULL);
    dispatch_async(downloadQueue, ^{
        // do the download
        bSelf.topPlaces = [FlickrFetcher topPlaces];
        
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

- (NSDictionary *) mapViewController:(MapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation
{
    // flicker does not have images for the actual Place, only for the photos in that place.
    NSMutableDictionary * photoAndImage = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [photoAndImage setObject:[[NSNull alloc] init] forKey:@"photo"];
    [photoAndImage setObject:[[NSNull alloc] init] forKey:@"image"];
    
    return photoAndImage;


}

#pragma mark - Photos place datasource delgate

// provide the last  place touched by user's in the table view
// this is the photos controller's model
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
    
    // get this notification, viewDidLoad happens before app become active, so this will work.
    // this did not work after adding tab controller into split view, app was active first
    //  [[NSNotificationCenter  defaultCenter] addObserver:self.tableView selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
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
    
    // fetch topplaces from flicker
    [self refreshTopPlaces]; 
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
