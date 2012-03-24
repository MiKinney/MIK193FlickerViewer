//
//  PhotoViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "FlickrFetcher.h"
#import "MIKActivityIndicatorView.h"
#import "DetailViewSelectorController.h"
#import "PhotoViewController.h"
#import "PhotosCacheController.h"
#import "Vacations.h"

@interface PhotoViewController()  <SubstitutableDetailViewController>

@property (strong, nonatomic) PhotosCacheController * cacheController;
@property (readonly) dispatch_queue_t downloadQueue;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

// declaring this method here, so I can locate the implementation anywhere I want in this .m file
- (void) setVisitButtonToMatchPhotoVacationPresence;

@end

@implementation PhotoViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolBar = _toolBar;
@synthesize visitButton = _visitButton;
@synthesize downloadQueue = _downloadQueue;
@synthesize titleLable = _titleLable;
@synthesize cacheController = _cacheController;
@synthesize photoURL = _photoURL;
@synthesize photoName = _photoName;
@synthesize photo = _photo;
@synthesize photoId = _photoId;
@synthesize photoDictionary = _photoDictionary;


- (PhotosCacheController *) cacheController {
    if(!_cacheController) {
        _cacheController = [[PhotosCacheController alloc] init];
    }    
    return _cacheController;
}

- (dispatch_queue_t) downloadQueue{
    if(!_downloadQueue){
        _downloadQueue = dispatch_queue_create("MyFlickerQue", NULL);;
    }    
    return _downloadQueue;
}


// download the photo from flicker (unless locally cached) then update view with it
//  
- (void) loadPhoto{
    
 
    __block NSData *photoFile;
    __block typeof (self) bSelf = self;
   
    
    MIKActivityIndicatorView* spinner = [[MIKActivityIndicatorView alloc] initWithView:self.view];
    [spinner startAnimating]; 

    dispatch_async(self.downloadQueue, ^{
        
        // check for cached photo first 
        photoFile = [bSelf.cacheController getCachedPhotoData:self.photoURL];
       
        // fetch from flicker if we don't have a cached file yet
        if(!photoFile) {
            // from flicker on the net
            photoFile = [NSData dataWithContentsOfURL:bSelf.photoURL];
            // cache the new one
            [bSelf.cacheController addPhotoDataToCache:photoFile forPhotoURL:bSelf.photoURL];
        }  
        
        // update the u.i. on it's thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if (photoFile) {
                
                // title for user
                bSelf.titleLable.text = self.photoName;  

                // set the image in the view
                bSelf.imageView.image = [[UIImage alloc] initWithData:photoFile];    
                
                // NSLog(@"%@ imageview size width %f imageview size height %f", self.photoName, bSelf.imageView.image.size.width, bSelf.imageView.image.size.height); 
                // since we assigned the image, rather than originally initing the imageView with the image in it, we need to manually set the frame size
                bSelf.imageView.frame = CGRectMake(0, 0,bSelf.imageView.image.size.width, bSelf.imageView.image.size.height);
                // NSLog(@"%@ frame size width %f frame size height %f", self.photoName, bSelf.imageView.frame.size.width, bSelf.imageView.frame.size.height); 
                
                // scrolling - todo - not working the way I want... example, selecting the same image twice in a row gives different visible 'zooms', even though my setZoomScale is the same
                //
                //  don't show any white space when  displaying image.
                [bSelf.scrollView setZoomScale:1 animated:NO]; //  make sure this is set before we set contentsize with image size, since contentsize changes when zoomed
                // scroll view needs to know the size of the content to scroll over, regardless of any zoomin
                bSelf.scrollView.contentSize = bSelf.imageView.bounds.size;
                
                // 
                CGSize scrollSize = bSelf.scrollView.bounds.size;
                // CGSize imageSize = bSelf.imageView.image.size; 
                CGSize imageSize = bSelf.imageView.bounds.size; // using bounds.size works better than using image.size, which is not what I would expect
                
                
                if(imageSize.width > 0 && imageSize.height > 0) { // don't know why these would ever be 0, but test anyway since this is a division...
                    // this zoom calulation logic is suspect...
                    float zoomX = (scrollSize.width / imageSize.width ); 
                    float zoomY = (scrollSize.height/ imageSize.height);
                    float zoom = MAX(zoomX, zoomY);
                    if(zoom > 1) { // only zoom in, never out. don't want any white lines
                        [bSelf.scrollView setZoomScale:zoom animated:NO];
                    }
                    //NSLog(@"%@ scrollviw width %f scrollviw height %f", self.photoName, scrollSize.width, scrollSize.height ); 
                    //NSLog(@"%@ imagesize width %f imagesize height %f", self.photoName, imageSize.width, imageSize.height ); 
                    //NSLog(@"%@ Zoom x %f zoom y %f zoom to %f", self.photoName, zoomX, zoomY, zoom);                    
                }
            }
                        
            [spinner stopAnimating]; // make sure we stop, even if no photo file
              
        });
        
    });
    
}

