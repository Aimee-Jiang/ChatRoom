//
//  WCLoginViewController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/11.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCLoginViewController.h"
#import "WCRegisgerViewController.h"
#import "WCNavigationController.h"

@interface WCLoginViewController()<WCRegisgerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation WCLoginViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    // 设置TextField和Btn的样式
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
  
    [self.pwdField addLeftViewWithImage:@"Card_Lock"];
    
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
    //从沙盒获取用户名
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
    self.userLabel.text = user;
}


- (IBAction)loginBtnClick:(id)sender {
    
    // 保存数据到单例
    WCUserInfo *userInfo = [WCUserInfo sharedWCUserInfo];
    userInfo.user = self.userLabel.text;
    userInfo.pwd = self.pwdField.text;
    
    // 调用父类的登录
    [super login];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // 获取注册控制器
    id destVc = segue.destinationViewController;
    
    
    if ([destVc isKindOfClass:[WCNavigationController class]]) {
        WCNavigationController *nav = destVc;
        //获取根控制器
        
        if ([nav.topViewController isKindOfClass:[WCRegisgerViewController class]]) {
            WCRegisgerViewController *registerVc =  (WCRegisgerViewController *)nav.topViewController;
            // 设置注册控制器的代理
            registerVc.delegate = self;
        }
        
    }
    
}

#pragma mark regisgerViewController的代理
-(void)regisgerViewControllerDidFinishRegister{
    WCLog(@"完成注册");
    // 完成注册 userLabel显示注册的用户名
    self.userLabel.text = [WCUserInfo sharedWCUserInfo].registerUser;
    
    // 提示
    [MBProgressHUD showSuccess:@"请重新输入密码进行登录" toView:self.view];
    
    
}

@end
