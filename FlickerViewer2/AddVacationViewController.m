//
//  AddVacationViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/21/12.
//  Copyright (c) 2012 All rights reserved.
//

#import "AddVacationViewController.h"

@interface AddVacationViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *vacationTextField;

@end

@implementation AddVacationViewController
@synthesize vacationTextField = _vacationTextField;

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)vacationEditingDidEnd:(UITextField *)sender {
    [self.vacationTextField resignFirstResponder]; // dismiss keypad
    [self.delegate addVacationViewController:self addedVacation:sender.text];
}

// 
- (IBAction)cancelButton:(UIButton *)sender {
 
    [self.vacationTextField resignFirstResponder]; // dismiss keypad
    [self.delegate addVacationViewController:self addedVacation:@""]; // send empty vacation so we don't create anythig
}


#pragma mark UITextFieldDelegate

// allow return to work regardless of text field contents
// this is an easy way for user to dismiss keypad
// 
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self.vacationTextField resignFirstResponder]; // dismiss keypad
  //  [self.delegate addVacationViewController:self addedVacation:textField.text]; 
    return YES;

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //can do this here or via the storyboard
    self.vacationTextField.delegate = self; // 
}

- (void)viewDidUnload
{
    [self setVacationTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
