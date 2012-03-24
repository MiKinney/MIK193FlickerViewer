//
//  RecentPhotosTableViewController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MIKAppDelegate.h"
#import "DetailViewSelectorController.h"
#import "RecentPhotosTableViewController.h"
#import "FlickrFetcher.h"

@interface  RecentPhotosTableViewController()
#define MAX_SAVED_PHOTOS 25
#define RECENT_PHOTOS_KEY @"recentPhotos"
@end

@implementation RecentPhotosTableViewController


// put's new photo at top of data model queue
// prevents dups by removing any exisiting older photo from queue
// saves que back to user defaults
// using standardUserDefaults storage here because it was influenced by the assignment.
// since then I've learned more persistant storage options 
//
+ (void) saveRecentPhoto: (NSDictionary *) photo{
    
    NSString * photoId = [photo objectForKey:FLICKR_PHOTO_ID];
    
    NSMutableArray * recentPhotos;
    
    // storage
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray *recents = [defaults arrayForKey:RECENT_PHOTOS_KEY];
    if(!recents) {
        recents = [[NSArray alloc] init]; // first time app runs, there isn't any saved photos array
    }
    
    recentPhotos = [recents mutableCopy];
    
    NSDictionary * eachPhoto;
    NSDictionary * duplicatePhoto;
    
    // does photo already exist in our recents collection ?
    for(eachPhoto in recentPhotos){
        if([photoId isEqualToString:[eachPhoto objectForKey:FLICKR_PHOTO_ID]]){ // get the flicker id for the stored photo and compare to new one
            duplicatePhoto = eachPhoto; // if existing, remember the duplicted photo so we can remove it after enumberation
            // note we can break out of enumeration here since will never be more than one duplicate... we are controling the collection 
            break; // best way to break out of fast enumeration ?
        }    
    }
    
    // we remove the photo from collection if alreay existing,
    if(duplicatePhoto){
        [recentPhotos removeObject:duplicatePhoto];
    }
    
    // then add as most recent at top of queu
    [recentPhotos insertObject:photo atIndex:0];
    // limit max number of photos
    recentPhotos.count > MAX_SAVED_PHOTOS ? [recentPhotos removeLastObject]: NULL;
    // update model which is user defaults everytime, but so our recent photos table can use the recentPhotos as it's data model input
   
    [defaults setObject:recentPhotos forKey:RECENT_PHOTOS_KEY]; // 
    [defaults synchronize]; // this is the real save operation,       
    
}



- (void) viewWillAppear:(BOOL)animated{
    
    // behavior bug - in iPhone, this makes the recents list update every time user views photo from the same recent list, 
    // because in iPhone, the nav controller is sequeing between the recents photos table list and the actual image file, which when we fetch the image file
    // I update the data model.... which is maybe where the bug is...
    //  get list of most recent photos viewed and update table view
    // 
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray *recents = [defaults arrayForKey:RECENT_PHOTOS_KEY];
    if(!recents) {
        recents = [[NSArray alloc] init]; // first time app runs, there isn't any saved photos array
    }
    
    // placePhotos is our data modal property in the super class controller 
    // accessed when tableView reloads next
    self.placePhotos = recents;
    
    [self.tableView reloadData]; 
    
  }

// override base class method, so we can use the correct recentPhotoViewController
// if iPad set the selected photo in the detail view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPhoto = [self.placePhotos objectAtIndex:indexPath.row]; // save user's selection
    
    DetailViewSelectorController * detailViewSelectorController = [(MIKAppDelegate *) [[UIApplication sharedApplication] delegate] detailViewSelectorController];
    
    if (detailViewSelectorController){ // we're on an ipad,
        // getting the same class type, but specific instance for the Recent photos
        PhotoViewController *pvc = [detailViewSelectorController recentPhotoViewController];
        // not using delegation in iPad, instead I use this method, which will update detail screen, 
        // is this best practice, or should I figure out a way to force detail to repaint and use it's protocol to update photo?
        pvc.photo = self.selectedPhoto; 
        [RecentPhotosTableViewController saveRecentPhoto:self.selectedPhoto];
    }   
    
}


@end
