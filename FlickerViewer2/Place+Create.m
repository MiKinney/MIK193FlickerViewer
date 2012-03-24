//
//  Place+Create.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Create.h"

@implementation Place (Create)

+ (Place *) placeWithName:(NSString *)name usingContext:(NSManagedObjectContext *)context {
    Place * place = nil;
    
    // any existing ?
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"]; // our table
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor]; // multiple sort descriptors allowed
    
    NSError * error = nil;
    NSArray * places = [context executeFetchRequest:request error:&error];
    //
    if(!places || [places count] > 1) { // no object returned or somehow more than one place with same name (could happen if same place added multiple times )        
        NSLog(@"placeWithName error %@", [error description]);
    } else if ([places count] == 0) { // none exists
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.name = name; // my responsibility to set attribute values
        place.dateAdded = [NSDate date];
    } else {
        place = [places lastObject]; // place already exists
    }
    
    return place;
    
    
}

@end
