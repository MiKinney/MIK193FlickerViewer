//
//  Vacations.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Vacations.h"

@implementation Vacations

static VacationDocument * managedVacation = nil;

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

// true if vacation exists in file system,
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

#define LAST_OPEN_VACATION_NAME_KEY @"lastOpenedVacationNameKey"

// note how the set and get class method use the store not only for peristance, but to avoid need of an instance variable
+ (void) persistLastOpenedVacationName:(NSString *)vacationName {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults]; 
    NSString * persistedVacationName = [[NSMutableString alloc] initWithString:vacationName];
    [defaults setObject:persistedVacationName forKey:LAST_OPEN_VACATION_NAME_KEY];
    [defaults synchronize]; // save it    
}

// return persisted name
// yes, this access's persisted store every time it's called... but should be fast enough
+ (NSString *) getLastOpenedVacationName {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults]; 
    NSString * selectedVacationName = [defaults stringForKey:LAST_OPEN_VACATION_NAME_KEY];
    if(!selectedVacationName) { // first time app runs, no string - since we don't have it defined in any bundle resource
        selectedVacationName = [[NSString alloc] initWithString:[Vacations getDefaultVacationName]];
        // persist it
        [Vacations persistLastOpenedVacationName:selectedVacationName];
    }    
    return selectedVacationName;   
}



+ (void) createVacation:(NSString *) vacationName done:(void (^)(VacationDocument* document))result {

    // make sure called with valid name...
    NSMutableString * newVacationName;     
    if(!vacationName || vacationName.length == 0) {
        // passed param non-existent or empty, use default name
        newVacationName = [[NSMutableString alloc] initWithString:[Vacations getDefaultVacationName]];
    } else {
        // passed param defined, use it 
        newVacationName = [[NSMutableString alloc] initWithString:vacationName];
    }

    VacationDocument * newDocument = [[VacationDocument alloc] initWithVacationName:newVacationName inDirectory:[Vacations vacationDirectory]];

    if(![[NSFileManager defaultManager] fileExistsAtPath:[newDocument.fileURL path]]) {
        // create it
        [newDocument saveToURL:newDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            
            if(success) {
                result (newDocument);
            } else {
                result (nil);
            }
       }];         
    } else {
       // document already exists
       result(newDocument); // success !
    }
}

+ (void) openVacation:(NSString *)vacationName done:(void (^)(BOOL success))result  {
    
    BOOL success = NO;
    
    // if there's a managed vacation already, and it's not us, make sure it's closed, cause we're reusing managedVacation
    if(managedVacation && (![managedVacation.vacationName isEqualToString:vacationName])) {
        // only one managed vacation at a time... since 
        VacationDocument * otherVacation = managedVacation; // we need to reuse the static value before this ones closed
        managedVacation = nil; // force new document creation below...
       [otherVacation closeWithCompletionHandler:^(BOOL success) {
            // don't care  // no need to wait for response, since we're opening a different vacation next
        }];
    } 
     
    if(!managedVacation) { // no managedVacation at all, or there is one and it's us (because it's not the otherVacaton)
        managedVacation = [[VacationDocument alloc] initWithVacationName:vacationName inDirectory:[Vacations vacationDirectory]];
    }
    
    if (managedVacation.documentState == UIDocumentStateClosed) {
        // closed so have to open it to use it
        [managedVacation openWithCompletionHandler:^(BOOL success) {  
            if(success) {
                // first time we open it, save it
                [Vacations  persistLastOpenedVacationName:vacationName];
            }
              result (success);
        }];
    } else if (managedVacation.documentState == UIDocumentStateNormal) {
        // the  database is already open and ready for use
         // no need to persistLastOpenedVacationName, since that happened when we first opened it
         result (success = YES);
    } else if (managedVacation.documentState == UIDocumentStateInConflict) {
        // todo handle conflicts, probably see this used in iCloud exercise ?
        result (success = NO);//
    }            
 }


// 
+ (VacationDocument *) getOpenManagedVacation  {
    
    if(managedVacation && managedVacation.documentState != UIDocumentStateClosed){
        return  managedVacation;
    }
    
    return nil;    
}


+ (void) removeVacation:(NSString *)vacationName done:(void (^)(BOOL))result {
  
    result(YES); // ok, even if did not exist...
}



@end
