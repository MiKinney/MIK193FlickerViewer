//
//  Photo+Create.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@interface Photo (Create)

// adds new photo or returns existing photo (matching on photoId)
+ (Photo *)addPhoto:(NSDictionary *)flickrInfo
        usingContext:(NSManagedObjectContext *)context;

// remove existing photo, and adjust associated places and tag objects as needed
//
+ (void) removePhoto:(NSString *)photoID
       usingContext:(NSManagedObjectContext *)context;


+ (BOOL) photoExists:(NSString *) photoId inContext:(NSManagedObjectContext *) context;

@end
