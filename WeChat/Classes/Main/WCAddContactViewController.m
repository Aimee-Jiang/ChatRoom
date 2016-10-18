//
//  WCAddContactViewController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/19.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCAddContactViewController.h"

@interface WCAddContactViewController()<UITextFieldDelegate>

@end

@implementation WCAddContactViewController


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSString *user = textField.text;
    WCLog(@"%@",user);
    
    if(![textField isTelphoneNum]){
        [self showAlert:@"请输入正确的手机号码"];
        return YES;
    }
    
    if([user isEqualToString:[WCUserInfo sharedWCUserInfo].user]){
        
        [self showAlert:@"不能添加自己为好友"];
        return YES;
    }
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",user,domain];
    XMPPJID *friendJid = [XMPPJID jidWithString:jidStr];
    
    if([[WCXMPPTool sharedWCXMPPTool].rosterStorage userExistsWithJID:friendJid xmppStream:[WCXMPPTool sharedWCXMPPTool].xmppStream]){
        [self showAlert:@"当前好友已经存在"];
        return YES;
    }
    
    
    // 发送好友添加的请求
    [[WCXMPPTool sharedWCXMPPTool].roster subscribePresenceToUser:friendJid];
    
    return YES;
}

-(void)showAlert:(NSString *)msg{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:@"谢谢" otherButtonTitles:nil, nil];
    [alert show];
}
@end
