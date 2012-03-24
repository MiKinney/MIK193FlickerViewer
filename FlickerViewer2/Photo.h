//
//  Photo.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * photoDescription;
@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *whatTags;
@property (nonatomic, retain) Place *whereTook;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addWhatTagsObject:(Tag *)value;
- (void)removeWhatTagsObject:(Tag *)value;
- (void)addWhatTags:(NSSet *)values;
- (void)removeWhatTags:(NSSet *)values;

@end
