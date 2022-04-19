//
//  AgoraChatThreadListViewController.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraChatThreadListViewController.h"
#import "AgoraChatThreadListNavgation.h"
#import "AgoraChatUserDataModel.h"
#import "UserInfoStore.h"
#import "AgoraChatThreadViewController.h"
@interface AgoraChatThreadListViewController ()<EaseThreadListProtocol>

@property (nonatomic) AgoraChatThreadListNavgation *navBar;

@property (nonatomic) EaseThreadListViewController *chatController;


@end

@implementation AgoraChatThreadListViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)group chatViewModel:(EaseChatViewModel *)viewModel {
    if ([super init]) {
        self.chatController = [[EaseThreadListViewController alloc]initWithGroup:group chatViewModel:viewModel];
        self.chatController.delegate = self;
    }
    return self;
}

- (void)threadListCount:(int)count {
    self.navBar.title = [NSString stringWithFormat:@"All threads (%d)",count];
}

- (void)agoraChatThreadList:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EaseThreadConversation *conv = self.chatController.dataArray[indexPath.row];
    [AgoraChatClient.sharedClient.threadManager joinChatThread:conv.threadInfo.threadId completion:^(AgoraChatThread *thread, AgoraChatError *aError) {
        if (!aError || aError.code == 40004) {
            AgoraChatThreadViewController *VC = [[AgoraChatThreadViewController alloc]initThreadChatViewControllerWithCoversationid:conv.threadInfo.threadId conversationType:AgoraChatConversationTypeGroupChat chatViewModel:self.chatController.viewModel parentMessageId:@"" model:nil];
            VC.navTitle = thread ? thread.threadName:conv.threadInfo.threadName;
            VC.detail = self.chatController.group.groupName;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _setupChatSubviews];
}

- (AgoraChatThreadListNavgation *)navBar {
    if (!_navBar) {
        _navBar = [[AgoraChatThreadListNavgation alloc]initWithFrame:CGRectMake(0, 0, EMScreenWidth, EMNavgationHeight)];
        _navBar.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        __weak typeof(self) weakSelf = self;
        [_navBar setBackBlock:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _navBar;
}

- (void)_setupChatSubviews
{
    [self addChildViewController:self.chatController];
    [self.view addSubview:self.navBar];
    self.navBar.title = @"All Threads";
    self.navBar.detail = [NSString stringWithFormat:@"# %@",self.chatController.group.groupName];
    [self.view addSubview:self.chatController.view];
    [self.chatController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(EMNavgationHeight, 0, 0, 0));
    }];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

//userProfile
- (id<EaseUserProfile>)userProfile:(NSString *)huanxinID
{
    AgoraChatUserDataModel *model = nil;
    if ([huanxinID isEqualToString:@""] || huanxinID == nil) {
        return model;
    }
    AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:huanxinID];
    if(userInfo) {
        model = [[AgoraChatUserDataModel alloc]initWithUserInfo:userInfo];
    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[huanxinID]];
    }
    return model;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
