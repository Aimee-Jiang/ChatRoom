//
//  WCRegisgerViewController.h
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/10.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WCRegisgerViewControllerDelegate <NSObject>

/**
 *  完成注册
 */
-(void)regisgerViewControllerDidFinishRegister;

@end
@interface WCRegisgerViewController : UIViewController

@property (nonatomic, weak) id<WCRegisgerViewControllerDelegate> delegate;

@end
