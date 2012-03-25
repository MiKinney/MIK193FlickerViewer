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
// creates the file if it does not exist, does not open it
// note returned document not valid until after result callback...
- (VacationDocument * ) initWithVacationName:(NSString*) vacationName inDirectory:(NSURL*) vacationDirectoryURL;

// returns YES if photo part of this vacation
- (BOOL) photoExists:(NSString *) photoID;

//add  photo to vacation if it doesn't already exist
// photo is a flicker dictionary
- (Photo *) addPhoto:(NSDictionary*) photo;

// remove photo, and adjust associated places and tag objects as needed
- (void) removePhoto:(NSString *) photoID;

@end
