//
//  AddVacationViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/21/12.
//  Copyright (c) 2012 All rights reserved.
//  used modally to allow user to add a new vacation
//  has it's own .xib file separate from the Storyboards
//  

#import <UIKit/UIKit.h>

@class AddVacationViewController;

@protocol AddVacationViewControllerDelegate <NSObject>

- (void) addVacationViewController:(AddVacationViewController *) sender
                     addedVacation:(NSString*) vacationName;

@end

@interface AddVacationViewController : UIViewController

@property (nonatomic, weak) id <AddVacationViewControllerDelegate> delegate;

@end
