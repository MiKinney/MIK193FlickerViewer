//
//  AddVacationViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
