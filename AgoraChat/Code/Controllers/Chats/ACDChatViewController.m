//
//  ACDChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/5.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDChatViewController.h"
#import "ACDContactInfoViewController.h"
#import "AgoraUserModel.h"
#import "AgoraChatUserDataModel.h"
#import "ACDDateHelper.h"
#import "UserInfoStore.h"

#import "ACDChatNavigationView.h"
#import "ACDContactInfoViewController.h"
#import "AgoraUserModel.h"
#import "ACDGroupInfoViewController.h"
#import "ACDAddContactViewController.h"
#import "ACDChatDetailViewController.h"

#import "AgoraChatCallKitManager.h"
#import "AgoraChatCallCell.h"
#import "AgoraChatCallKit/AgoraChatCallKit.h"

@interface ACDChatViewController ()<EaseChatViewControllerDelegate, AgoraChatroomManagerDelegate, AgoraChatGroupManagerDelegate, EaseMessageCellDelegate>
@property (nonatomic, strong) EaseConversationModel *conversationModel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleDetailLabel;
@property (nonatomic, strong) UIView* fullScreenView;
@property (strong, nonatomic) UIButton *backButton;

@property (nonatomic, strong) ACDChatNavigationView *navigationView;
@property (nonatomic, assign) AgoraChatConversationType conversationType;
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSArray *contacts;

@property (nonatomic, strong) EaseChatViewModel *viewModel;


@end

@implementation ACDChatViewController

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(AgoraChatConversationType)conType {
    if (self = [super init]) {
        _conversation = [AgoraChatClient.sharedClient.chatManager getConversation:conversationId type:conType createIfNotExist:YES];
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:_conversation];
        self.conversationType = conType;
        self.conversationId = conversationId;
        
        _viewModel = [[EaseChatViewModel alloc]init];
        _viewModel.displaySentAvatar = NO;
        _viewModel.displaySentName = NO;
        if (conType != AgoraChatTypeGroupChat) {
            _viewModel.displayReceiverName= NO;
        }
      
        _contacts = [[AgoraChatClient sharedClient].contactManager getContacts];
        _chatController = [EaseChatViewController initWithConversationId:conversationId
                                                    conversationType:conType
                                                        chatViewModel:_viewModel];

        _chatController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserInfo:) name:USERINFO_UPDATE object:nil];
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [self _setupChatSubviews];
    if (_conversation.unreadMessagesCount > 0) {
        [[AgoraChatClient sharedClient].chatManager ackConversationRead:_conversation.conversationId completion:nil];
    }
    
    [NSNotificationCenter.defaultCenter addObserverForName:AGORA_CHAT_CALL_KIT_COMMMUNICATE_RECORD object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        NSArray<AgoraChatMessage *> *messages = (NSArray *)[note.object objectForKey:@"msg"];
        if (messages && messages.count > 0) {
            NSMutableArray *messageModels = [NSMutableArray array];
            for (AgoraChatMessage *message in messages) {
                EaseMessageModel *model = [[EaseMessageModel alloc] initWithAgoraChatMessage:message];
                [messageModels addObject:model];
            }
            [self.chatController.dataArray addObjectsFromArray:messageModels];
            if (!self.chatController.moreMsgId) {
                self.chatController.moreMsgId = messages.firstObject.messageId;
            }
            [self.chatController.tableView reloadData];
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


- (void)dealloc
{
    [[AgoraChatClient sharedClient].roomManager removeDelegate:self];
    [[AgoraChatClient sharedClient].groupManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setupChatSubviews
{
    [self addChildViewController:_chatController];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:_chatController.view];
    
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(_chatController.view.mas_top);
    }];
    [_chatController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(AgoraChatVIEWTOPMARGIN + 60.0, 0, 0, 0));
    }];
 
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
}


#pragma mark - EaseChatViewControllerDelegate

- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel
{
    if (messageModel.message.body.type == AgoraChatMessageTypeText) {
        if ([messageModel.message.ext[@"msgType"] isEqualToString:@"rtcCallWithAgora"]) {
            NSString *action = messageModel.message.ext[@"action"];
            if ([action isEqualToString:@"invite"]) {
                if (messageModel.message.chatType == AgoraChatTypeChat) {
                    return nil;
                }
            }
            AgoraChatCallCell *cell = [[AgoraChatCallCell alloc] initWithDirection:messageModel.direction chatType:messageModel.message.chatType messageType:messageModel.type viewModel:_viewModel];
            cell.delegate = self;
            cell.model = messageModel;
            return cell;
        }
    }
//    if (messageModel.type == AgoraChatMessageTypePictMixText) {
//        AgoraChatMsgPicMixTextBubbleView* picMixBV = [[AgoraChatMsgPicMixTextBubbleView alloc] init];
//        [picMixBV setModel:messageModel];
//        AgoraChatMessageCell *cell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:picMixBV];
//        cell.model = messageModel;
//        cell.delegate = self;
//        return cell;
//    }
    // TODO: call cell
    if(messageModel.message.body.type == AgoraChatMessageBodyTypeCustom) {
        AgoraChatCustomMessageBody* body = (AgoraChatCustomMessageBody*)messageModel.message.body;
        if([body.event isEqualToString:@"userCard"]){
//            AgoraChatUserCardMsgView* userCardMsgView = [[AgoraChatUserCardMsgView alloc] init];
//            userCardMsgView.backgroundColor = [UIColor whiteColor];
//            [userCardMsgView setModel:messageModel];
//            AgoraChatMessageCell* userCardCell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:userCardMsgView];
//            userCardCell.model = messageModel;
//            userCardCell.delegate = self;
//            return userCardCell;
        }
    }
    return nil;
}

//typing 1v1 single chat only
- (void)peerTyping
{
    NSAttributedString *titleString = [ACDUtil attributeContent:self.navTitle color:TextLabelBlackColor font:BFont(18.0f)];

    NSAttributedString *preTypingString = [ACDUtil attributeContent:@" (other party is typing)" color:TextLabelGrayColor font:Font(@"PingFang SC",14.0)];
    
    NSMutableAttributedString *mutAttributeString = [[NSMutableAttributedString alloc] init];
    [mutAttributeString appendAttributedString:titleString];
    [mutAttributeString appendAttributedString:preTypingString];
    self.navigationView.leftLabel.attributedText = mutAttributeString;

}

//1v1 single chat only
- (void)peerEndTyping
{
    self.navigationView.leftLabel.text = [NSString stringWithFormat:@"%@",self.navTitle];
}

//userProfile
- (id<EaseUserProfile>)userProfile:(NSString *)huanxinID
{
    AgoraChatUserDataModel *model = nil;
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

- (BOOL)messageLongPressExtShowReaction:(AgoraChatMessage *)message
{
    return [message.body isKindOfClass:AgoraChatTextMessageBody.class];
}

#pragma mark - AgoraChatMessageCellDelegate


- (void)messageCellDidSelected:(EaseMessageCell *)aCell
{
    if (!aCell.model.message.isReadAcked) {
        [[AgoraChatClient sharedClient].chatManager sendMessageReadAck:aCell.model.message.messageId toUser:aCell.model.message.conversationId completion:nil];
    }
    
    // TODO: fz 点击加入房间放到下次迭代了
//    if ([aCell.model.message.ext[@"msgType"] isEqualToString:@"rtcCallWithAgora"]) {
//        NSString *action = aCell.model.message.ext[@"action"];
//        if ([action isEqualToString:@"invite"]) {
//            if (aCell.model.message.chatType == AgoraChatTypeGroupChat) {
//                [AgoraChatCallKitManager.shareManager joinToMutleCall:aCell.model.message];
//            }
//        }
//    }
    
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
    for (AgoraChatUserInfo *userInfo in userinfoList) {
        if ([userInfo.userId isEqualToString:self.chatController.currentConversation.conversationId]) {
            [_navigationView.chatImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl]];
        }
        AgoraChatUserDataModel *model = [[AgoraChatUserDataModel alloc]initWithUserInfo:userInfo];
        [userInfoAry addObject:model];
    }
    
    [self.chatController setUserProfiles:userInfoAry];
}

