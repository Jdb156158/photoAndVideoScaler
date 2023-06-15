//
//  AppDelegate.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/4/7.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navnext = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc]init]];
    [self.window setRootViewController:navnext];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
