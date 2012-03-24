//
//  Place.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *whatPhotos;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addWhatPhotosObject:(Photo *)value;
- (void)removeWhatPhotosObject:(Photo *)value;
- (void)addWhatPhotos:(NSSet *)values;
- (void)removeWhatPhotos:(NSSet *)values;

@end
