//
//  AgoraChatThreadViewController.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraChatThreadViewController.h"
#import "AgoraUserModel.h"
#import "AgoraChatUserDataModel.h"
#import "ACDDateHelper.h"
#import "UserInfoStore.h"

#import "ACDChatNavigationView.h"
#import "AgoraUserModel.h"
#import "AgoraChatThreadListNavgation.h"
#import "AgoraChatThreadEditViewController.h"
#import "AgoraChatThreadMembersViewController.h"
#import "ACDNotificationSettingViewController.h"
@interface AgoraChatThreadViewController ()<EaseChatViewControllerDelegate,AgoraChatroomManagerDelegate,EMBottomMoreFunctionViewDelegate>
@property (nonatomic, strong) EaseConversationModel *conversationModel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;
@property (nonatomic, strong) UIView* fullScreenView;
@property (strong, nonatomic) UIButton *backButton;

@property (nonatomic) AgoraChatThreadListNavgation *navBar;
@property (nonatomic, assign) AgoraChatConversationType conversationType;
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic) AgoraChatGroup *group;

@end

@implementation AgoraChatThreadViewController

- (instancetype)initThreadChatViewControllerWithCoversationid:(NSString *)conversationId conversationType:(AgoraChatConversationType)conType chatViewModel:(EaseChatViewModel *)viewModel parentMessageId:(NSString *)parentMessageId model:(EaseMessageModel *)model {
    if (self = [super init]) {
        _conversation = [AgoraChatClient.sharedClient.chatManager getConversation:conversationId type:conType createIfNotExist:YES isThread:YES];
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:_conversation];
        self.conversationType = conType;
        self.conversationId = conversationId;
        EaseChatViewModel *viewModel = [[EaseChatViewModel alloc]init];
        viewModel.displaySentAvatar = NO;
        viewModel.displaySentName = NO;
        if (conType != AgoraChatTypeGroupChat) {
            viewModel.displayReceiverName= NO;
        }
        _chatController = [[EaseThreadChatViewController alloc] initThreadChatViewControllerWithCoversationid:conversationId chatViewModel:viewModel parentMessageId:parentMessageId model:model];
        _chatController.delegate = self;
        if (model.message.chatThread.threadName.length) {
            self.navBar.title = model.message.chatThread.threadName;
        }
//        self.navBar.detail = [NSString stringWithFormat:@"# %@",self.chatController.group.groupName];
//        self.group = self.chatController.group;
    }
    return self;
}

- (void)setNavTitle:(NSString *)navTitle {
    self.navBar.title = navTitle;
}

- (void)setDetail:(NSString *)detail {
    self.navBar.detail = [NSString stringWithFormat:@"# %@",detail];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserInfo:) name:USERINFO_UPDATE object:nil];
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [self _setupChatSubviews];
    if (_conversation.unreadMessagesCount > 0) {
        [[AgoraChatClient sharedClient].chatManager ackConversationRead:_conversation.conversationId completion:nil];
    }
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


- (void)dealloc
{
    [[AgoraChatClient sharedClient].roomManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setupChatSubviews
{
    [self addChildViewController:_chatController];
    [self.view addSubview:self.navBar];
    [self.view addSubview:_chatController.view];
    
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(_chatController.view.mas_top);
    }];
    [_chatController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(AgoraChatVIEWTOPMARGIN + 60.0, 0, 0, 0));
    }];
 
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    UIButton *edit = [[self.chatController.tableView.tableHeaderView viewWithTag:678] viewWithTag:919];
    [edit addTarget:self action:@selector(editThread) forControlEvents:UIControlEventTouchUpInside];
}

