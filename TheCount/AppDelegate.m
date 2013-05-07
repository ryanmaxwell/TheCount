//
//  AppDelegate.m
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DataAccessor.h"

@implementation AppDelegate

@synthesize window = _window;

+ (void)initialize {
    // register some defaults - not written to disk, just initialised within memory (volatile).
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:NO], @"LeftHandMode",
								 nil];
    [defaults registerDefaults:appDefaults];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Add the main view controller's view to the window and display.
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    // saves user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSInteger visiblePage = self.mainViewController.pageControl.currentPage; // TODO
    
//    [defaults setInteger:visiblePage forKey:@"VisiblePage"];
    [defaults synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [[DataAccessor sharedDataAccessor] saveContext];
}


- (void)awakeFromNib {
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}



@end
