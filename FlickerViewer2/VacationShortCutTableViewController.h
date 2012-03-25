//
//  VacationTableViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  shows two staic cells an Itinerary and a Photo Tag static cell ( per Stanford assignment requirements )
//  allows user to select and look at an Itineary View of places or the other for a given vacationName
// 
//  Refactor : alternative ways to table view display, could be: 1. Adding two toolbar buttons or items that 'flips the view' of the vacation,
//             with two buttons, single touch from view a vacation in Itinerary display mode of places or vacation, or touch to see associated photo tags, 
//             one less touch required.  As per assignment, there is an extra seque, that being to show this view, which is really a toolbar, that should always
//             by shown.  No Itineary and Tag window just for two cells.
//  

#import <UIKit/UIKit.h>


@interface VacationShortCutTableViewController : UITableViewController

// view will udpate to reflect newly opened vacation 
- (void) vacationOpenedUpdate;

@end
