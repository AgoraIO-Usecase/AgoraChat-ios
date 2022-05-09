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
#import "PresenceManager.h"
#import "ACDChatDetailViewController.h"


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

@end

@implementation ACDChatViewController

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(AgoraChatConversationType)conType {
    if (self = [super init]) {
        _conversation = [AgoraChatClient.sharedClient.chatManager getConversation:conversationId type:conType createIfNotExist:YES];
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:_conversation];
        self.conversationType = conType;
        self.conversationId = conversationId;
        
        EaseChatViewModel *viewModel = [[EaseChatViewModel alloc]init];
        viewModel.displaySentAvatar = NO;
        viewModel.displaySentName = NO;
        if (conType != AgoraChatTypeGroupChat) {
            viewModel.displayReceiverName= NO;
        }
      
        _contacts = [[AgoraChatClient sharedClient].contactManager getContacts];
        _chatController = [EaseChatViewController initWithConversationId:conversationId
                                                    conversationType:conType
                                                        chatViewModel:viewModel];

        [_chatController setTypingIndicator:[ACDDemoOptions sharedOptions].isChatTyping];
        _chatController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserInfo:) name:USERINFO_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presencesUpdated:) name:PRESENCES_UPDATE object:nil];
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [self _setupChatSubviews];
    if (_conversation.unreadMessagesCount > 0) {
        [[AgoraChatClient sharedClient].chatManager ackConversationRead:_conversation.conversationId completion:nil];
    }
    [self _updatePresenceStatus];
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

- (void)_setupNavigationBarTitle
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 06, 40)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = _conversationModel.showName;
    if(self.conversation.type == AgoraChatConversationTypeChat) {
        [[PresenceManager sharedInstance] subscribe:@[self.conversationId] completion:nil];
        AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:self.conversation.conversationId];
        if(userInfo && userInfo.nickName.length > 0)
            self.titleLabel.text = userInfo.nickName;
    }
    [titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView);
        make.left.equalTo(titleView).offset(5);
        make.right.equalTo(titleView).offset(-5);
    }];
    
    self.titleDetailLabel = [[UILabel alloc] init];
    self.titleDetailLabel.font = [UIFont systemFontOfSize:15];
    self.titleDetailLabel.textColor = [UIColor grayColor];
    self.titleDetailLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:self.titleDetailLabel];
    [self.titleDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(titleView);
    }];
  
}


#pragma mark - EaseChatViewControllerDelegate

- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel
{
//    if (messageModel.type == AgoraChatMessageTypePictMixText) {
//        AgoraChatMsgPicMixTextBubbleView* picMixBV = [[AgoraChatMsgPicMixTextBubbleView alloc] init];
//        [picMixBV setModel:messageModel];
//        AgoraChatMessageCell *cell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:picMixBV];
//        cell.model = messageModel;
//        cell.delegate = self;
//        return cell;
//    }

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
        _navigationView.rightButton.hidden = YES;
        _navigationView.leftLabel.text = self.navTitle;
        ACD_WS
        _navigationView.leftButtonBlock = ^{
            [weakSelf backAction];
        };

        _navigationView.chatButtonBlock = ^{
            [weakSelf goInfoPage];
        };

        _navigationView.rightButtonBlock = ^{
            [weakSelf goChatDetailPage];
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

- (void)presencesUpdated:(NSNotification*)noti
{
    NSArray*array = noti.object;
    if(self.conversation.type == AgoraChatConversationTypeChat) {
        if([array containsObject:self.conversation.conversationId]) {
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself _updatePresenceStatus];
            });
        }
    }
    
}

- (void)_updatePresenceStatus
{
    if(self.conversation.type == AgoraChatConversationTypeChat && self.conversation.conversationId.length > 0) {
        AgoraChatPresence*presence = [[PresenceManager sharedInstance].presences objectForKey:self.conversation.conversationId];
        if(presence) {
            NSInteger status = [PresenceManager fetchStatus:presence];
            NSString* imageName = [[PresenceManager whiteStrokePresenceImages] objectForKey:[NSNumber numberWithInteger:status]];
            NSString* showStatus = [[PresenceManager showStatus] objectForKey:[NSNumber numberWithInteger:status]];
            if(status == 0) {
                showStatus = [PresenceManager formatOfflineStatus:presence.lastTime];
            }
            [self.navigationView.chatImageView setPresenceImage:[UIImage imageNamed:imageName]];
            if(status != PRESENCESTATUS_OFFLINE && presence.statusDescription.length > 0)
                self.navigationView.presenceLabel.text = presence.statusDescription;
            else
                self.navigationView.presenceLabel.text = showStatus;
        }else{
            [self.navigationView.chatImageView setPresenceImage:[UIImage imageNamed:kPresenceOfflineDescription]];
            self.navigationView.presenceLabel.text = kPresenceOfflineDescription;
        }
    }
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

