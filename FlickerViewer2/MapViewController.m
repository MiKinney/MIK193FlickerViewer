//
//  MapViewController.m
//  FlickerViewer
//
//  Created by Michael Kinney on 3/2/12.
//  Copyright (c) 2012 All rights reserved.
//

#import "DetailViewSelectorController.h"
#import "MapViewController.h"
#import "PhotosMapAnnotation.h"
#import "PlacesMapAnnotation.h"
#import "RecentPhotosTableViewController.h"


@interface MapViewController() <PhotosDataSourceDelegate>  // Refactor to remove need to implement PhotosDataSourceDelegate, 

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKAnnotationView * selectedAnnotationView;


@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize selectedAnnotationView = _selectedAnnotationView;


// remove any existing annotations and add new ones
// note if no new ones, then this operation clears the map
- (void) updateMapView
{
    // if called before mapView exists, then this does nothing...
    // 
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];    
}


// note how we call updateMapView from both setMapView and setAnnotations, 
// thus if setAnnotations called before mapView is set, map will still work when setMapview called
// 
- (void) setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}


#pragma mark MKMapViewDelegate

// setup pin annotations and calluts
// note this has an image for both places and photos, but for places image is not supplied by flicker, 
// refactor to remove leftCalloutAccessoryView for places
- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView * aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
		// disclosure button used for segues
        UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];        
        aView.rightCalloutAccessoryView = rightButton;
		
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)]; 
        // don't set the image yet, that's too expensive, wait until we actually show it later
        [(UIImageView *) aView.leftCalloutAccessoryView setImage:nil];
                
    }
        
    aView.annotation = annotation; // yes, setting this twice the first  time view's created.
    return aView;
}

// if user is viewing photos map, get thumbnail image for selected pin 
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    self.selectedAnnotationView = aView; // save for later use by delegate callbacks for selected place and photos
   
    // since iOS reuses annnotation cells, if the user interacted with the map before we got the image back, such as by selecting another pin
    // then the annotations and thus photos may not match, so test view and annotation again may have changed, and we would be supplying the wrong image.
    // first of all, only do this for annotations with photos
    // Refactor - consider moving this queue request out of the map view controller and into a  datamodel...
    if([self.selectedAnnotationView.annotation isKindOfClass:[PhotosMapAnnotation class]]) {
 
        dispatch_queue_t thumbNailQueue = dispatch_queue_create("ThumbnailQue", NULL);
        dispatch_async(thumbNailQueue, ^ {  

            // making a request here to the Internet (if not cached), on another queue, so it could be 'some time' before this returns
            // photoAndImage keeps the photo used to make the request and the resultant image, if any, paired up
            NSDictionary * photoAndImage = [self.delegate mapViewController:self imageForAnnotation:aView.annotation]; // request to net
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // yes, check annoation again for correct type, the annotation could be a different type now, for example a Places annotation
                if([self.selectedAnnotationView.annotation isKindOfClass:[PhotosMapAnnotation class]]) {
                    PhotosMapAnnotation * photosMapAnnotation = self.selectedAnnotationView.annotation;
                    // 
                    NSDictionary * requestedPhoto = [photoAndImage objectForKey:@"photo"];
                    
                    if([photosMapAnnotation.photo isEqualToDictionary:requestedPhoto]) { // present dictionary item same as one used in request ?
                        UIImage *image = nil;
                        id returnedImage = [photoAndImage objectForKey:@"image"];
                        // make sure we have a valid image, if none existed, dictionary contains NSNull object, not UIImage object
                        if ([returnedImage isKindOfClass:[UIImage class]]) {
                            image = (UIImage *) returnedImage;
                            [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
                        } else {
                            [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
                        }                        
                    }
                }
            });
            
        });
        dispatch_release(thumbNailQueue);
    }
}

