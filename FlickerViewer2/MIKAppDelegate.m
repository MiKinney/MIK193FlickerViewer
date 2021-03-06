//
//  MIKAppDelegate.m
//  FlickerViewer2
//
//  Created by Michael Kinney on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewSelectorController.h"
#import "MIKAppDelegate.h"
#import "Vacations.h"


@implementation MIKAppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // if on iPad, setup up split view controllers delegate
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) { 
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        // get our detail view controller, which is my own container / controller for other controllers
        DetailViewSelectorController * detailViewSelectorController = [splitViewController.viewControllers lastObject]; // 
            
        // the DetailViewSelectorController use's the split view's show/hide methods to  control
		//  display of popover buttons in portrait / landscape mode for each controller in the detail view controller
        // 
        splitViewController.delegate = (id) detailViewSelectorController;  
		
    }
      
    // make sure we have at least a default vacation document on disk the first time user uses the app
    // open the last vacation viewed, if any, create the default if nothing yet persisted.
    //
    NSArray * vacationNames = [Vacations getVacationNames];
    if(vacationNames.count > 0)
    {
		// we already have created vacations, get the last one used and open it 
        [Vacations openVacation:[Vacations getLastOpenedVacationName] done:^(BOOL success) {
            // hopefully it opened, not sending a message in this 'demo'
        }];
		
    } else {
        // create the default since nothing exists
        [Vacations createVacation:@"" done:^(VacationDocument *document) {
            // open it so it's ready for use by default
            if(document) {
                [Vacations openVacation:document.vacationName done:^(BOOL success) {
                    // hopefully it opened, not sending a message in this 'demo'
                }];
			}
        }];
       
    }
                             
    return YES;
}

// 					
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // todo - close open vacations, but check first that UIManagedDocument doesn't do this on it's own.
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    NSLog(@"App active");
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


@end
