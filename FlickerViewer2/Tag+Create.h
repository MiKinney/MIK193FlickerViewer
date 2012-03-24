//
//  Tag+Create.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *) tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *) context; 

// convenience method for use when deleting a photo that is associated with a tag
// needed because Photo table to Tag table is a many to many relationship, and deleting a photo would still leave the Tag 
// object in existence if other Photos still using it, so we can to call this to have the Tag object update it's count
// note so far only need to call this after deleting the photo 
// will not delete below 0, and at 0, core data will remove the Tag object anyway
+ (void) decreasePhotoCount:(Tag *) tag;

@end
