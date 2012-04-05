//
//  PhotosCacheController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/7/12.
//  adds photo data with photo url to persistant cache
//  limits max cache size by removing older files as needed before adding a new file
//  
#import "PhotosCacheController.h"


@interface PhotosCacheController()

@property (strong,nonatomic) NSData * cachedData;
@property (strong, nonatomic) NSURL * cachePath;

// declared this here so I can located whereever I want in the implementation
- (void) insureRoomInCacheForBytes : (NSUInteger) roomNeeded;

@end

@implementation PhotosCacheController

#define MAX_ALLOWED_CACHE_SIZE 10 * 1000000 // in bytes

@synthesize cachedData =_cachedData;
@synthesize cachePath = _cachedPath;

// create subdirectory for cache if non-existent
- (id) init {
    self = [super init];
    if(self) {
        // build the directory path in the caches directory and append our subdirectory photosCache
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        self.cachePath = [[paths objectAtIndex:0] URLByAppendingPathComponent:@"photosCache"]; // only one path in iOS and it's at index 0
        // create if non-existant
        if(![[NSFileManager defaultManager] fileExistsAtPath:[self.cachePath path]]) {
            // create it, alert user on error
            NSError *error;
            if(![[NSFileManager defaultManager] createDirectoryAtPath:[self.cachePath path] withIntermediateDirectories:NO attributes:nil error:&error]) {
                
                // handle error
                NSString *message = [NSString stringWithFormat:@"Error! %@ %@", [error localizedDescription],[error localizedFailureReason]];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"photosCache" 
                                                                message:message
                                                               delegate:nil 
                                                      cancelButtonTitle:@"OK" 
                                                      otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    
    return self;
}

// add's photo data at given url, 
//
-(void) addPhotoDataToCache:(NSData *)photoData forPhotoURL:(NSURL *)photoURL {
    
    NSString * fileName = [[photoURL path] lastPathComponent];
	// filePath is made from our cache directory and file name
	NSString * filePath = [[self.cachePath path] stringByAppendingPathComponent:fileName];
    
	// if not already cached...
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
		// 
        // first make sure enough room in cache
        [self insureRoomInCacheForBytes:[photoData  length]];
        
        // now add the new file
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:photoData attributes:nil];
        
	}
}

// returns photo data from cache at given url, nil if nothing in cache
- (NSData *) getCachedPhotoData:(NSURL *)photoURL {
        
    self.cachedData = nil; // in case not cached.
	// extract fileName, same name used to cache file in addPhotoDataToCache
    NSString * fileName = [[photoURL path] lastPathComponent];  
	// filePath is made from our cache directory and file name, 
	NSString * filePath = [[self.cachePath path] stringByAppendingPathComponent:fileName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // make sure it's in the cache
        self.cachedData = [[NSData alloc] initWithContentsOfFile:filePath];
    }
  
    return self.cachedData;
}

// maintaines cache size, removes oldest files as needed, reentrant
// 
- (void) insureRoomInCacheForBytes : (NSUInteger) sizeNeeded {
     
    // how much room used by all files in this path ?
    unsigned long long  cacheUsed = 0;
    unsigned long long  fileSize;
    
    // find total cache bytes used for all files in cache
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.cachePath path] error:nil];
    for(NSString * file in files) {
        NSString * filePath = [[self.cachePath path] stringByAppendingPathComponent:file];
		// need to specifically request file attributes, 
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if(attributes != nil) {
            fileSize = [attributes fileSize]; // with this method do not need to use key/value  
            cacheUsed += fileSize;
        }
    }
    
    // NSLog(@"max cache size is %u and cache used is %llu and sizeNeeded is %u", MAX_ALLOWED_CACHE_SIZE, cacheUsed, sizeNeeded);
    // todo - guard - if sizeNeeded is greated than the entire cache size, reentrancy will never finish  
    if (cacheUsed + sizeNeeded > MAX_ALLOWED_CACHE_SIZE) {
        // need to remove enough files to make room, but only one for each call into insureRoomInCacheForBytes
        NSMutableString * olderFilePath = [[NSMutableString alloc] init];
        NSDate *olderFileDate = [NSDate date]; 
        NSDate *fileDate; 
        
		// find the oldest file in the cache
		// get all files in cache directory
        NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.cachePath path] error:nil];
        for(NSString * file in files) {
			// get size for each file, note we need a string and not the NSURL here...
            NSString * filePath = [[self.cachePath path] stringByAppendingPathComponent:file];
            NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            if(attributes != nil) {
                fileDate = [attributes fileModificationDate];
                NSTimeInterval timeDiff = [fileDate timeIntervalSinceDate:olderFileDate];
                if(timeDiff < 0) { // fileDate is older 
                    olderFileDate = fileDate; // now the oldest
                    olderFilePath = [filePath copy];
                }
            }
        }
        
        if(olderFilePath.length > 0 ) {
            
            // NSLog(@"removing file from cache %@", olderFilePath);
			
            // remove the oldest file from the cache
            [[NSFileManager defaultManager] removeItemAtPath:olderFilePath error:nil];
            
            // reentrant !
            // call ourselves till we have enough room
            [self insureRoomInCacheForBytes:sizeNeeded];

        }
    }        
}


@end
