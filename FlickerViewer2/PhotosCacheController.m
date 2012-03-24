//
//  PhotosCacheController.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/7/12.
//  adds photo data with photo url to persistant cache
//  limits max cache size by removing older files as needed to add a new file
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

- (id) init {
    self = [super init];
    if(self) {
        // build the directory path
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        self.cachePath = [[paths objectAtIndex:0] URLByAppendingPathComponent:@"photosCache"]; // only one in iOS and it's at index 0
        // create if non-existant
        if(![[NSFileManager defaultManager] fileExistsAtPath:[self.cachePath path]]) {
            // create it, alert user on error
            NSError *error;
            if(![[NSFileManager defaultManager] createDirectoryAtPath:[self.cachePath path] withIntermediateDirectories:NO attributes:nil error:&error]) {
                
                // right out of apple's example, handle error
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
	NSString * filePath = [[self.cachePath path] stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
		// 
        // first make sure enough room in cache
        [self insureRoomInCacheForBytes:[photoData  length]];
        
        // now add the new file
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:photoData attributes:nil];
        
	}
}

// returns photo data at given url, nil if nothing in cache
- (NSData *) getCachedPhotoData:(NSURL *)photoURL {
    
    
    self.cachedData = nil;
    NSString * fileName = [[photoURL path] lastPathComponent];
	NSString * filePath = [[self.cachePath path] stringByAppendingPathComponent:fileName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // make sure it's in the cache
        self.cachedData = [[NSData alloc] initWithContentsOfFile:filePath];
    }
  
    return self.cachedData;
}

// maintaines cache size, removes oldest files as needed, reentrant
// I really like how much coding work is possible with objective languages with plenty of frameworks and patterns built in.
- (void) insureRoomInCacheForBytes : (NSUInteger) sizeNeeded {
     
    // how much room used by all files in this path ?
    unsigned long long  cacheUsed = 0;
    unsigned long long  fileSize;
    
    // find total cache bytes used for all files in cache
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.cachePath path] error:nil];
    for(NSString * file in files) {
        NSString * filePath = [[self.cachePath path] stringByAppendingPathComponent:file];
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if(attributes != nil) {
            fileSize = [attributes fileSize];
            cacheUsed += fileSize;
        }
    }
    
    // NSLog(@"max cache size is %u and cache used is %llu and sizeNeeded is %u", MAX_ALLOWED_CACHE_SIZE, cacheUsed, sizeNeeded);
      
    if (cacheUsed + sizeNeeded > MAX_ALLOWED_CACHE_SIZE) {
        // need to remove enough files to make room

        NSMutableString * olderFilePath = [[NSMutableString alloc] init];
        NSDate *olderFileDate = [NSDate date]; 
        NSDate *fileDate; 
        
        NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.cachePath path] error:nil];
        for(NSString * file in files) {
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
