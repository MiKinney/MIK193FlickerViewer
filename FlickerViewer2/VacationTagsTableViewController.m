//
//  TagsTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "VacationTagsTableViewController.h"
#import "AllPhotosForOneTagTableViewController.h"
#import "Tag.h"
#import "Vacations.h"

@interface VacationTagsTableViewController()

@property (strong, nonatomic) VacationDocument * vacationDocument;

@end

@implementation VacationTagsTableViewController 

@synthesize vacationDocument = _vacationDocument;


// setup fetching for the photos with tags for this specific vacation
//
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"photoCount" ascending:NO selector:@selector(compare:)]];
    // no predicate because we want ALL the Tags
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.vacationDocument.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Refactor note as written this only seques for tableView cell generated seques
    // 
    if([sender isKindOfClass:[UITableViewCell class]])
    {
        // vacations can have multiple places, get the user's selection
        NSIndexPath * indexPath = self.tableView.indexPathForSelectedRow;
        Tag * tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
                
        // seque to table list of all photos taken in this place
        id destinationController = [segue destinationViewController];
        if([destinationController isKindOfClass:[AllPhotosForOneTagTableViewController class]]) {
            AllPhotosForOneTagTableViewController * vc = (AllPhotosForOneTagTableViewController * ) destinationController;
            vc.tagName = tag.name;
        }      
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

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // get VacationDocument managed document for this vacation and setup fetch request
    // do this everytime view appears, just in case selected vacation name changes
    [Vacations getVacation:[Vacations getSelectedVacationName] done:^(VacationDocument *document) {
        self.vacationDocument = document;
        [self setupFetchedResultsController];
    }]; 
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Place Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Tag * tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = tag.name;
    // display number of photos for this tag and use text Photo or Photos
    int photoCount = [tag.photoCount intValue];
    NSString * subTitleText = [[NSString alloc] init];
    photoCount <= 1 ? (subTitleText = @"Photo") : (subTitleText = @"Photos");
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d %@",photoCount, subTitleText];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
