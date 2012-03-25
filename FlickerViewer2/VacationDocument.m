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


- (VacationDocument * ) initWithVacationName:(NSString *)vacationName inDirectory:(NSURL*) vacationDirectoryURL {
    
    self.vacationName = vacationName;
    
    NSURL * vacationURL = [vacationDirectoryURL URLByAppendingPathComponent:self.vacationName];
    
    self = [super initWithFileURL:vacationURL]; // in UIManagedDocument
    
    return self;    
}













@end