- (void)editThread {
    AgoraChatThreadEditViewController *VC = [AgoraChatThreadEditViewController new];
    VC.threadId = self.conversationId;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)lookMembers {
    AgoraChatThreadMembersViewController *VC = [[AgoraChatThreadMembersViewController alloc] initWithThread:self.conversationId group:self.chatController.group];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - EaseChatViewControllerDelegate

//- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel
//{
////    if (messageModel.type == AgoraChatMessageTypePictMixText) {
////        AgoraChatMsgPicMixTextBubbleView* picMixBV = [[AgoraChatMsgPicMixTextBubbleView alloc] init];
////        [picMixBV setModel:messageModel];
////        AgoraChatMessageCell *cell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:picMixBV];
////        cell.model = messageModel;
////        cell.delegate = self;
////        return cell;
////    }
//
//    if(messageModel.message.body.type == AgoraChatMessageBodyTypeCustom) {
//        AgoraChatCustomMessageBody* body = (AgoraChatCustomMessageBody*)messageModel.message.body;
//        if([body.event isEqualToString:@"userCard"]){
////            AgoraChatUserCardMsgView* userCardMsgView = [[AgoraChatUserCardMsgView alloc] init];
////            userCardMsgView.backgroundColor = [UIColor whiteColor];
////            [userCardMsgView setModel:messageModel];
////            AgoraChatMessageCell* userCardCell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:userCardMsgView];
////            userCardCell.model = messageModel;
////            userCardCell.delegate = self;
////            return userCardCell;
//        }
//    }
//    return nil;
//}

//typing 1v1 single chat only
- (void)peerTyping
{
    self.titleDetailLabel.text = @"other party is typing";
}

//1v1 single chat only
- (void)peerEndTyping
{
    self.titleDetailLabel.text = nil;
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


- (void)avatarDidSelected:(id<EaseUserProfile>)userData
{
    if (userData && userData.easeId) {
        [self personData:userData.easeId];
    }
}

- (void)didSendMessage:(AgoraChatMessage *)message error:(AgoraChatError *)error
{
    if (error) {
        [self showHint:error.errorDescription];
    }
}

#pragma mark - AgoraChatMessageCellDelegate


- (void)messageCellDidSelected:(EaseMessageCell *)aCell
{
    if (!aCell.model.message.isReadAcked) {
        [[AgoraChatClient sharedClient].chatManager sendMessageReadAck:aCell.model.message.messageId toUser:aCell.model.message.conversationId completion:nil];
    }
}

- (void)messageAvatarDidSelected:(EaseMessageModel *)model
{
    [self personData:model.message.from];
}

#pragma mark - data

- (void)resetUserInfo:(NSNotification *)notification
{
    NSArray *userinfoList = (NSArray *)notification.userInfo[USERINFO_LIST];
    if (!userinfoList && userinfoList.count == 0)
        return;
    
    NSMutableArray *userInfoAry = [[NSMutableArray alloc]init];

    
    [self.chatController setUserProfiles:userInfoAry];
}

- (void)personData:(NSString*)contanct
{
   
}

- (void)backAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AgoraChatGroupManagerDelegate
- (void)popThreadChat {
    [self popDestinationVC];
}

#pragma mark - AgoraChatroomManagerDelegate

- (void)userDidJoinChatroom:(AgoraChatroom *)aChatroom
                       user:(NSString *)aUsername
{
    if (self.conversation.type == AgoraChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:self.conversation.conversationId]) {
        NSString *str = [NSString stringWithFormat:@"%@ join chat room", aUsername];
        [self showHint:str];
    }
}

- (void)userDidLeaveChatroom:(AgoraChatroom *)aChatroom
                        user:(NSString *)aUsername
{
    if (self.conversation.type == AgoraChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:self.conversation.conversationId]) {
        NSString *str = [NSString stringWithFormat:@"%@ leave chat room", aUsername];
        [self showHint:str];
    }
}

- (void)didDismissFromChatroom:(AgoraChatroom *)aChatroom
                        reason:(AgoraChatroomBeKickedReason)aReason
{
    if (aReason == 0)
        [self showHint:[NSString stringWithFormat:@"removed from chat room %@", aChatroom.subject]];
    if (aReason == 1)
        [self showHint:[NSString stringWithFormat:@"chatroom %@ has dissolved", aChatroom.subject]];
    if (aReason == 2)
        [self showHint:@"your account is offline"];
    if (self.conversation.type == AgoraChatTypeChatRoom && [aChatroom.chatroomId isEqualToString:self.conversation.conversationId]) {
        [self backAction];
    }
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom removedMutedMembers:(NSArray *)aMutes
{
    if ([aMutes containsObject:AgoraChatClient.sharedClient.currentUsername]) {
        [self showHint:@"your gag order is lifted"];
    }
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom addedMutedMembers:(NSArray *)aMutes muteExpire:(NSInteger)aMuteExpire
{
    if ([aMutes containsObject:AgoraChatClient.sharedClient.currentUsername]) {
        [self showHint:@"you're under a gag order"];
    }
}

- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom addedWhiteListMembers:(NSArray *)aMembers
{
    if ([aMembers containsObject:AgoraChatClient.sharedClient.currentUsername]) {
        [self showHint:@"you have been whitelisted"];
    }
}

- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom removedWhiteListMembers:(NSArray *)aMembers
{
    if ([aMembers containsObject:AgoraChatClient.sharedClient.currentUsername]) {
        [self showHint:@"you have been removed from the whitelist"];
    }
}

- (void)chatroomAllMemberMuteChanged:(AgoraChatroom *)aChatroom isAllMemberMuted:(BOOL)aMuted
{
    [self showHint:[NSString stringWithFormat:@"all member mute %@", aMuted ? @"open" : @"close"]];
}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom addedAdmin:(NSString *)aAdmin
{
    [self showHint:[NSString stringWithFormat:@"%@ become an administrator", aAdmin]];
}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom removedAdmin:(NSString *)aAdmin
{
    [self showHint:[NSString stringWithFormat:@"%@ demoted to common member", aAdmin]];
}

- (void)chatroomOwnerDidUpdate:(AgoraChatroom *)aChatroom newOwner:(NSString *)aNewOwner oldOwner:(NSString *)aOldOwner
{
    [self showHint:[NSString stringWithFormat:@"%@ turn over the chat room owner to %@", aOldOwner, aNewOwner]];
}

- (void)chatroomAnnouncementDidUpdate:(AgoraChatroom *)aChatroom announcement:(NSString *)aAnnouncement
{
    [self showHint:@"chat room bulletin content has been updated, please check"];
}

- (void)showSheet {
    NSMutableArray<EaseExtendMenuModel*> *extMenuArray = [[NSMutableArray<EaseExtendMenuModel*> alloc]init];
    EaseExtendMenuModel *memberModel = [[EaseExtendMenuModel alloc]initWithData:ImageWithName(@"thread_members") funcDesc:@"Thead Members" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
        [self lookMembers];
    }];
    memberModel.showMore = YES;
    [extMenuArray addObject:memberModel];
    EaseExtendMenuModel *nofitfyModel = [[EaseExtendMenuModel alloc]initWithData:ImageWithName(@"thread_notifications") funcDesc:@"Thead Notifications" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
        [self pushThreadNotifySetting];
    }];
    nofitfyModel.showMore = YES;
    [extMenuArray addObject:nofitfyModel];
    if ([self.chatController.isAdmin isEqualToString:@"1"] || [[self.chatController.owner lowercaseString] isEqualToString:[[AgoraChatClient.sharedClient currentUsername] lowercaseString]]) {
        EaseExtendMenuModel *editModel = [[EaseExtendMenuModel alloc]initWithData:ImageWithName(@"thread_edit_black") funcDesc:@"Edit Thread" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
            [self editThread];
        }];
        editModel.showMore = YES;
        [extMenuArray addObject:editModel];
    }
    EaseExtendMenuModel *leaveModel = [[EaseExtendMenuModel alloc]initWithData:ImageWithName(@"thread_leave") funcDesc:@"Leave Thread" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
        [self showAlert:1];
    }];
    [extMenuArray addObject:leaveModel];
    if ([self.chatController.isAdmin isEqualToString:@"1"]) {
        EaseExtendMenuModel *destoryModel = [[EaseExtendMenuModel alloc]initWithData:ImageWithName(@"groupInfo_deband") funcDesc:@"Disband Thread" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
            [self showAlert:2];
        }];
        destoryModel.funcDescColor = COLOR_HEX(0xFF14CC);
        [extMenuArray addObject:destoryModel];
    }
    [EMBottomMoreFunctionView showMenuItems:extMenuArray showReaction:NO delegate:self ligheViews:nil animation:YES userInfo:nil];
}

