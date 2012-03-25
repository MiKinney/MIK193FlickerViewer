//
//  DTCustomColorAcessory.h
//  FlickerViewer2
//
//  Used with permission from :
// http://www.cocoanetics.com/2010/10/custom-colored-disclosure-indicators/
//
// slight changes to use ARC

#import <UIKit/UIKit.h>

@interface DTCustomColoredAccessory : UIControl

{
	UIColor *_accessoryColor;
	UIColor *_highlightedColor;
}

@property (nonatomic, strong) UIColor *accessoryColor;
@property (nonatomic, strong) UIColor *highlightedColor;

+ (DTCustomColoredAccessory *)accessoryWithColor:(UIColor *)color;

@end
