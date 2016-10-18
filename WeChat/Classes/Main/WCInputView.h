//
//  WCInputView.h
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/11.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCInputView : UIView
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

+(instancetype)inputView;

@end
