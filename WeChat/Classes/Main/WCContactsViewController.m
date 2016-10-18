//
//  WCContactsViewController.m
//  WeChat
//
//  Created by Weiwei Jiang on 14/12/19.
//  Copyright (c) 2014年 Weiwei Jiang. All rights reserved.
//

#import "WCContactsViewController.h"
#import "WCChatViewController.h"

@interface WCContactsViewController()<NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *_resultsContrl;
}

@property (nonatomic, strong) NSArray *friends;

@end

@implementation WCContactsViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    // 从数据里加载好友列表显示
    [self loadFriends];
    
}

-(void)loadFriends{
    //使用CoreData获取数据
    // 1.上下文【关联到数据库XMPPRoster.sqlite】
    NSManagedObjectContext *context = [WCXMPPTool sharedWCXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    
    // 查哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 设置过滤和排序
    NSString *jid = [WCUserInfo sharedWCUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jid];
    request.predicate = pre;
    
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 执行请求获取数据
    _resultsContrl = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _resultsContrl.delegate = self;
    
    NSError *err = nil;
    [_resultsContrl performFetch:&err];
    if (err) {
        WCLog(@"%@",err);
    }
    
}


#pragma mark 当数据的内容发生改变后，会调用 这个方法
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    WCLog(@"数据发生改变");
    //刷新表格
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _resultsContrl.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    XMPPUserCoreDataStorageObject *friend = _resultsContrl.fetchedObjects[indexPath.row];
    switch ([friend.sectionNum intValue]) {//好友状态
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
        default:
            break;
    }
    cell.textLabel.text = friend.jidStr;
    
    return cell;
}

//实现这个方法，cell往左滑就会有个delete
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WCLog(@"删除好友");
        XMPPUserCoreDataStorageObject *friend = _resultsContrl.fetchedObjects[indexPath.row];
        
        XMPPJID *freindJid = friend.jid;
        [[WCXMPPTool sharedWCXMPPTool].roster removeUser:freindJid];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //获取好友
    XMPPUserCoreDataStorageObject *friend = _resultsContrl.fetchedObjects[indexPath.row];
    
    //选中表格进行聊天界面
    [self performSegueWithIdentifier:@"ChatSegue" sender:friend.jid];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id destVc = segue.destinationViewController;
    
    if ([destVc isKindOfClass:[WCChatViewController class]]) {
        WCChatViewController *chatVc = destVc;
        chatVc.friendJid = sender;
        
    }
}

@end
