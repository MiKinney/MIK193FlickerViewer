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
        [Vacations openVacation:[self.vacationNames objectAtIndex:indexPath.row] done:^(BOOL success) {
            if(success) {
                // after vacation opens have to update the sequed controller becuase by now it has already appeared.
                id destinationController = [segue destinationViewController];
                if([destinationController respondsToSelector:@selector(vacationOpenedUpdate)]) {
                    [destinationController vacationOpenedUpdate];
                }
            } else {
                // todo - something with result if there's an error
            }
        }];
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
    if(vacationName && vacationName.length > 0){ // make sure user entered something in the dialog
        if(![Vacations vacationExists:vacationName]) {
            // new vacation needed, create it and then open it and then update our view
            [Vacations createVacation:vacationName done:^(VacationDocument * document) {
                if(document) {
                    // let's assume since the user just added it, they want to use it, so open it
                    // this way they can go directly to looking at photos without having to select the vacation first in the vacations table view
                    [Vacations openVacation:document.vacationName done:^(BOOL success) {
                            if(success) {
                                // also update table to show latest vacation name !
                                self.vacationNames = [Vacations getVacationNames]; // update
                                [self.tableView reloadData];
                            }
                        }]; // end open vacation
                    
                } else {
                    // todo error on creation....
                }
            }]; // end create vacation
            
        } else {
            // todo alert user vacation already exists - could do this in the add vacation dialog !!
        }
    }
}


@end

