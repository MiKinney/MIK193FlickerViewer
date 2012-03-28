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

- (void) centerScrollViewContents;
- (void)setMaxMinZoomScalesForCurrentBounds:(PhotoViewController *) controller;
- (void) loadPhoto;

@end

@implementation PhotoViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolBar = _toolBar;
@synthesize visitButton = _visitButton;
@synthesize photoTitleLabel = _photoTitleLabel;
@synthesize downloadQueue = _downloadQueue;

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
        } else { // not on screen 
            self.imageView.image = nil; // save memory and used as prompt to load image when view does appear
        }        
    } 
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
				
				// reusing scrollview, reset zoom scale to 1 before setting any frame or content,
				// otherwise the imageView.frame size will keeping growing, by factors of 2, 3... after everytime we call loadPhoto and set a zoom level
                [bSelf.scrollView setZoomScale:1 animated:NO]; //  make sure this is set before we set contentsize with image size, since contentsize changes when zoomed

               	// remove old image, begin new... 			
				[bSelf.imageView removeFromSuperview];				
                // new displayable image from the photo file we fetched earlier
				bSelf.imageView.image = nil;
                bSelf.imageView.image = [[UIImage alloc] initWithData:photoFile]; 
				// NSLog(@"%@ imageview size width %f imageview size height %f", self.photoName, bSelf.imageView.image.size.width, bSelf.imageView.image.size.height); 
                // since we assigned the image, rather than originally initing the imageView with the image in it, we need to manually set the frame size
                bSelf.imageView.frame = CGRectMake(0, 0,bSelf.imageView.image.size.width, bSelf.imageView.image.size.height);
				
				//NSLog(@"   ");
				//NSLog(@"imageFrameSize on load photo is width %f frame size height %f",bSelf.imageView.frame.size.width, bSelf.imageView.frame.size.height); 
				
			    // update scrollview with new view, since  we removed the old one. fresh / reset image data each new phot
				[bSelf.scrollView addSubview:bSelf.imageView];
				
				// scroll view needs image size it will scroll over (note to always clear zoom to 1, reset it, 
				// before setting this content, as it's affect by zoom setting.
				[bSelf.scrollView setContentOffset:CGPointZero]; // in case prior photo was scrolled, this will put scroll view bound back to it's frame's bounds
				bSelf.scrollView.contentSize = bSelf.imageView.image.size;
               				
				// calculated a reasonable min / max value for this image;
				//
				[bSelf setMaxMinZoomScalesForCurrentBounds:bSelf];
				
				//NSLog(@"load photo zoom scale BEFORE zooming is %f",self.scrollView.zoomScale);
				//NSLog(@"setting zoom scale to %f", self.scrollView.minimumZoomScale);
				
				[self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
				
				//NSLog(@"load photo zoom scale AFTER zooming %f",self.scrollView.zoomScale);
				
				// keep image centered in view...
				[self centerScrollViewContents];
			  
			}
            
            // note how  so we don't show the button state before photo is loaded, we call this in the queue, after the photo is loaded.
            [self setVisitButtonToMatchPhotoVacationPresence]; // do this after we load,
			// title for user
			bSelf.photoTitleLabel.text = self.photoName; 

            [spinner stopAnimating]; // make sure we stop, even if no photo file
              
        });
    });
}

