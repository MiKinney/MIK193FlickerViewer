//
//  MIKActivityIndicatorView.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/27/12.
//  Copyright (c) 2012 All rights reserved.
//  this is all about having an activity indicator with a background, so it shows up
//  todo - would think there's a simpler way ... without needing this class

#import "MIKActivityIndicatorView.h"

@interface MIKActivityIndicatorView() 

@end

@implementation MIKActivityIndicatorView

-(id) initWithView:(UIView *)parentView{
    
    CGRect viewBounds = parentView.bounds;
    
    self = [super initWithFrame:CGRectMake(0, 0, 64, 64)];
    [self setCenter:CGPointMake((viewBounds.origin.x + (viewBounds.size.width / 2)), viewBounds.origin.y + (viewBounds.size.height/2))];
    self.color = [UIColor whiteColor]; 
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.75;    

    [parentView addSubview:self];  
    
    return self;
    
}

@end