- (void)pushThreadNotifySetting {
    ACDNotificationSettingViewController *controller = [[ACDNotificationSettingViewController alloc] init];
    controller.notificationType = AgoraNotificationSettingTypeThread;
    controller.conversationID = self.conversationId;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - EMBottomMoreFunctionViewDelegate
- (void)bottomMoreFunctionView:(EMBottomMoreFunctionView *)view didSelectedMenuItem:(EaseExtendMenuModel *)model {
    if (model.itemDidSelectedHandle) {
        model.itemDidSelectedHandle(model.funcDesc, YES);
    }
    
    [EMBottomMoreFunctionView hideWithAnimation:YES needClear:NO];
}


#pragma mark getter and setter
- (AgoraChatThreadListNavgation *)navBar {
    if (!_navBar) {
        _navBar = [[AgoraChatThreadListNavgation alloc]init];
        _navBar.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        __weak typeof(self) weakSelf = self;
        [_navBar setBackBlock:^{
            if (weakSelf.createPush == YES) {
                [weakSelf popDestinationVC];
            } else {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
        [_navBar hiddenMore:NO];
        [_navBar setMoreBlock:^{
            [weakSelf showSheet];
        }];
        
    }
    return _navBar;
}


- (void)popDestinationVC {
    UIViewController *tmp;
    for (UIViewController *VC in self.navigationController.viewControllers) {
        if ([VC isKindOfClass:[NSClassFromString(@"ACDChatViewController") class]]) {
            tmp = VC;
            break;
        }
    }
    if (tmp) {
        [self.navigationController popToViewController:tmp animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)threadNameChange:(NSString *)threadName {
    self.navBar.title = threadName;
    if (self.chatController.group) {
        self.navBar.detail = self.chatController.group.groupName;
    }
}

- (void)pushThreadList {
    [AgoraChatClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:self.conversationId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        if (!aError) {
            EaseThreadListViewController *VC = [[EaseThreadListViewController alloc] initWithGroup:aGroup chatViewModel:self.chatController.viewModel];
            [self.navigationController pushViewController:VC animated:YES];
        } else {
            [self showHint:aError.errorDescription];
        }
    }];
}

- (void)showAlert:(int)type {
    NSString *title = [NSString stringWithFormat:@"%@ this Thread?",type == 1 ? @"Leave":@"Disband"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:type == 1 ? @"Leave":@"Disband" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (type == 1) {
            [self leaveThread];
        } else {
            [self destoryThread];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)leaveThread {
    [AgoraChatClient.sharedClient.threadManager leaveChatThread:self.conversationId completion:^(AgoraChatError *aError) {
        if (!aError) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showHint:aError.errorDescription];
        }
    }];
}

- (void)destoryThread {
    [AgoraChatClient.sharedClient.threadManager destroyChatThread:self.conversationId completion:^(AgoraChatError *aError) {
        if (!aError) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showHint:aError.errorDescription];
        }
    }];
}

@end
