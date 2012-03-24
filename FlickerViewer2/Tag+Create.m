//
//  Tag+Create.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *) tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context {

    Tag * tag = nil;
    
    // any existing ?
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"]; // our table
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor]; // multiple sort descriptors allowed
    
    NSError * error = nil;
    NSArray * tags = [context executeFetchRequest:request error:&error];
    //
    if(!tags || [tags count] > 1) { // no object returned or somehow more than one tag with same name (could happen if same tag added multiple times )        
        NSLog(@"tagWithName error %@", [error description]);
    } else if ([tags count] == 0) { // none exists
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        // my responsibility to set attribute values
        tag.name = name;
        tag.photoCount = [NSDecimalNumber numberWithInt:1]; // a tag can be associated with multiple photos
        
    } else {
        tag = [tags lastObject]; // tag already exists
        // but now associated with another photo, 
        // keep track of total number of associated photos
        // this is to allow quick sorting later, rather than iterating over all tags and all photos in all tags to get count
        int updatedCount = [tag.photoCount intValue]  + 1;
        tag.photoCount = [NSNumber numberWithInt:updatedCount];
    }
    
    return tag;
    
}


+ (void) decreasePhotoCount:(Tag *) tag {
    
    int decreasedCount = [tag.photoCount intValue] -1 ;
    // should never have a Tag object left around with less than 1 Photo, as core data should have removed the Tag object
    // but use guard anyway
    if(decreasedCount < 0) decreasedCount = 0 ; 
    tag.photoCount = [NSNumber numberWithInt:decreasedCount];    
    
}

@end
