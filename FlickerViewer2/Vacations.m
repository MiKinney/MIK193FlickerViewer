//
//  Vacations.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Vacations.h"

@implementation Vacations


// a dictionary of open VacationsDocuments, keyed by vacationName
// this is where we store our open vacatons
+ (NSMutableDictionary *) myOpenVacations {
    static NSMutableDictionary * vacations = nil;
    if(!vacations) {
        vacations = [[NSMutableDictionary alloc] init];
    }    
    return vacations;
}

// URL to vacation directory, creates if non-existent, returns 'cached' value on subsequent calls, so to keep down 'disk' usage
// 
+ (NSURL *) vacationDirectory {
    // 
    #define VACATIONS_SUBFOLDER @"Vacations"
    
    static NSURL* directory = nil;
    
    if(!directory) {
        directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        directory = [directory URLByAppendingPathComponent:VACATIONS_SUBFOLDER isDirectory:YES];
        if(![[NSFileManager defaultManager] fileExistsAtPath:[directory path] isDirectory:nil]) {
            NSError * error;
            if(![[NSFileManager defaultManager] createDirectoryAtPath:[directory path] withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"%@ %@", NSStringFromSelector(_cmd), error.description); 
            }
        }
    }  
    
    return directory;    
}


//private method for use within Vacations class
+ (NSString *) getDefaultVacationName {
    return @"My Vacation";
}

// private method, returns array of complete vacation URL's in persistent store
+ (NSArray *) getVacationURLs {
    
    NSError * error;
    NSArray * properties = [[NSArray alloc] initWithObjects:NSURLNameKey, nil];
    NSArray * vacations = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[Vacations vacationDirectory] includingPropertiesForKeys:properties options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    if(!vacations) {
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), error.description);     
    }
    
    return vacations;    
}

// returns array of vacationNames  extracted from vacaton urls path in persistent store
// since coming from NSURL pathComponent, these are NSStrings. 
+ (NSArray *) getVacationNames {
    NSArray * vacations = [Vacations getVacationURLs];
    NSMutableArray * vacationNames = [[NSMutableArray alloc] init];
    for(NSURL * vacation in vacations) {
        [vacationNames addObject:[[vacation pathComponents] lastObject]]; // last object is filename and thus vacation name
    }
    
    return vacationNames;
}

// true if vacation persisted,
+(BOOL) vacationExists:(NSString *)vacationName {
    BOOL exists = NO;
    
    NSArray * vacationNames = [Vacations getVacationNames];
    for(NSString * vacation in vacationNames) {
        if([vacation isEqualToString:vacationName]) {
            exists = YES;
            break;
        }
    }
    
    return exists;    
}

#define SELECTED_VACATION_NAME_KEY @"selectedVacationNameKey"

// note how the set and get class method use the store not only for peristance, but to avoid need of an instance variable
+ (void) setSelectedVacationName:(NSString *)vacationName {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults]; 
    NSString * persistedVacationName = [[NSMutableString alloc] initWithString:vacationName];
    [defaults setObject:persistedVacationName forKey:SELECTED_VACATION_NAME_KEY];
    [defaults synchronize]; // save it    
}

// return persisted name
// yes, this access's persisted store every time it's called... but should be fast enough
+ (NSString *) getSelectedVacationName {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults]; 
    NSString * selectedVacationName = [defaults stringForKey:SELECTED_VACATION_NAME_KEY];
    if(!selectedVacationName) { // first time app runs, no string - since we don't have it defined in any bundle resource
        selectedVacationName = [[NSString alloc] initWithString:[Vacations getDefaultVacationName]];
        // persist it
        [Vacations setSelectedVacationName:selectedVacationName];
    }    
    return selectedVacationName;   
}



+ (void) getVacation:(NSString *)vacationName done:(void (^)(VacationDocument *))result {
    
    // make sure called with valid name...
    NSMutableString * newVacationName;     
    if(!vacationName || vacationName.length == 0) {
        // passed param non-existent or empty, use default name
        newVacationName = [[NSMutableString alloc] initWithString:[Vacations getDefaultVacationName]];
    } else {
        // passed param defined, use it 
        newVacationName = [[NSMutableString alloc] initWithString:vacationName];
    }
    
    VacationDocument * document = (VacationDocument*) [[Vacations myOpenVacations] objectForKey:newVacationName];
    if(!document) {
        // nothing open, note this inits the object, but it may or may not exist in the file system until after calling openVacation
        document = [[VacationDocument alloc] initWithVacationName:newVacationName inDirectory:[Vacations vacationDirectory]];
        // add to my collection of vacations
        [[Vacations myOpenVacations] setValue:document forKey:newVacationName];
    }      
    
    // this will openVacation (unless already open)
    [document openVacation:^(BOOL success) {
        if(success) {
            // done
            result(document); // new document
        } else {
            NSLog(@"%@ error opening vacation %@", NSStringFromSelector(_cmd), newVacationName);
            result(nil); // bad document
        }
    }];

}

+ (void) removeVacation:(NSString *)vacationName done:(void (^)(BOOL))result {
    id document = [[Vacations myOpenVacations] objectForKey:vacationName];
    if(document) {
        // todo - need to actually delete from persistEnt store !
        [[Vacations myOpenVacations] removeObjectForKey:vacationName];
    }
    result(YES); // ok, even if did not exist...
}



@end
