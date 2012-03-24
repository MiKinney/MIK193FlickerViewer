//
//  PhotosTableViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"

@protocol PhotosDataSourceDelegate 

- (NSDictionary *) place;

@end

@interface PhotosTableViewController : UITableViewController 
@property (strong, nonatomic) NSArray *placePhotos;
@property (strong, nonatomic) NSDictionary *selectedPhoto;

@property (nonatomic,weak) id <PhotosDataSourceDelegate> dataSourceDelegate;

@end
