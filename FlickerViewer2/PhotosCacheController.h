//
//  PhotosCacheController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/7/12.
//
//  Copyright (c) 2012 All rights reserved.
//
//  Maintains a cache of photo data
//  cache size is 10Mb max and is persisted in NSCachesDirectory
//  keeps most recent photos in cache, discards oldest too maintain cache size
//
#import <Foundation/Foundation.h>


@interface PhotosCacheController : NSObject

- (id) init;

// returns cached data or nil
//
- (NSData *) getCachedPhotoData: (NSURL *) photoURL;

// adds photo data if not already present, to cache using photoURL for filePath, 
//
- (void) addPhotoDataToCache: (NSData *) data forPhotoURL: (NSURL *) photoURL;



@end
