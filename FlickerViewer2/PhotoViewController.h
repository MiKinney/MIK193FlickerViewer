//
//  PhotoViewController.h
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/23/12.
//  Copyright (c) 2012  All rights reserved.
//  
//  This is the PhotoViewController class for all image views in the iPad and iPhone
//  

#import <UIKit/UIKit.h>


@interface PhotoViewController : UIViewController <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (weak, nonatomic) NSDictionary * photo; // todo change to method instead ?

//  - made these methods 'public' so Vacation subclass can access and I can hookup in Storyboard
//  Refactor - another way to do same thing ?
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *visitButton;
@property (weak, nonatomic) IBOutlet UILabel *photoTitleLabel;

// 
@property (strong, nonatomic) NSDictionary * photoDictionary;
@property (strong, nonatomic) NSURL * photoURL;
@property (strong, nonatomic) NSString * photoName;
@property (strong, nonatomic) NSString * photoId;

- (void) loadPhoto;


// subclass needs this to update visit button, 
// objective-c - way to do this without making the method public ? 
//
- (void) setVisitButtonToMatchPhotoVacationPresence;

@end
