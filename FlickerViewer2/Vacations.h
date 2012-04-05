//
//  Vacations.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/15/12.
//  Copyright (c) 2012 . All rights reserved.
//
// access to a vacation managed document
// may only have one document open at same time
// also convenience method to get all persisted vacations.

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

// returns persisted value of last vacation user had open
// 
+(NSString*) getLastOpenedVacationName;

// creates the managed document on disk if it doesn't exist, and returns it (or the existing one) in the callback 
+ (void) createVacation:(NSString *) vacationName done:(void (^)(VacationDocument * document))result; 

// opens vacationdocument (if not already open) vacation must already exist
// also c
+ (void) openVacation:(NSString *) vacationName done:(void (^)(BOOL success))result; 

// returns presently open managed vacation, nil if nothing open yet
+ (VacationDocument * ) getOpenManagedVacation;

// removes vacation from collection, does NOT close it nor remove from file system
+ (void) removeVacation:(NSString *) vacationName done:(void(^)(BOOL success)) result;

@end
