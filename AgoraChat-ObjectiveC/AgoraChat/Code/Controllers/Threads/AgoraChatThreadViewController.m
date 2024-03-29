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
#import "ACDContactListController.h"
#import "ACDGroupListViewController.h"
#import "AgoraChat_Demo-Swift.h"
#import "EaseDefines.h"
#import "AgoraChatMessage+ShowText.h"
#import "AgoraChatURLPreviewCell.h"
#import "ACDReportMessageViewController.h"
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
@property (nonatomic) NSMutableArray <__kindof AgoraChatMessage*> *forwardMessages;

@property (nonatomic) AgoraEditBar *editBar;

@property (nonatomic) BOOL editMode;

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
    self.forwardMessages = [NSMutableArray array];
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

#pragma mark - EaseChatViewControllerDelegate
- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel {
    switch (messageModel.message.body.type) {
        case AgoraChatMessageTypeText:
            if (messageModel.isUrl) {
                AgoraChatURLPreviewCell *cell = [[AgoraChatURLPreviewCell alloc] initWithDirection:messageModel.direction chatType:messageModel.message.chatType messageType:messageModel.type viewModel:self.chatController.viewModel];
                messageModel.type = AgoraChatMessageTypeExtURLPreview;
                cell.delegate = self.chatController;
                cell.model = messageModel;
                return cell;
            }
            break;
        default:
            break;
    }
    return nil;
}
- (void)peerTyping
{
    self.titleDetailLabel.text = @"Typing...";
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

- (NSMutableArray<EaseExtendMenuModel *> *)messageLongPressExtMenuItemArray:(NSMutableArray<EaseExtendMenuModel*>*)defaultLongPressItems messageModel:(nonnull EaseMessageModel *)messageModel{
    __weak typeof(self) weakSelf = self;
    __block EaseMessageModel *msgModel = messageModel;
    if(msgModel.direction == AgoraChatMessageDirectionReceive) {
        if (msgModel.message.body.type == AgoraChatMessageBodyTypeText || msgModel.message.body.type == AgoraChatMessageBodyTypeImage || msgModel.message.body.type == AgoraChatMessageBodyTypeFile || msgModel.message.body.type == AgoraChatMessageBodyTypeVideo || msgModel.message.body.type == AgoraChatMessageBodyTypeVoice) {
            EaseExtendMenuModel *reportItem = [[EaseExtendMenuModel alloc]initWithData:[UIImage imageNamed:@"report"] funcDesc:@"Report" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
                [weakSelf pushToReportMessageViewController:messageModel];
            }];
            [defaultLongPressItems addObject:reportItem];
        }
    }
    return defaultLongPressItems;
}

