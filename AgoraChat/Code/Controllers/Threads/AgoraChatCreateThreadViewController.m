//
//  AgoraChatCreateThreadViewController.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraChatCreateThreadViewController.h"
#import "AgoraChatThreadListNavgation.h"
#import "AgoraChatUserDataModel.h"
#import "UserInfoStore.h"
#import "AgoraChatThreadViewController.h"

@interface AgoraChatCreateThreadViewController ()<EaseChatViewControllerDelegate>

@property (nonatomic) AgoraChatThreadListNavgation *navBar;

@property (nonatomic) EaseThreadCreateViewController *createViewController;

@property (nonatomic) AgoraChatGroup *group;

@end

@implementation AgoraChatCreateThreadViewController

- (instancetype)initWithType:(EMThreadHeaderType)type viewModel:(EaseChatViewModel *)viewModel message:(EaseMessageModel *)message {
    if ([super init]) {
        self.createViewController = [[EaseThreadCreateViewController alloc] initWithType:type viewModel:viewModel message:message];
        self.createViewController.delegate = self;
        [AgoraChatClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:message.message.to completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
            if (!aError) {
                self.group = aGroup;
            }
        }];
    }
    return self;
}

- (void)didSendMessage:(AgoraChatMessage *)message thread:(nonnull AgoraChatThread *)thread error:(nonnull AgoraChatError *)error {
    EaseMessageModel *model = [[EaseMessageModel alloc]initWithAgoraChatMessage:message];
    if (!thread.threadId.length) {
        [self showHint:@"conversationId is empty!"];
        return;
    }
    model.thread = thread;
    AgoraChatThreadViewController *VC = [[AgoraChatThreadViewController alloc] initThreadChatViewControllerWithCoversationid:thread.threadId conversationType:AgoraChatConversationTypeGroupChat chatViewModel:self.createViewController.viewModel parentMessageId:thread.messageId model:model];
    VC.createPush = YES;
    VC.navTitle = thread.threadName;
    VC.detail = self.group.groupName;
    [self.navigationController pushViewController:VC animated:YES];
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

- (void)_setupChatSubviews
{
    [self addChildViewController:self.createViewController];
    [self.view addSubview:self.navBar];
    self.navBar.title = @"New Thread";
    [self.view addSubview:self.createViewController.view];
    [self.createViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
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

@end