// given a flicker photo dictionary, extract photo info from dictionary 
// and load image if on screen,  or setup to load the actual image
// 
-(void) setPhoto:(NSDictionary *)photo {
    if(![_photo isEqualToDictionary:photo]) {
        // photo has changed
        self.photoDictionary = photo;
        self.photoURL = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge]; // not a network request, just formatting the url
        // NSLog(@"%@ photoURL is %@", NSStringFromSelector(_cmd), [self.photoURL path]);
        self.photoName = [photo objectForKey:FLICKR_PHOTO_TITLE];
        self.photoId = [photo objectForKey:FLICKR_PHOTO_ID];
        if(self.imageView.window) {
            // on screen, typical behavior for iPad with detail view behavior
            [self loadPhoto]; // actually get the image and display it  
            [self setVisitButtonToMatchPhotoVacationPresence]; // do this after we load, so we don't show the button state before photo is loaded
        } else { // not on screen 
            self.imageView.image = nil; // save memory and used as prompt to load image when view does appear
        }        
    } 
}

// based on photo presence in given VacationDocument, set button to display 'visit' or 'unvisit', 'vacation name',  
// 
- (void) setVisitButtonToMatchPhotoVacationPresence:(VacationDocument*) document {
    if([document photoExists:self.photoId]) {
        // exists in vacation, so can unvisit from this vacation
        self.visitButton.title = [[NSString alloc] initWithFormat:@"Unvisit %@", document.vacationName];
    } else {
        // does not exist in vacation, so can visit on this vacation
        self.visitButton.title = [[NSString alloc] initWithFormat:@"Visit %@", document.vacationName];
    }   
}


// based on photo presence in given VacationDocument, set button to display 'visit' or 'unvisit', 'vacation name', 
// find's it's own vacation name and document
- (void) setVisitButtonToMatchPhotoVacationPresence {
    
     // need vacationName to get managed document 
     // getSelectedVacationName always returns a name, default name very first time app runs
    // otherwise returns a persisted version of user's selection
     NSString * vacationName = [Vacations getSelectedVacationName];
    
     [Vacations getVacation:vacationName done:^(VacationDocument *document) {
         // this method does the actual work
         [self setVisitButtonToMatchPhotoVacationPresence:document];
     }];
    
}

// add or remove presently displayed photo from vacation
// 
- (IBAction)visitButtonTouched:(UIBarButtonItem *)sender {
    
    [Vacations getVacation:[Vacations getSelectedVacationName] done:^(VacationDocument *document) {
        
        if([document photoExists:self.photoId]) {
            // we have a photo on vacation so remove it
            // 
            [document removePhoto:self.photoId];
            // update visit button accordingly
            [self setVisitButtonToMatchPhotoVacationPresence:document];
        } else { 
            // no photo, add it to vacation
            [document addPhoto:self.photoDictionary];
            // update visit button accordingly
            [self setVisitButtonToMatchPhotoVacationPresence:document];
        }        
    }];
    
}


#pragma mark - View lifecycle

// 
- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];    
    
    // this supports views, typically iPhone, where when we setPhoto above, the image was not yet on screen 
    if(!self.imageView.image && self.photoURL) { // as long as we don't have an image already but we do have the url for it
        [self loadPhoto];
        [self setVisitButtonToMatchPhotoVacationPresence]; // do this after we load, so we don't show the button state before photo is loaded
        [self.scrollView flashScrollIndicators]; // show that the view is scrollable - todo - not seeing this visible on screen, why ?
    } else {
        // this will update button to reflect any changes in user's selected vacation
        // cannot use kvo or notifications per present design since  the Vacations class only has class methods.
        // but only do if there is an image displayed in the first place, otherwise we have a button saying 'visit 'selected vacation'
        if(self.imageView.image) {
            [self setVisitButtonToMatchPhotoVacationPresence]; 
            [self.scrollView flashScrollIndicators]; // show that the view is scrollable -  todo - not seeing this visible on screen, why ?
        }
    }
}


- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // todo - set all properties to nil...
    self.photoURL = nil;
    self.photoName = nil;
    self.cacheController = nil;

    [self setScrollView:nil];
    [self setImageView:nil];
    [self setToolBar:nil];
    [self setVisitButton:nil];
    
    dispatch_release(self.downloadQueue);
    
    
    [self setTitleLable:nil];
        [super viewDidUnload];

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

#pragma mark SubstitutableDetailViewController
// the DetailViewSelectorController is the splitViewController's delegate, the DetailViewSelectorController 
// shows / hides the buttons, then calls this on the view controller, that's how the DetailViewSelectorController
// can support multiple detail views
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Add the popover button to the toolbar.
    NSMutableArray *itemsArray = [self.toolBar.items mutableCopy];
    [itemsArray insertObject:barButtonItem atIndex:0];
    [self.toolBar setItems:itemsArray animated:NO];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
    // Remove the popover button from the toolbar.
    NSMutableArray *itemsArray = [self.toolBar.items mutableCopy];
    [itemsArray removeObject:barButtonItem];
    [self.toolBar setItems:itemsArray animated:NO];
}

#pragma mark scroll view delegates

// note we set the min and max zoom values using the storyboard
-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}



@end