- (void)pushToReportMessageViewController:(EaseMessageModel *)messageModel {
    ACDReportMessageViewController *vc = [[ACDReportMessageViewController alloc] initWithReportMessage:messageModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (AgoraEditBar *)editBar {
    if (!_editBar) {
        _editBar = [[AgoraEditBar alloc] initWithFrame:CGRectMake(0, EMScreenHeight-kBottomSafeHeight-54, EMScreenWidth, kBottomSafeHeight+54)];
        [_editBar hiddenWithTag:AgoraEditBarOperationDelete];
    }
    return _editBar;
}


- (void)messageListEntryEditModeThenOperation:(EditBarOperationType)type {
    switch (type) {
        case EditBarOperationTypeDelete: {
            [self removeLocalHistoryMessages];
        }
            break;
        case EditBarOperationTypeForward: {
            [self chooseForwardTargets];
        }
            break;
        default:
            break;
    }

}

- (BOOL)messageListEntryEditModeWhetherShowBottom {
    [self.view addSubview:self.chatController.toolBar];
    [self.chatController.toolBar hiddenWithOperation:EditBarOperationTypeDelete];
    [self.navBar editMode:YES];
    return YES;
}


- (void)chooseForwardTargets {
    [self fillForwardMessages];
    [self recoverNormalState];
    ACDContactListController *contact = [[ACDContactListController alloc] init];
    ACDGroupListViewController *group = [[ACDGroupListViewController alloc] init];
    contact.forward = YES;
    group.forward = YES;
    contact.selectedBlock = ^(NSString * _Nonnull contactId) {
        [self forwardCombineMessages:contactId chat:YES];
    };
    group.selectedBlock = ^(NSString * _Nonnull groupId) {
        [self forwardCombineMessages:groupId chat:NO];
    };
    
    ForwardTargetsViewController *vc = [[ForwardTargetsViewController alloc] initWithViewControllers:@[contact,group] indicators:@[@"Contact",@"Group"]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)forwardCombineMessages:(NSString *)target chat:(BOOL)chat{
    NSMutableArray <__kindof NSString*>*ids = [NSMutableArray array];
    for (AgoraChatMessage *message in self.forwardMessages) {
        [ids addObject:message.messageId];
    }
    NSString *summary = @"";
    for (int i = 0; i < self.forwardMessages.count; i++) {
        if (i > 2) {
            if (IsStringEmpty(summary)) {
                summary = @"Introduction to merge forwarded messages summary,to show combine message detail";
            }
            break;
        } else {
            AgoraChatMessage *message = self.forwardMessages[i];
            AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:message.from];
            AgoraChatUserDataModel *model = [[AgoraChatUserDataModel alloc]initWithUserInfo:userInfo];
            NSString *nickName = IsStringEmpty(model.showName) ? message.from:model.showName;
            if (i == 0) {
                summary = [NSString stringWithFormat:@"%@:%@",nickName,message.showText];
            } else {
                summary = [NSString stringWithFormat:@"%@\n%@:%@",summary,nickName,message.showText];
            }
        }
    }
    AgoraChatCombineMessageBody *body = [[AgoraChatCombineMessageBody alloc] initWithTitle:@"Chat History" summary:summary compatibleText:@"The version is low and unable to display the content." messageIdList:ids];
    AgoraChatMessage *message = [[AgoraChatMessage alloc] initWithConversationID:target body:body ext:nil];
    message.chatType = chat ? AgoraChatTypeChat:AgoraChatTypeGroupChat;
    [AgoraChatClient.sharedClient.chatManager sendMessage:message progress:nil completion:^(AgoraChatMessage * _Nullable message, AgoraChatError * _Nullable error) {
        if (!error && message != nil) {
            [self showHint:@"Forward successful!"];
        } else {
            [self showHint:error.errorDescription];
        }
    }];
}

- (void)fillForwardMessages {
    [self.forwardMessages removeAllObjects];
    for (id obj in self.chatController.dataArray) {
        if ([obj isKindOfClass:[EaseMessageModel class]]) {
            if (((EaseMessageModel *)obj).selected) {
                AgoraChatMessage *message = ((EaseMessageModel *)obj).message;
                [self.forwardMessages addObject:message];
            }
        }
    }
}

- (void)removeLocalHistoryMessages {
    if (self.forwardMessages.count >= 50) {
        [self showHint:@"Remove history message reach limit."];
        return;
    }
    [self fillForwardMessages];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Message" message:[NSString stringWithFormat:@"Delete %lu messages form database",(unsigned long)self.forwardMessages.count] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray <__kindof NSString *>* ids = [NSMutableArray array];
        for (AgoraChatMessage *message in self.forwardMessages) {
            [ids addObject:message.messageId];
        }
        [AgoraChatClient.sharedClient.chatManager removeMessagesFromServerWithConversation:self.conversation messageIds:ids completion:^(AgoraChatError * _Nullable aError) {
            if (aError) {
                [self showHint:aError.errorDescription];
            }
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }]];
    [self presentViewController:alert animated:YES completion:nil];
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
            [weakSelf navBarMoreAction];
        }];
        
    }
    return _navBar;
}

- (void)navBarMoreAction {
    if (self.navBar.back.isHidden) {
        [self recoverNormalState];
    } else {
        [self showSheet];
    }
}

- (void)recoverNormalState {
    self.editMode = NO;
    [self.navBar editMode:NO];
    for (id model in self.chatController.dataArray) {
        if ([model isKindOfClass:[EaseMessageModel class]]) {
            ((EaseMessageModel *)model).selected = NO;
        }
    }
    [self.editBar removeFromSuperview];
    self.chatController.editMode = NO;
    [self.chatController.toolBar dismiss];
    [self.chatController.tableView reloadData];
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
