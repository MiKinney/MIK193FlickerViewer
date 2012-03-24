//
//  VacationsTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney.
//  Copyright (c)2012
//

#import "AddVacationViewController.h"
#import "VacationsTableViewController.h"
#import "VacationShortCutTableViewController.h"
#import "Vacations.h"

@interface VacationsTableViewController() <AddVacationViewControllerDelegate>

@property (strong, nonatomic ) NSArray * vacationNames;

@end

@implementation VacationsTableViewController 

@synthesize vacationNames  = _vacationNames;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.vacationNames = nil;
    [super viewDidUnload];       
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // get collection of existing vacations and display 'em
    //
    self.vacationNames = [Vacations getVacationNames];
    [self.tableView reloadData];
    
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // get user's selected vacation name before segueing
    if([sender isKindOfClass:[UITableViewCell class]])
    {
        NSIndexPath * indexPath = self.tableView.indexPathForSelectedRow;
        [Vacations setSelectedVacationName:[self.vacationNames objectAtIndex:indexPath.row]];
    }

}

#pragma mark - Table view data source


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows;
    
    if(!self.vacationNames) {
        numRows = 0;
    } else {
        numRows = self.vacationNames.count;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacations Vacation Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // display vacation name...
    cell.textLabel.text = [self.vacationNames objectAtIndex:indexPath.row]; 
    
    return cell;
}

// allow the user to add a new vacation
// create and display the add vacation modal view
//
- (IBAction)addVacation:(id)sender {

    AddVacationViewController * addVacationViewController = [[AddVacationViewController alloc] initWithNibName:@"AddVacationViewController" bundle:nil];
    addVacationViewController.delegate = self;
    addVacationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:addVacationViewController animated:YES completion:nil]; // new iOS5 method
    
}

- (void) addVacationViewController:(AddVacationViewController *)sender addedVacation:(NSString *)vacationName {
    // NSLog(@"received vacation request %@", vacationName);
    // close the modal view first
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString * newVacationName = vacationName; // doing this so we can access it in the following blocks
    if(vacationName && vacationName.length > 0){
        if(![Vacations vacationExists:vacationName]) {
            // new vacation needed, getVacation creates the document, persists it, and opens it
            // Refactor - a method that just creates it on disk without opening it. 
            [Vacations getVacation:vacationName done:^(VacationDocument *document) {
                // it's open, but we might not need it now, so just close it
                // 
                [document closeVacation:^(BOOL success) {
                    typeof (self) bSelf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{ // should be on main queue already, but just in case.. 
                        // let's assume since the user just added it, they want to use it, so select it
                        // this way they can go directly to looking at photos and adding them to the vacation
                        // the other controllers will open the vacation if that's necessary
                        [Vacations setSelectedVacationName:newVacationName]; // block access 
                        // update table on main que to show new vacation !
                        self.vacationNames = [Vacations getVacationNames]; // get the latest from persistent store !
                                                
                        [bSelf.tableView reloadData];
                    });
                }];
            }];
            
        } else {
            // todo alert user vacation already exists - could do this in the add vacation dialog !!
        }
    }
}


@end

