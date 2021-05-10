//
//  AppDelegate.m
//  Test
//
//  Created by MMM on 2021/1/4.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "FacematchController.h"
#import "PictureNamingController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
//    ViewController *vc = [[ViewController alloc] init];
//    FacematchController *vc = [[FacematchController alloc] init];
    PictureNamingController *vc = [[PictureNamingController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