- (void)personData:(NSString*)contanct
{
    AgoraUserModel *userModel = [[AgoraUserModel alloc] initWithHyphenateId:contanct];
    UIViewController *controller = nil;
    if ([self.contacts containsObject:contanct]) {
        controller = [[ACDContactInfoViewController alloc] initWithUserModel:userModel];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        controller = [[ACDAddContactViewController alloc]initWithUserModel:userModel];
        controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)backAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - AgoraChatGroupManagerDelegate

- (void)didLeaveGroup:(AgoraChatGroup *)aGroup reason:(AgoraChatGroupLeaveReason)aReason
{
    [self backAction];
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

#pragma mark getter and setter
- (ACDChatNavigationView *)navigationView {
    if (_navigationView == nil) {
        _navigationView = [[ACDChatNavigationView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 80.0f)];
        _navigationView.leftLabel.text = self.navTitle;
        ACD_WS
        _navigationView.leftButtonBlock = ^{
            [weakSelf backAction];
        };

        _navigationView.chatButtonBlock = ^{
            [weakSelf goInfoPage];
        };

        _navigationView.rightButton.hidden = NO;
        [_navigationView.rightButton setImage:[UIImage imageNamed:@"nav_bar_call"] forState:UIControlStateNormal];
        _navigationView.rightButtonBlock = ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Audio Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (weakSelf.conversationType == AgoraChatConversationTypeChat) {
                    [AgoraChatCallKitManager.shareManager audioCallToUser:weakSelf.conversationId];
                } else {
                    [AgoraChatCallKitManager.shareManager audioCallToGroup:weakSelf.conversationId viewController:weakSelf];
                }
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Video Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (weakSelf.conversationType == AgoraChatConversationTypeChat) {
                    [AgoraChatCallKitManager.shareManager videoCallToUser:weakSelf.conversationId];
                } else {
                    [AgoraChatCallKitManager.shareManager videoCallToGroup:weakSelf.conversationId viewController:weakSelf];
                }
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        };
    }
    return _navigationView;
}


- (void)goInfoPage {
    if (self.conversationType == AgoraChatConversationTypeChat) {
        [self goContactInfoWithContactId:self.conversationId];
    }
    
    if (self.conversationType == AgoraChatConversationTypeGroupChat) {
        [self goGroupInfoWithGroupId:self.conversationId];
    }

}


- (void)goContactInfoWithContactId:(NSString *)contactId {
    AgoraUserModel * model = [[AgoraUserModel alloc] initWithHyphenateId:contactId];
    ACDContactInfoViewController *vc = [[ACDContactInfoViewController alloc] initWithUserModel:model];
    vc.isHideChatButton = YES;
    
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)goGroupInfoWithGroupId:(NSString *)groupId {
    ACDGroupInfoViewController *vc = [[ACDGroupInfoViewController alloc] initWithGroupId:groupId];
    
    vc.accessType = ACDGroupInfoAccessTypeChat;
    vc.isHideChatButton = YES;
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goChatDetailPage {
    if (self.conversationType == AgoraChatConversationTypeChat) {
        [self goChatDetailWithContactId:self.conversationId];
    }
    
    if (self.conversationType == AgoraChatConversationTypeGroupChat) {
        [self goGroupDetailWithContactId:self.conversationId];
    }
}

- (void)goChatDetailWithContactId:(NSString *)contactId {
    ACDChatDetailViewController *vc = [[ACDChatDetailViewController alloc] initWithCoversation:self.conversation];
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)goGroupDetailWithContactId:(NSString *)contactId {
    ACDChatDetailViewController *vc = [[ACDChatDetailViewController alloc] initWithCoversation:self.conversation];

    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end

