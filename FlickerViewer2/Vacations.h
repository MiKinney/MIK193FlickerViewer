//
//  Vacations.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/15/12.
//  Copyright (c) 2012 . All rights reserved.
//
// a collection of VacationDocuments

#import <Foundation/Foundation.h>
#import "VacationDocument.h"

@interface Vacations : NSObject

// convinence methods to all persisted vacation files in app's directory
// returns an array of NSStrings of just vacation names, to access the document, use getVacation
// note this call goes to persistent store each time
+ (NSArray *) getVacationNames;

// returns true if vacation already exists in persistent store
// note this call goes to persistent store each time
+ (BOOL) vacationExists:(NSString *)vacationName;

// set's (and persists) vacation name 
// note this does not open the vacation, for that use getVacation 
// there is only one selected vacation name possible at any one time for all vacations 
+ (void) setSelectedVacationName:(NSString *) vacationName;
// get's set selected vacation name , returns default name if nothing yet persisted
// there is only one selected vacation name possible at any one time for all vacations 
+ (NSString *) getSelectedVacationName;



// provides existing vacationDocument and  opens document if not already open
// if necessary creates file on disk and adds the document first
// document == nil if error creating or opening document
// insures that only one instance of a UIManagedDocument exists and is open for any vacationName
+ (void) getVacation:(NSString*) vacationName done:(void(^)(VacationDocument * document)) result;

// removes vacation from collection, does NOT close it nor remove from file system
+ (void) removeVacation:(NSString *) vacationName done:(void(^)(BOOL success)) result;

@end
