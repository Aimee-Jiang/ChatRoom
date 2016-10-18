//
//  WCProfileViewController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/14.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "WCEditProfileViewController.h"

@interface WCProfileViewController()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,WCEditProfileViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *haedView;//头像
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;//昵称

@property (weak, nonatomic) IBOutlet UILabel *weixinNumLabel;//微信号
@property (weak, nonatomic) IBOutlet UILabel *orgnameLabel;//公司
@property (weak, nonatomic) IBOutlet UILabel *orgunitLabel;//部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//职位
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;//电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;//邮件


@end

@implementation WCProfileViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"个人信息";
    [self loadVCard];
}

/**
 *  加载电子名片信息
 */
-(void)loadVCard{
    
    //xmpp提供了一个方法，直接获取个人信息
    XMPPvCardTemp *myVCard =[WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    // 设置头像
    if(myVCard.photo){
        self.haedView.image = [UIImage imageWithData:myVCard.photo];
    }
    
    // 设置昵称
    self.nicknameLabel.text = myVCard.nickname;
    
    // 设置微信号[用户名]
    
    self.weixinNumLabel.text = [WCUserInfo sharedWCUserInfo].user;
    
    self.orgnameLabel.text = myVCard.orgName;
    
    if (myVCard.orgUnits.count > 0) {
        self.orgunitLabel.text = myVCard.orgUnits[0];
        
    }
    
    self.titleLabel.text = myVCard.title;
    
#warning myVCard.telecomsAddresses 这个get方法，没有对电子名片的xml数据进行解析
    // 使用note字段充当电话
    self.phoneLabel.text = myVCard.note;
    
    
    //邮件解析
    if (myVCard.emailAddresses.count > 0) {
        //不管有多少个邮件，只取第一个
        self.emailLabel.text = myVCard.emailAddresses[0];
    }
    

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 获取cell.tag
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger tag = cell.tag;
    
    // 判断
    if (tag == 2) {//不做任务操作
        WCLog(@"不做任务操作");
        return;
    }
    
    if(tag == 0){
        WCLog(@"选择照片");
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"相册", nil];
        [sheet showInView:self.view];
        
    }else{
        WCLog(@"跳到下一个控制器");
        [self performSegueWithIdentifier:@"EditVCardSegue" sender:cell];
        
    }
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //获取编辑个人信息的控制
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[WCEditProfileViewController class]]) {
        WCEditProfileViewController *editVc = destVc;
        editVc.cell = sender;
        editVc.delegate = self;
    }
}

#pragma mark actionsheet的代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if(buttonIndex == 2){
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // 设置代理
    imagePicker.delegate =self;
    
    // 设置允许编辑
    imagePicker.allowsEditing = YES;
    
    if (buttonIndex == 0) {//照相
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{//相册
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    // 显示图片选择器
    [self presentViewController:imagePicker animated:YES completion:nil];
        
    
}


#pragma mark 图片选择器的代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    WCLog(@"%@",info);
    // 获取图片 设置图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    self.haedView.image = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 更新到服务器
    [self editProfileViewControllerDidSave];
    
   }


#pragma mark 编辑个人信息的控制器代理
-(void)editProfileViewControllerDidSave{
    //获取当前的电子名片信息
    XMPPvCardTemp *myvCard = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
    
    myvCard.photo = UIImagePNGRepresentation(self.haedView.image);
    
    myvCard.nickname = self.nicknameLabel.text;
    
    myvCard.orgName = self.orgnameLabel.text;
    
    if (self.orgunitLabel.text.length > 0) {
        myvCard.orgUnits = @[self.orgunitLabel.text];
    }
    
    myvCard.title = self.titleLabel.text;
    
    myvCard.note =  self.phoneLabel.text;

    if (self.emailLabel.text.length > 0) {
        myvCard.emailAddresses = @[self.emailLabel.text];
    }
    
    //更新 这个方法内部会实现数据上传到服务，无需程序自己操作
    [[WCXMPPTool sharedWCXMPPTool].vCard updateMyvCardTemp:myvCard];

    
}
@end
