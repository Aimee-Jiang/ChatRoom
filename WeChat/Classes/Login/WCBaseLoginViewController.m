//
//  WCBaseLoginViewController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/8.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCBaseLoginViewController.h"
#import "AppDelegate.h"

@implementation WCBaseLoginViewController


- (void)login{
    
    /*
     * 官方的登录实现
     
     * 把用户名和密码放在WCUserInfo的单例
     
     
     * 调用 AppDelegate的一个login 连接服务并登录
     */
    
    //隐藏键盘
    [self.view endEditing:YES];
    
    [MBProgressHUD showMessage:@"正在登录中..." toView:self.view];
    
    [WCXMPPTool sharedWCXMPPTool].registerOperation = NO;
    __weak typeof(self) selfVc = self;
    
    [[WCXMPPTool sharedWCXMPPTool] xmppUserLogin:^(XMPPResultType type) {
        [selfVc handleResultType:type];
    }];
}


-(void)handleResultType:(XMPPResultType)type{
    // 主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view
         ];
        switch (type) {
            case XMPPResultTypeLoginSuccess:
                NSLog(@"登录成功");
                [self enterMainPage];
                break;
            case XMPPResultTypeLoginFailure:
                NSLog(@"登录失败");
                [MBProgressHUD showError:@"用户名或者密码不正确" toView:self.view];
                break;
            case XMPPResultTypeNetErr:
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
            default:
                break;
        }
    });
    
}


-(void)enterMainPage{
    
    // 更改用户的登录状态为YES
    [WCUserInfo sharedWCUserInfo].loginStatus = YES;
    
    // 把用户登录成功的数据，保存到沙盒
    [[WCUserInfo sharedWCUserInfo] saveUserInfoToSanbox];
    
    // 隐藏模态窗口
    [self dismissViewControllerAnimated:NO completion:nil];
    [UIStoryboard showInitialVCWithName:@"Main"];
}

@end
