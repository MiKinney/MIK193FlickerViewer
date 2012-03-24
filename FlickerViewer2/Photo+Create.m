//
//  Photo+Create.m
//  FlickerViewer2
//
//  Created by Michael Kinney 
//  Copyright (c) 2012  All rights reserved.
//

#import "FlickrFetcher.h"
#import "Photo+Create.h"
#import "Place+Create.h"
#import "Tag+Create.h"

@implementation Photo (Create)

//// tags are in a space deliminated string
// returns array of captilized tag strings, 
// note by capitilizing here, in the original source for the tags, all displayes and core data fetches will work throughout the app
// because all subsequent tag name access is via properties in a Tag object...
+ (NSArray *) getPhotoTags:(NSDictionary *) photoFlickrInfo {
    NSMutableArray * photoTags = [[NSMutableArray alloc] init];
    
    // get all tags for this photo
    NSString * flickerTags = [photoFlickrInfo objectForKey:FLICKR_TAGS];
    NSScanner * scanner = [NSScanner scannerWithString:flickerTags];
    
    NSString *sepString = @" "; //// tags are in a space deliminated string
    NSString * aFlickerTag = nil;
   
    while(![scanner isAtEnd]) {
        [scanner scanUpToString:sepString intoString:&aFlickerTag];
        //NSLog(@"tag found is %@", aFlickerTag);
        if(aFlickerTag) {
            if([aFlickerTag rangeOfString:@":"].location == NSNotFound){ // there is a tag and it doesn't contain a colon
            // NSLog(@"tag used is %@", aFlickerTag);
            [photoTags addObject:[aFlickerTag capitalizedString]]; // add after capitalizing name
            }
        }
    }
    
    return photoTags;    
}

// returns array of photo's (if any) matching this photoID
//
+ (NSArray *) photoMatches: (NSString *) photoId inContext:(NSManagedObjectContext *)context{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoId = %@", photoId];
    // xxx don't really need to sort, but no sure what happens with a nil descriptor
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches) { // nil, dbase problem, not same as no photo
        NSLog(@"%@ %@", NSStringFromSelector(_cmd),[error description]);
    } 
    
    return matches;
   
}

+(BOOL) photoExists:(NSString *) photoId inContext:(NSManagedObjectContext *)context{
    BOOL exists = NO;
    
    NSArray *matches = [Photo photoMatches:photoId inContext:context];
    
    if ([matches count] >= 1) {
        exists = YES;
    }
    
    return exists;    
}

// 
+ (Photo *) addPhoto:(NSDictionary *)flickrInfo usingContext:(NSManagedObjectContext *)context {
    
    Photo *photo = nil;
    NSString * photoId = [flickrInfo objectForKey:FLICKR_PHOTO_ID]; 
    NSArray *matches = [Photo photoMatches:photoId inContext:context];
    
   if ([matches count] == 0) { // no photo stored yet for this id
        //  creating photo table with places and tag relationships !
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.photoId = [flickrInfo objectForKey:FLICKR_PHOTO_ID];
        photo.title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE];
        if(photo.title.length == 0) {
           photo.title = @"no name";
        }
        photo.photoDescription = [flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        if(photo.photoDescription.length == 0) {
            photo.photoDescription = @"no description";
        }
        // note photoURL is stored as a NSString, not as a NSURL
        photo.photoURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString];
      //  NSLog(@"%@ photoURL is %@", NSStringFromSelector(_cmd), photo.photoURL);
        // add places table
        photo.whereTook = [Place placeWithName:[flickrInfo objectForKey:FLICKR_PHOTO_PLACE_NAME] usingContext:context];
        // for all tags in photo's dictionary, add the relationship tag object  
        // parse single string of tags into an array of strings, each being a tag
        NSArray * flickerTags = [self getPhotoTags:flickrInfo]; // array of 
        // need a mutable set to add tags and init so we don't loose existing tags
        // NSMutableSet * photosTags = [[NSMutableSet alloc] initWithSet:[photo.whatTags copy]];
        for(NSString * flickerTag in flickerTags) {
            // add tag table for each tag
            [photo addWhatTagsObject:[Tag tagWithName:flickerTag inManagedObjectContext:context]];
        }
        // all done creating photo table with places and tag relationships ! 
       
    } else {
        photo = [matches lastObject]; // already exists, return the existing one
    }
    
    return photo;
}

+ (void) removePhoto:(NSString *)photoID usingContext:(NSManagedObjectContext *)context {
    
    NSArray * matches = [Photo photoMatches:photoID inContext:context];
    
    if(matches.count >= 1) { // make sure we have at least one to remove (though by design, should never have more than one... good place for unit tests.
    
        Photo * photo = (Photo * ) [matches objectAtIndex:0]; 
        // Photo to Tag table entity relationship is many to many
        // so even though we will delete the photo, some or all Tag objects may still exist
        // we need to manually decrease the count of num photos held by tag
        // note we have do this before deleting photo, as some of these tags references might be invalid after deleting photo
        NSSet * photoTags = [photo whatTags];
        for(id photoTag in photoTags) {
            Tag * tag = (Tag *) photoTag;
            [Tag decreasePhotoCount:tag]; 
        }
        
        [context deleteObject:photo];  
        
    }
    
}






@end
