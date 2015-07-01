//
//  AppDelegate.m
//  NKStampTool
//
//  Created by nanoka____ on 2015/07/01.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

/*========================================================
 ; AppDelegate
 ========================================================*/
@implementation AppDelegate

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc
{
    self.window = nil;
}

/*--------------------------------------------------------
 ; didFinishLaunchingWithOptions : アプリ起動時に呼び出される
 ;                            in : UIApplication * application
 ;                               : NSDictionary *launchOptions
 ;                           out : BOOL YES
 --------------------------------------------------------*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *oViewController = [[ViewController alloc] init];
    UINavigationController *oNavigationController = [[UINavigationController alloc] initWithRootViewController:oViewController];
    oViewController = nil;
    [oNavigationController setNavigationBarHidden:YES];
    self.window.rootViewController = oNavigationController;
    oNavigationController = nil;
    [self.window makeKeyAndVisible];
    return YES;
}

@end