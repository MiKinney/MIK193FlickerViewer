//
//  Place+Create.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@interface Place (Create)

// return existing place if exists with same name
// else create a new place with given name
// 

+ (Place *) placeWithName:(NSString *)name usingContext:(NSManagedObjectContext *) context; 

@end
