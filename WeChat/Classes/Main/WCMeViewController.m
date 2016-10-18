//
//  WCMeViewController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/13.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCMeViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"

@interface WCMeViewController()

- (IBAction)logoutBtnClick:(id)sender;
/**
 *  头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *headerView;
/**
 *  昵称
 */
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

/**
 *  微信号
 */
@property (weak, nonatomic) IBOutlet UILabel *weixinNumLabel;

@end

@implementation WCMeViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    // 显示当前用户个人信息

    //xmpp提供了一个方法，直接获取个人信息
   XMPPvCardTemp *myVCard =[WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    // 设置头像
    if(myVCard.photo){
        self.headerView.image = [UIImage imageWithData:myVCard.photo];
    }
    
    // 设置昵称
    self.nickNameLabel.text = myVCard.nickname;
    
    // 设置微信号[用户名]
    
    NSString *user = [WCUserInfo sharedWCUserInfo].user;
    self.weixinNumLabel.text = [NSString stringWithFormat:@"微信号:%@",user];
    
}


- (IBAction)logoutBtnClick:(id)sender {
    
    [[WCXMPPTool sharedWCXMPPTool] xmppUserlogout];
}
@end
