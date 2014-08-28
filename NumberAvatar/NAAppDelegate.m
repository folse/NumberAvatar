//
//  NAAppDelegate.m
//  NumberAvatar
//
//  Created by Jennifer on 8/27/14.
//  Copyright (c) 2014 folse. All rights reserved.
//

#import "NAAppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"

@implementation NAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:APP_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Light" size:18.0],NSFontAttributeName,nil]];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [application setStatusBarHidden:NO];
    
    [MobClick startWithAppkey:UMENG_APP_KEY reportPolicy:SEND_INTERVAL channelId:@"AppStore"];
    
    [MobClick setAppVersion:AppVersionShort];
    [MobClick checkUpdate:@"发现新版本" cancelButtonTitle:@"跳过" otherButtonTitles:@"安装"];
    
     [self shareSDKSetup];
    
    return YES;
}

#pragma mark ShareSDK Setup

- (void)shareSDKSetup{
    
    [ShareSDK registerApp:@"2e54015892f2" useAppTrusteeship:NO];
    [ShareSDK ssoEnabled:YES];
    [ShareSDK allowExchangeDataEnabled:YES];
    [ShareSDK setStatPolicy:SSCStatPolicyLimitSize];
    
    //[ShareSDK connectSinaWeiboWithAppKey:SinaWeiboKey appSecret:SinaWeiboSecret redirectUri:@"http://www.qianmiaomiao.com"];
    
    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885" wechatCls:[WXApi class]];
    
    //[ShareSDK connectQZoneWithAppKey:QQSpaceKey appSecret:QQSpaceSecret qqApiInterfaceCls:nil tencentOAuthCls:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
