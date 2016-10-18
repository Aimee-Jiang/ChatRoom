//
//  WCUserInfo.h
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/8.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
static NSString *domain = @"jww.local";
@interface WCUserInfo : NSObject

singleton_interface(WCUserInfo);

@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *pwd;


@property (nonatomic, assign) BOOL  loginStatus;


@property (nonatomic, copy) NSString *registerUser;
@property (nonatomic, copy) NSString *registerPwd;
@property (nonatomic, copy) NSString *jid;

-(void)loadUserInfoFromSanbox;


-(void)saveUserInfoToSanbox;
@end
