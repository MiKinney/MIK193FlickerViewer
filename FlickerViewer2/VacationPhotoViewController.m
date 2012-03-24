//
//  VacationPhotoViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationPhotoViewController.h"
#import "Vacations.h"

@interface VacationPhotoViewController() 

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation VacationPhotoViewController

@synthesize masterPopoverController = _masterPopoverController;


// setup to load the image when we don't have a flicker photo dictionary but instead already have photo info 
// added this method to support display of photo info stored in core data
//
- (void) setPhoto:(Photo*) photo {
    
   
    // photoURL is stored as string in core data
    NSURL * url = [NSURL URLWithString:photo.photoURL];
    
    self.photoURL = url;
    self.photoName = photo.title;
    self.photoId = photo.photoId;
    self.photoDictionary = nil; // we no longer have a dictionary
    
    // display if on screen, else display when we do come on screen
    if(self.imageView.window) {
        // on screen, typical behavior for iPad with detail view behavior
        [self loadPhoto];
        // do this after we load, so we don't show the button state before photo is loaded
        //
        [self setVisitButtonToMatchPhotoVacationPresence];
    } else { // not on screen 
        self.imageView.image = nil; // save memory and used as prompt to load image when view does appear
    } 
    
}

// add or remove presently displayed photo from vacation
// 
- (IBAction)visitButtonTouched:(UIBarButtonItem *)sender {
    
    [Vacations getVacation:[Vacations getSelectedVacationName] done:^(VacationDocument *document) {
        
        if([document photoExists:self.photoId]) {
            // we have a photo on vacation so remove it
            // 
            [document removePhoto:self.photoId];
            // once removed, we can no longer add it back (from vacation plane), so no need to show visit... also
            self.imageView.image = nil;
            // no image, no title
            self.photoTitleLabel.text = @"";
            
            // this will update the visit button to reflect that there's no image
            [self setVisitButtonToMatchPhotoVacationPresence];
            // 
            // todo - in iPhone, we should pop the view
            // note - right now, we are still showing the visit button's last state
            // since view is now gone, it's doesn't make sense to show anything
        }      
    }];
    
}


#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
