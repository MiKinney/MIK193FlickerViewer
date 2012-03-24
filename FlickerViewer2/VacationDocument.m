//
//  VacationDocument.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/15/12.
//  Copyright (c) 2012  All rights reserved.
//
#import "VacationDocument.h"
#import "Photo+Create.h"


@interface VacationDocument()

// note redefining property from public ready only to private readwrite
@property (strong, readwrite, nonatomic) NSString * vacationName; // todo - check for leak

@end

@implementation VacationDocument

@synthesize vacationName = _vacationName;

- (NSString *) vacationName {
    if(!_vacationName) {
        _vacationName = [[NSString alloc] init];
    }
    return _vacationName;
}

- (BOOL) photoExists:(NSString *)photoID {
    return ([Photo photoExists:photoID inContext:self.managedObjectContext]);
}


- (Photo *) addPhoto:(NSDictionary *)photo {    
    return([Photo addPhoto:photo usingContext:self.managedObjectContext]);    
}

- (void) removePhoto:(NSString *)photoID {
    [Photo removePhoto:photoID usingContext:self.managedObjectContext];
}


- (VacationDocument*) initWithVacationName:(NSString *)vacationName inDirectory:(NSURL*) vacationDirectoryURL{
    
    self.vacationName = vacationName;
    
    NSURL * vacationURL = [vacationDirectoryURL URLByAppendingPathComponent:self.vacationName];
    
    // NSLog(@"%@ %@", NSStringFromSelector(_cmd), [vacationURL path]);
    
    self = [super initWithFileURL:vacationURL]; // in UIManagedDocument
    
    return self;    
}

- (void) openVacation:(void (^)(BOOL))result {
    
     BOOL success = NO;
    
     // NSLog(@"%@ %@", NSStringFromSelector(_cmd), [self.fileURL path]);
    
    // if the file does not exist, specified by fileURL path, then create it, here path is string with directory and file anem
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.fileURL path]]) {
        // create it
        [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            // success may be YES or NO, let caller handle it
            result (success);
        }];         
    } else if (self.documentState == UIDocumentStateClosed) {
        // it managedDocumentOpen's, but it's closed, so we have to open it to use it
        [self openWithCompletionHandler:^(BOOL success) {
            // success may be YES or NO, let caller handle it
            result (success);
        }];
    } else if (self.documentState == UIDocumentStateNormal) {
        // the  database is ready for use
        result (success = YES);
    } else if (self.documentState == UIDocumentStateInConflict) {
        // todo handle conflicts, probably see this used in iCloud exercise ?
        result (success = NO);//
    }    
}

- (void) closeVacation:(void (^)(BOOL))result {
    [self closeWithCompletionHandler:^(BOOL success) {
        result(success);
    }];
}















@end
