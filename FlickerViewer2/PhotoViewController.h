//
//  PhotoViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoViewController : UIViewController <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (weak, nonatomic) NSDictionary * photo; // todo change to method instead ?

// refactor - made these methods 'public' so subclass can access, 
// todo refactor - now some of these can be moved out of public view...
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *visitButton;
@property (weak, nonatomic) IBOutlet UILabel *photoTitleLabel;

- (void) loadPhoto;


@property (strong, nonatomic) NSDictionary * photoDictionary;
@property (strong, nonatomic) NSURL * photoURL;
@property (strong, nonatomic) NSString * photoName;
@property (strong, nonatomic) NSString * photoId;

// subclass need this to update visit button, 
// objective-c - way to do this without making the method public ? 
//
- (void) setVisitButtonToMatchPhotoVacationPresence;

@end
