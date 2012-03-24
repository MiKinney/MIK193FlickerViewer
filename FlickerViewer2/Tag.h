//
//  Tag.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * photoCount;
@property (nonatomic, retain) NSSet *whichPhotos;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addWhichPhotosObject:(Photo *)value;
- (void)removeWhichPhotosObject:(Photo *)value;
- (void)addWhichPhotos:(NSSet *)values;
- (void)removeWhichPhotos:(NSSet *)values;

@end
