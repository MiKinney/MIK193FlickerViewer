//
//  PhotosCacheController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/7/12.
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Maintains a cache of photo data
//  cache size is 10Mb max
//  keeps most recent photos in cache, discards oldest if cach too large
//
#import <Foundation/Foundation.h>



@interface PhotosCacheController : NSObject

- (id) init;

// returns cached data or nil

- (NSData *) getCachedPhotoData : (NSURL *) photoURL;

// adds photo data to cache using photoURL for filePath, if not already present
//
- (void) addPhotoDataToCache : (NSData *) data forPhotoURL : (NSURL *) photoURL;



@end
