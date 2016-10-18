//
//  WCEditProfileViewController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/14.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCEditProfileViewController.h"
#import "XMPPvCardTemp.h"

@interface WCEditProfileViewController()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation WCEditProfileViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // 设置标题和TextField的默认值
    self.title = self.cell.textLabel.text;
    
    self.textField.text = self.cell.detailTextLabel.text;
    
    // 右边添加个按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClick)];
}


-(void)saveBtnClick{
    // 更改Cell的detailTextLabel的text
    self.cell.detailTextLabel.text = self.textField.text;
    
    [self.cell layoutSubviews ];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // 调用代理
    if([self.delegate respondsToSelector:@selector(editProfileViewControllerDidSave)]){
        // 通知代理，点击保存按钮
        [self.delegate editProfileViewControllerDidSave];
    }
        

}
@end