// center the image as it becomes smaller than the size of the screen (code originated with apple example )
// 
- (void) centerScrollViewContents{
	
	// get the scrollView bounds, because from that we get the viewing size fo the scroll view onto the image
	// compage that with the image frame size in width and height, to find diff in dimensions and use that to adjust center points in frame structure
	CGSize boundsSize = self.scrollView.bounds.size;
	CGRect frameToCenter = self.imageView.frame;
	
	// center horizontally
	if (frameToCenter.size.width < boundsSize.width)
		// image smaller than scroll view, adjust frames origin x component by finding diffs in widths
		// a positive offset in along the x axis, is image frames upper left corner, bounds though is still 0,0
		frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.0f; 
	else
		// iamge is larger, then a true center would be a negative origin.x, if that was possible
		frameToCenter.origin.x = 0; // so this will not center on positive zoom ??	
	// center vertically
	if (frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0f;
	else
		frameToCenter.origin.y = 0;	
	
	self.imageView.frame = frameToCenter;
}


// adapted apple source,  set's scroll min max zoom scale according to image size..
// passing controller to  this method, so I can call it out of block, using bSelf...
- (void)setMaxMinZoomScalesForCurrentBounds:(PhotoViewController *) controller;
{
	//NSLog(@"entering set max min zoom value");
    CGSize boundsSize = controller.scrollView.bounds.size;
	//NSLog(@"scrollboundsSize  is width %f and height %f", boundsSize.width, boundsSize.height);
		
	CGSize imageSize = controller.imageView.image.size; // apple bug had bounds size here, frame is the true image size
	// NSLog(@"imageSize  is width %f and height %f", imageSize.width, imageSize.height);
	
	/*
	CGSize scrollViewFrameSize = controller.scrollView.frame.size;
	NSLog(@"scrollViewFrameSize  is width %f and height %f", scrollViewFrameSize.width, scrollViewFrameSize.height);
	
	CGSize imageFrameSize = controller.imageView.frame.size; // apple bug had bounds size here, frame is the true image size
	NSLog(@"imageFrameSize  is width %f and height %f", imageFrameSize.width, imageFrameSize.height);
	 
	 CGSize contentSize = controller.scrollView.contentSize;
	 NSLog(@"contentSize  is width %f and height %f", contentSize.width, contentSize.height);
	*/
	
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visibl
 	self.scrollView.minimumZoomScale = minScale;
	
	// NSLog(@"min zoom scale using bounds  is %f", minScale);
	
}


// keep the image centered as user zooms, or anything causes the zoom
//
- (void) scrollViewDidZoom:(UIScrollView *)scrollView {	
	//	[self centerScrollViewContents];		
	//NSLog(@"zoom scale after scrollViewDidZoon %f", scrollView.zoomScale);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {	

	[self centerScrollViewContents];	 
}


// based on photo presence in given VacationDocument, set button to display 'visit' or 'unvisit', 'vacation name',  
// 
- (void) setVisitButtonToMatchPhotoVacationPresence:(VacationDocument*) document {
    
    if(self.imageView.image) { // but only show the title if there's an image displayed]
        self.visitButton.enabled =  YES; // becuase we disable it if no image
        // visit or unvisit 
        if([document photoExists:self.photoId]) {
            // exists in vacation, so can unvisit from this vacation
            self.visitButton.title = [[NSString alloc] initWithFormat:@"Unvisit %@", document.vacationName];
        } else {
            // does not exist in vacation, so can visit on this vacation
            self.visitButton.title = [[NSString alloc] initWithFormat:@"Visit %@", document.vacationName];
        }  
        
    } else {
        self.visitButton.title = @"     ";
        self.visitButton.enabled =  NO;
    }
}


// based on photo presence in given VacationDocument, set button to display 'visit' or 'unvisit', 'vacation name', 
// find's it's own vacation name and document
- (void) setVisitButtonToMatchPhotoVacationPresence {
    
    VacationDocument * vacationDocument = [Vacations getOpenManagedVacation];
    if(vacationDocument) { // make sure it's open
        [self setVisitButtonToMatchPhotoVacationPresence:vacationDocument];
    }    
}

// add or remove presently displayed photo from vacation
// 
- (IBAction)visitButtonTouched:(UIBarButtonItem *)sender {
    
    VacationDocument * document = [Vacations getOpenManagedVacation];  
	
    if(document) {       
        if([document photoExists:self.photoId]) {
            // we have a photo on vacation so remove it
            // 
            [document removePhoto:self.photoId];
            // update visit button to show we can Visit the place again
            [self setVisitButtonToMatchPhotoVacationPresence:document];
        } else { 
            // no photo, add it to vacation
            [document addPhoto:self.photoDictionary];
            // update visit button to show we can Unvisit this place
            [self setVisitButtonToMatchPhotoVacationPresence:document];
        }   
    }
}

#pragma mark scroll view image control

#pragma mark scroll view delegates

// note we set the min and max zoom values using the storyboard
-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
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
        [self.scrollView flashScrollIndicators]; // show that the view is scrollable 
    } else {
        // photo already loaded and image displayed,  
        // this will update button to reflect any changes in user's selected vacation, while displaying this photo, such as by going to Vacation tab
        // cannot use kvo or notifications per present design since  the Vacations class only has class methods.       
        [self setVisitButtonToMatchPhotoVacationPresence]; 
        [self.scrollView flashScrollIndicators]; // show that the view is scrollable -    
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
    
    [self setPhotoTitleLabel:nil];
        
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




@end
