//
//  WCNavigationController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/8.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCNavigationController.h"

@implementation WCNavigationController


+(void)initialize{
   
    
    
}

// 设置导航栏的主题
+(void)setupNavTheme{
    // 设置导航样式
    
    UINavigationBar *navBar = [UINavigationBar appearance];
   
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    
    // 设置栏的字体
    NSMutableDictionary *att = [NSMutableDictionary dictionary];
    att[NSForegroundColorAttributeName] = [UIColor whiteColor];
    att[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    
    [navBar setTitleTextAttributes:att];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

@end
