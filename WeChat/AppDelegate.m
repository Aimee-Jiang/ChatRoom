//
//  AppDelegate.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/6.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "WCNavigationController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"%@",path);
    
    [WCNavigationController setupNavTheme];
    
    // 从沙里加载用户的数据到单例
    [[WCUserInfo sharedWCUserInfo] loadUserInfoFromSanbox];
    
    // 判断用户的登录状态，YES 直接来到主界面
    if([WCUserInfo sharedWCUserInfo].loginStatus){
        UIStoryboard *storayobard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storayobard.instantiateInitialViewController;
        
        // 自动登录服务
        // 1秒后再自动登录
#warning 一般情况下，都不会马上连接，会稍微等等
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WCXMPPTool sharedWCXMPPTool] xmppUserLogin:nil];
        });
        
    }
    
    //注册应用接收通知
    if ([[UIDevice currentDevice].systemVersion doubleValue] > 8.0){
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    
    return YES;
}




@end
