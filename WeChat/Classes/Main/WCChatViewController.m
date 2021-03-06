//
//  WCChatViewController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/20.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCChatViewController.h"
#import "WCInputView.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface WCChatViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>{

    NSFetchedResultsController *_resultsContr;

}
//inputView底部约束
@property (nonatomic, strong) NSLayoutConstraint *inputViewBottomConstraint;
//inputView高度约束
@property (nonatomic, strong) NSLayoutConstraint *inputViewHeightConstraint;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) HttpTool *httpTool;
@end

@implementation WCChatViewController

-(HttpTool *)httpTool{
    if (!_httpTool) {
        _httpTool = [[HttpTool alloc] init];
    }
    
    return _httpTool;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self loadMsgs];
    
}

-(void)keyboardWillShow:(NSNotification *)noti{
    NSLog(@"%@",noti);
    // 获取键盘的高度
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat kbHeight =  kbEndFrm.size.height;
    
    if([[UIDevice currentDevice].systemVersion doubleValue] < 8.0
       && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        kbHeight = kbEndFrm.size.width;
    }
        
    self.inputViewBottomConstraint.constant = kbHeight;
    
    //表格滚动到底部
    [self scrollToTableBottom];
    
}

-(void)keyboardWillHide:(NSNotification *)noti{
    // 隐藏键盘的进修 距离底部的约束永远为0
    self.inputViewBottomConstraint.constant = 0;
}


-(void)setupView{
  
    UITableView *tableView = [[UITableView alloc] init];
    //tableView.backgroundColor = [UIColor redColor];
    tableView.delegate = self;
    tableView.dataSource = self;

    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    WCInputView *inputView = [WCInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    
    inputView.textView.delegate = self;
    
    // 添加按钮事件
    [inputView.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputView];
    
    // 水平方向的约束
   NSDictionary *views = @{@"tableview":tableView,
                            @"inputView":inputView};
    
    NSArray *tabviewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableview]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tabviewHConstraints];
    
    NSArray *inputViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHConstraints];
    
    
    NSArray *vContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[tableview]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:vContraints];
  
    self.inputViewHeightConstraint = vContraints[2];
    self.inputViewBottomConstraint = [vContraints lastObject];
    NSLog(@"%@",vContraints);
}

#pragma mark 加载XMPPMessageArchiving数据库的数据显示在表格
-(void)loadMsgs{

    NSManagedObjectContext *context = [WCXMPPTool sharedWCXMPPTool].msgStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 过滤、排序
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[WCUserInfo sharedWCUserInfo].jid,self.friendJid.bare];
    NSLog(@"%@",pre);
    request.predicate = pre;
    
    // 时间升序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
   
    _resultsContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    NSError *err = nil;
    // 代理
    _resultsContr.delegate = self;
    
    [_resultsContr performFetch:&err];
    
    NSLog(@"%@",_resultsContr.fetchedObjects);
    if (err) {
        WCLog(@"%@",err);
    }
}

#pragma mark -表格的数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _resultsContr.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ChatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 获取聊天消息对象
    XMPPMessageArchiving_Message_CoreDataObject *msg =  _resultsContr.fetchedObjects[indexPath.row];
    
    
    // 判断是图片还是纯文本
    NSString *chatType = [msg.message attributeStringValueForName:@"bodyType"];
    if ([chatType isEqualToString:@"image"]) {
    
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"DefaultProfileHead_qq"]];
        cell.textLabel.text = nil;
    }else if([chatType isEqualToString:@"text"]){
    
        if ([msg.outgoing boolValue]) {
            //自己发
            cell.textLabel.text = msg.body;
        }else{
            //别人发的
            cell.textLabel.text = msg.body;
        }
        
        cell.imageView.image = nil;
    }
    return cell;
}


#pragma mark ResultController的代理
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
    [self scrollToTableBottom];
}

#pragma mark TextView的代理
-(void)textViewDidChange:(UITextView *)textView{
    //获取ContentSize
    CGFloat contentH = textView.contentSize.height;
    NSLog(@"textView的content的高度 %f",contentH);
    
    // 大于33，超过一行的高度/ 小于68 高度是在三行内
    if (contentH > 33 && contentH < 68 ) {
        self.inputViewHeightConstraint.constant = contentH + 18;
    }
    
    NSString *text = textView.text;
    
    
    // 换行就等于点击了的send
    if ([text rangeOfString:@"\n"].length != 0) {
        NSLog(@"发送数据 %@",text);
        
        // 去除换行字符
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self sendMsgWithText:text bodyType:@"text"];
        textView.text = nil;
        
        // 发送完消息 把inputView的高度改回来
        self.inputViewHeightConstraint.constant = 50;
        
    }else{
        NSLog(@"%@",textView.text);

    }
}


#pragma mark 发送聊天消息
-(void)sendMsgWithText:(NSString *)text bodyType:(NSString *)bodyType{
    
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    //image 图片
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
   
    // 设置内容
    [msg addBody:text];
     NSLog(@"%@",msg);
    [[WCXMPPTool sharedWCXMPPTool].xmppStream sendElement:msg];
}

#pragma mark 滚动到底部
-(void)scrollToTableBottom{
    NSInteger lastRow = _resultsContr.fetchedObjects.count - 1;
    
    if (lastRow < 0) {
        //行数如果小于0，不能滚动
        return;
    }
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark 选择图片
-(void)addBtnClick{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];

}

#pragma mark 选取后图片的回调
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%@",info);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // 取文件名 用户名 + 时间(201412111537)年月日时分秒
    NSString *user = [WCUserInfo sharedWCUserInfo].user;

    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    dataFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeStr = [dataFormatter stringFromDate:[NSDate date]];
    
    // 针对我的服务，文件名不用加后缀
    NSString *fileName = [user stringByAppendingString:timeStr];
    
    // 拼接上传路径
    NSString *uploadUrl = [@"http://localhost:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    
    // 使用HTTP put 上传
#warning 图片上传请使用jpg格式 因为我写的服务器只接接收jpg
    [self.httpTool uploadData:UIImageJPEGRepresentation(image, 0.75) url:[NSURL URLWithString:uploadUrl] progressBlock:nil completion:^(NSError *error) {
       
        if (!error) {
            NSLog(@"上传成功");
            [self sendMsgWithText:uploadUrl bodyType:@"image"];
        }
    }];
}

@end
