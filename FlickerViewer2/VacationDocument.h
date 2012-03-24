//
//  VacationDocument.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/15/12.
//  Copyright (c) 
//
//  Each document is a UIManagedDocument specific a vacation with it's own managedObjectContext
//  this allows  opening multiple vacation documents at one time
//  but only one instance for each vacation name...

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface VacationDocument : UIManagedDocument

// the vacation name for this instance
@property (strong, readonly, nonatomic) NSString* vacationName;

// the complete URL including vacation name
// 
// - (VacationDocument *) initWithVacationFileURL:(NSURL*) vacation;

// the name of the vacation, builds the vacation URL internally
// note does NOT create the file on disk, to do that, you need to open it at least once
// Refactor - could use a init method that actually creates the file, but does not open it... oh well, this is just 'demo' code
- (VacationDocument *) initWithVacationName:(NSString*) vacationName inDirectory:(NSURL*) vacationDirectoryURL;

// opens vacation file specified in initializers  (unless already open)
// success is YES if operation succeeds, else NO
- (void) openVacation:(void(^)(BOOL success)) result;

// close also forces an auto save
- (void) closeVacation:(void(^)(BOOL success)) result;

// returns YES if photo part of this vacation
- (BOOL) photoExists:(NSString *) photoID;

//add  photo to vacation if it doesn't already exist
// photo is a flicker dictionary
- (Photo *) addPhoto:(NSDictionary*) photo;

// remove photo, and adjust associated places and tag objects as needed
- (void) removePhoto:(NSString *) photoID;

@end