// user clicked disclosure button
// based on iPhone or iPad and annotation type, segue to other views or show image in detail view
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

    self.selectedAnnotationView = view; // save for later use by delegate callbacks for selected place and photos
	
	// on an iPad need access to the detail views...
	DetailViewSelectorController *  detailViewSelectorController = [self.splitViewController.viewControllers lastObject];
    
    if (detailViewSelectorController){ // we're on an ipad, 
        PhotoViewController * photoViewController = [detailViewSelectorController photoViewController]; 
        if([view.annotation isKindOfClass:[PhotosMapAnnotation class]])
        {
            // update detail view with the image contained in the annotation callout
            PhotosMapAnnotation * photosMapAnnotation = (PhotosMapAnnotation *) view.annotation;            
            photoViewController.photo = photosMapAnnotation.photo;
            // maintain recents list out of the calling controller
            [RecentPhotosTableViewController saveRecentPhoto:photosMapAnnotation.photo];

        } else if ([view.annotation isKindOfClass:[PlacesMapAnnotation class]]){
            // Refactor we're showing the places annotations, so from here ideally I would want to seque to the photos map, 
            // but instead seguing to a photo table view, because it has access to the datamodel,  photos map does not have direct access to data model, 
			// (because made flicker viewer in steps from Stanford exercises without thinking far enough ahead)
            // so instead  we  segue to the photostableviewcontroller, which I really don't like...
            [self performSegueWithIdentifier:@"ShowPhotosTableView" sender:self];
        }
    } else { // iPhone
        if([view.annotation isKindOfClass:[PhotosMapAnnotation class]])
        {
            // for iPhone we have to force the segue to the photo view controller, unlike iPad, there is no detail view around
            [self performSegueWithIdentifier:@"ShowPhotoViewController" sender:self];
   
        } else if ([view.annotation isKindOfClass:[PlacesMapAnnotation class]]){
			// Refactor we're showing the places annotations, so from here ideally I would want to seque to the photos map, 
            // but instead seguing to a photo table view, because it has access to the datamodel,  photos map does not have direct access to data model, 
			// (because made flicker viewer in steps from Stanford exercises without thinking far enough ahead)
            // so instead  we  segue to the photostableviewcontroller, which I really don't like...
			//
            [self performSegueWithIdentifier:@"ShowPhotosTableView" sender:self];
        } 
    }
}


// zoom map to show pins
// todo - needs some work.  
- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if ([self.delegate respondsToSelector:@selector(region)])
    {
        MKCoordinateRegion region = [self.delegate region];
        
        // xxx refine - way to do this based on actual 
        double METERS_PER_MILE = 1609.34;
        double milesForZoom = 5; // xxx refine way to determine this value based on annotations lats and longitudes
        
        // xxx 
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(region.center, milesForZoom * METERS_PER_MILE, milesForZoom * METERS_PER_MILE);
        [mapView setRegion:[self.mapView regionThatFits:viewRegion] animated:NO];
        
        /* trying to figure distance based on location of annotations, to come up with a zoom / span that encompasses all
        CLLocationCoordinate2D coordinate;
         double maxLatitude, minLatitude, maxLongitude, minLongitude;
        for (id<MKAnnotation> annotation in self.annotations){
            coordinate = annotation.coordinate;
            maxLatitude = MAX(maxLatitude, coordinate.latitude);
            minLatitude = MIN(minLatitude, coordinate.latitude);
            maxLongitude = MAX(maxLongitude, coordinate.latitude);
            minLongitude = MIN(minLongitude, coordinate.latitude);
        }
        
        double latSpan = maxLatitude - minLatitude;
        double lonSpan = maxLongitude - minLongitude
       
        MKCoordinateSpan span = {latSpan, lonSpan};
      
        
        MKCoordinateSpan span = {0.4, 0.4};
        region.span = span;
        [mapView setRegion:region animated:NO];
         
        */
    }
}


#pragma mark PhotosDataSourceDelegate
// don't like this here in the map view particulary, 
// but it's needed by the table controller, PhotosTableViewController, which 
// we segue to directly from the places map view..
// Refactor datamodel to remove this need...
- (NSDictionary *) place {
    
    NSDictionary * selectedPlace = nil;
    
    if ([self.selectedAnnotationView.annotation isKindOfClass:[PlacesMapAnnotation class]]) {
    
        PlacesMapAnnotation * placesMapAnnotation = (PlacesMapAnnotation *) self.selectedAnnotationView.annotation;  
        selectedPlace = placesMapAnnotation.place;
    }
    
    return selectedPlace;
}


#pragma mark segue
// I'm programatically creating these segues in calloutAccessoryControlTapped
// 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPhotosTableView" ]) {
		// Refactor - will not seque to a table view controller from the map view 
        PhotosTableViewController * destinationViewController = (PhotosTableViewController *) [segue destinationViewController];
        destinationViewController.dataSourceDelegate = self; // Refactor
		
    } else if ([segue.identifier isEqualToString:@"ShowPhotoViewController"]) {
		
        PhotoViewController * photoViewController = (PhotoViewController *) [segue destinationViewController];
		
        if ([self.selectedAnnotationView.annotation isKindOfClass:[PhotosMapAnnotation class]]) {
            PhotosMapAnnotation * photosMapAnnotation = (PhotosMapAnnotation *) self.selectedAnnotationView.annotation;  
            photoViewController.photo = photosMapAnnotation.photo; // the photo view controller needs this  
            [RecentPhotosTableViewController saveRecentPhoto:photosMapAnnotation.photo];
        }
    }
    
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self; // for the MKMapViewDelegate
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    self.selectedAnnotationView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
