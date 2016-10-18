//
//  WCEditProfileViewController.h
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/14.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WCEditProfileViewControllerDelegate <NSObject>

-(void)editProfileViewControllerDidSave;


@end

@interface WCEditProfileViewController : UITableViewController

@property (nonatomic, strong) UITableViewCell *cell;

@property (nonatomic, weak) id<WCEditProfileViewControllerDelegate> delegate;

@end
