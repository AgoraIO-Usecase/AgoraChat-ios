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
#import "AgoraChatThreadViewController.h"
#import "AgoraChatCreateThreadViewController.h"
#import "AgoraChatThreadListViewController.h"
#import "PresenceManager.h"
#import "ACDChatDetailViewController.h"
#import "AgoraChatMessageWeakHint.h"

#import "ACDReportMessageViewController.h"

#import "AgoraChatCallKitManager.h"
#import "AgoraChatCallCell.h"
#import "AgoraChatURLPreviewCell.h"
#import "AgoraChatCallKit/AgoraChatCallKit.h"
#import "ACDChatRecordViewController.h"
#import "ACDTextTranslationCell.h"
#import "ACDTextTranslationBubbleView.h"
#import "EaseMessageModel+Translation.h"
#import "ACDAtGroupMembersViewController.h"
#import "ACDGroupMemberAttributesCache.h"
#import "ACDContactListController.h"
#import "ACDGroupListViewController.h"
#import "AgoraChat_Demo-Swift.h"
#import "AgoraChatMessage+ShowText.h"

@interface ACDChatViewController ()<EaseChatViewControllerDelegate, AgoraChatroomManagerDelegate, AgoraChatGroupManagerDelegate, EaseMessageCellDelegate,TranslationCellDelegate,EaseUserUtilsDelegate>


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
@property (nonatomic, strong) NSMutableArray<NSString *> *atUserList;
@property (nonatomic, assign) BOOL atAll;
@property (nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *typingAttributes;

@property (nonatomic) NSMutableArray <__kindof AgoraChatMessage*> *forwardMessages;

@property (nonatomic) AgoraEditBar *editBar;

@property (nonatomic) AgoraEditNavigation *editNavigation;

@end

@implementation ACDChatViewController

- (instancetype)initWithConversationId:(NSString *)conversationId conversationType:(AgoraChatConversationType)conType {
    if (self = [super init]) {
        _conversation = [AgoraChatClient.sharedClient.chatManager getConversation:conversationId type:conType createIfNotExist:YES isThread:NO];
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
        [_chatController setEditingStatusVisible:[ACDDemoOptions sharedOptions].isChatTyping];
        _chatController.delegate = self;
        _atAll = NO;
        self.forwardMessages = [NSMutableArray array];
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
    EaseUserUtils.shared.delegate = self;
    [ACDGroupMemberAttributesCache.shareInstance fetchCacheValueGroupId:self.conversationId userName:AgoraChatClient.sharedClient.currentUsername key:GROUP_NICKNAME_KEY completion:^(AgoraChatError * _Nullable error, NSString * _Nullable value) {
        [self.chatController refreshTableView:YES];
    }];
    if (_conversation.unreadMessagesCount > 0) {
        [[AgoraChatClient sharedClient].chatManager ackConversationRead:_conversation.conversationId completion:nil];
    }
    __weak typeof(self)weakSelf = self;
    [NSNotificationCenter.defaultCenter addObserverForName:AGORA_CHAT_CALL_KIT_COMMMUNICATE_RECORD object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        NSArray<AgoraChatMessage *> *messages = (NSArray *)[note.object objectForKey:@"msg"];
        if (messages && messages.count > 0) {
            NSMutableArray *messageModels = [NSMutableArray array];
            for (AgoraChatMessage *message in messages) {
                EaseMessageModel *model = [[EaseMessageModel alloc] initWithAgoraChatMessage:message];
                [messageModels addObject:model];
            }
            [weakSelf.chatController.dataArray addObjectsFromArray:messageModels];
            if (!weakSelf.chatController.moreMsgId) {
                weakSelf.chatController.moreMsgId = messages.firstObject.messageId;
            }
            [weakSelf.chatController.tableView reloadData];
        }
    }];

    
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
        if(userInfo && userInfo.nickname.length > 0)
            self.titleLabel.text = userInfo.nickname;
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

    self.navigationItem.titleView = titleView;

}


#pragma mark - EaseChatViewControllerDelegate
- (UITableViewCell *)cellForItem:(UITableView *)tableView messageModel:(EaseMessageModel *)messageModel {
    switch (messageModel.message.body.type) {
        case AgoraChatMessageTypeText:
            if (messageModel.isUrl) {
                AgoraChatURLPreviewCell *cell = [[AgoraChatURLPreviewCell alloc] initWithDirection:messageModel.direction chatType:messageModel.message.chatType messageType:messageModel.type viewModel:_viewModel];
                messageModel.type = AgoraChatMessageTypeExtURLPreview;
                cell.delegate = self.chatController;
                cell.model = messageModel;
                return cell;
            }
            if ([messageModel.message.ext[@"msgType"] isEqualToString:@"rtcCallWithAgora"]) {
                NSString *action = messageModel.message.ext[@"action"];
                if ([action isEqualToString:@"invite"]) {
                    if (messageModel.message.chatType == AgoraChatTypeChat) {
                        return nil;
                    }
                }
                if ([[messageModel.message.ext objectForKey:kMSG_EXT_NEWNOTI] isEqualToString:kNOTI_EXT_ADDFRIEND]) {
                    AgoraChatMessageWeakHint *weakHintCell = [[AgoraChatMessageWeakHint alloc]initWithMessageModel:messageModel];
                    return weakHintCell;
                }
                AgoraChatCallCell *cell = [[AgoraChatCallCell alloc] initWithDirection:messageModel.direction chatType:messageModel.message.chatType messageType:messageModel.type viewModel:_viewModel];
                cell.delegate = self;
                cell.model = messageModel;
                return cell;
            }
            break;
        default:
            break;
    }
    
    

////    if (messageModel.type == AgoraChatMessageTypePictMixText) {
////        AgoraChatMsgPicMixTextBubbleView* picMixBV = [[AgoraChatMsgPicMixTextBubbleView alloc] init];
////        [picMixBV setModel:messageModel];
////        AgoraChatMessageCell *cell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:picMixBV];
////        cell.model = messageModel;
////        cell.delegate = self;
////        return cell;
////    }

//    if(messageModel.message.body.type == AgoraChatMessageBodyTypeCustom) {
//        AgoraChatCustomMessageBody* body = (AgoraChatCustomMessageBody*)messageModel.message.body;
//        if([body.event isEqualToString:@"userCard"]){
//            AgoraChatUserCardMsgView* userCardMsgView = [[AgoraChatUserCardMsgView alloc] init];
//            userCardMsgView.backgroundColor = [UIColor whiteColor];
//            [userCardMsgView setModel:messageModel];
//            AgoraChatMessageCell* userCardCell = [[AgoraChatMessageCell alloc] initWithDirection:messageModel.direction type:messageModel.type msgView:userCardMsgView];
//            userCardCell.model = messageModel;
//            userCardCell.delegate = self;
//            return userCardCell;
//        }
//    }
    
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
    
    if (messageModel.message.direction == AgoraChatMessageDirectionReceive && messageModel.isTranslation) {
        ACDTextTranslationCell* textTranslationCell = [[ACDTextTranslationCell alloc] initWithDirection:messageModel.message.direction chatType:messageModel.message.chatType messageType:50 viewModel:self.viewModel];
        textTranslationCell.delegate = self.chatController;
        textTranslationCell.model = messageModel;
        textTranslationCell.translateDelegate = self;
        return textTranslationCell;
    }

    //@{kMSG_EXT_NEWNOTI : kNOTI_EXT_ADDGROUP, kNOTI_EXT_USERID : mutableStr}

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
    if ([huanxinID isEqualToString:@""] || huanxinID == nil) {
        return model;
    }
    if (self.chatController.currentConversation.type == AgoraChatConversationTypeGroupChat && self.chatController.endScroll) {
        NSString* alias = [ACDGroupMemberAttributesCache.shareInstance fetchGroupAlias:self.conversation.conversationId userId:huanxinID];
        if (alias == nil) {
            [self fetchMemberNickNameOnGroup:huanxinID model:model];
            return model;
        }
        if (alias.length > 0) {
            model = [[AgoraChatUserDataModel alloc] initWithUserId:huanxinID showName:alias];
            return model;
        }
    }
    AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:huanxinID];
    if(userInfo) {
        model = [[AgoraChatUserDataModel alloc] initWithUserInfo:userInfo];
    }else{
        AgoraChatUserInfo* userInfo = [[AgoraChatUserInfo alloc]init];
        userInfo.userId = huanxinID;
        model = [[AgoraChatUserDataModel alloc]initWithUserInfo:userInfo];
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[huanxinID]];
    }
    return model;
}

- (void)fetchMemberNickNameOnGroup:(NSString *)userId model:(AgoraChatUserDataModel *)model{
    if ([userId isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
        return;
    }
    [[ACDGroupMemberAttributesCache shareInstance] fetchCacheValueGroupId:self.chatController.currentConversation.conversationId userName:userId key:GROUP_NICKNAME_KEY completion:^(AgoraChatError * _Nullable error, NSString * _Nullable value) {
        if (error == nil && value != nil && ![value isEqualToString:@""]) {
            //model.showName = value;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray<NSIndexPath*>* updateIndexPaths = [NSMutableArray array];
                for (NSIndexPath* indexPath in self.chatController.tableView.indexPathsForVisibleRows) {
                    id cell = [self.chatController.tableView cellForRowAtIndexPath:indexPath];
                    EaseMessageModel *msgModel = nil;
                    if (cell && [cell respondsToSelector:@selector(model)]) {
                        id tmp = [cell performSelector:@selector(model)];
                        if ([tmp isKindOfClass:[EaseMessageModel class]]) {
                            msgModel = tmp;
                        }
                    }
                    if ([msgModel isKindOfClass:[EaseMessageModel class]] && [msgModel.message.from isEqualToString:userId]) {
                        [updateIndexPaths addObject:indexPath];
                        msgModel.userDataProfile = [self userProfile:userId];
                    }
                }
                if (updateIndexPaths.count > 0)
                    [self.chatController.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:NO];
            });
        }
    }];
}

- (AgoraChatMessage *)willSendMessage:(AgoraChatMessage *)aMessage
{
    // diable auto translating
    if (aMessage.body.type == AgoraChatMessageTypeText && ACDDemoOptions.sharedOptions.enableTranslate && ACDDemoOptions.sharedOptions.autoLanguages.count > 0) {
        AgoraChatTextMessageBody* textBody = (AgoraChatTextMessageBody*)aMessage.body;
        NSMutableArray<NSString*> * languages = [NSMutableArray array];
        [ACDDemoOptions.sharedOptions.autoLanguages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [languages addObject:((AgoraChatTranslateLanguage*)obj).languageCode];
        }];
        textBody.targetLanguages = languages;
    }
    if (self.conversation.type == AgoraChatConversationTypeGroupChat && aMessage.body.type == AgoraChatMessageTypeText && (self.atUserList.count > 0 || self.atAll)) {
        AgoraChatTextMessageBody* textBody = (AgoraChatTextMessageBody*)aMessage.body;
        if (self.atAll) {
            aMessage.ext = @{@"em_at_list":@"ALL"};
        } else if (self.atUserList.count > 0) {
            aMessage.ext = @{@"em_at_list":self.atUserList};
        }
        self.atAll = NO;
        [self.atUserList removeAllObjects];
    }
    return aMessage;
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

- (void)scrollViewEndScroll
{
    for (UITableViewCell *cell in [self.chatController.tableView visibleCells]) {
        if ([cell canPerformAction:@selector(model) withSender:nil]) {
            id model = [cell performSelector:@selector(model)];
            if ([model isKindOfClass:[EaseMessageModel class]]) {
                [cell performSelector:@selector(setModel:) withObject:model];
            }
        }
    }
}

- (void)didSelectThreadBubble:(EaseMessageModel *)model {
    if (!model.message.chatThread.threadId.length) {
        [self showHint:@"conversationId is empty!"];
        return;
    }
    [AgoraChatClient.sharedClient.threadManager joinChatThread:model.message.chatThread.threadId completion:^(AgoraChatThread *thread,AgoraChatError *aError) {
        if (!aError || aError.code == AgoraChatErrorUserAlreadyExist) {
            if (thread) {
                model.thread = thread;
            }
            AgoraChatThreadViewController *VC = [[AgoraChatThreadViewController alloc] initThreadChatViewControllerWithCoversationid:model.message.chatThread.threadId conversationType:self.chatController.currentConversation.type chatViewModel:self.chatController.viewModel parentMessageId:model.message.messageId model:model];
            VC.detail = self.navTitle;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }];
}

- (void)createThread:(EaseMessageModel *)model {
    AgoraChatCreateThreadViewController *VC = [[AgoraChatCreateThreadViewController alloc] initWithType:EMThreadHeaderTypeCreate viewModel:self.chatController.viewModel message:model];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)joinChatThreadFromNotifyMessage:(NSString *)messageId {
    AgoraChatMessage *message = [AgoraChatClient.sharedClient.chatManager getMessageWithMessageId:messageId];
    EaseMessageModel *model = [[EaseMessageModel alloc] initWithAgoraChatMessage:message];
    model.direction = message.direction;
    model.isHeader = YES;
    model.isPlaying = NO;
    model.type = message.body.type;
    if (!message.chatThread.threadId.length) {
        [self showHint:@"threadId is empty!"];
        return;
    }
    [AgoraChatClient.sharedClient.threadManager joinChatThread:message.chatThread.threadId completion:^(AgoraChatThread *thread,AgoraChatError *aError) {
        if (!aError || aError.code == AgoraChatErrorUserAlreadyExist) {
            AgoraChatThreadViewController *VC = [[AgoraChatThreadViewController alloc] initThreadChatViewControllerWithCoversationid:message.chatThread.threadId conversationType:self.chatController.currentConversation.type chatViewModel:self.chatController.viewModel parentMessageId:message.messageId model:model];
            VC.detail = [NSString stringWithFormat:@"# %@",self.navTitle];
            if (thread.threadName.length) {
                VC.navTitle = thread.threadName;
            } else {
                VC.navTitle = message.chatThread.threadName;
            }
            [self.navigationController pushViewController:VC animated:YES];
        }
    }];
//    [self pushThreadListAction];
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
    if (msgModel.message.body.type == AgoraChatMessageTypeText && ACDDemoOptions.sharedOptions.enableTranslate && ACDDemoOptions.sharedOptions.demandLanguage.languageCode > 0) {
        EaseExtendMenuModel *reportItem = [[EaseExtendMenuModel alloc]initWithData:[UIImage imageNamed:@"report"] funcDesc:@"Translate" handle:^(NSString * _Nonnull itemDesc, BOOL isExecuted) {
            [weakSelf translateMessage:messageModel];
        }];
        [defaultLongPressItems addObject:reportItem];
    }
    return defaultLongPressItems;
}

- (BOOL)textView:(UITextView*)textView ShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.conversation.type == AgoraChatConversationTypeGroupChat) {
        if ([text isEqualToString:@"@"]) {
            // input @ in group chat
            [self _willInputAt:textView range:range];
            
        } else if ([text isEqualToString:@""]) {
            // delete something in group chat
            __block BOOL isAt = NO;
            NSAttributedString *attributedString = textView.attributedText;
            [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange blockRange, BOOL * _Nonnull stop) {
                NSString *atUser = attrs[@"AtInfo"];
                if (atUser) {
                    if (range.location + range.length == blockRange.location + blockRange.length) {
                        isAt = YES;
                        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
                        [result deleteCharactersInRange:blockRange];
                        textView.attributedText = result;
                        if ([atUser isEqualToString:@"ALL"]) {
                            self.atAll = NO;
                        } else {
                            [self.atUserList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stopAtUserList) {
                                 if (obj.length > 0 && [obj isEqualToString:atUser]) {
                                     [self.atUserList removeObjectAtIndex:idx];
                                     *stopAtUserList = YES;
                                 }
                            }];
                        }
                        *stop = YES;
                    }
                }
            }];
            return !isAt;
        }
        if (!self.typingAttributes) {
            self.typingAttributes = textView.typingAttributes;
        }
        textView.typingAttributes = self.typingAttributes;
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSRange selectRange = textView.selectedRange;
    if (selectRange.length > 0)
    {
        return;
    }
    [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textView.attributedText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if (attrs[@"AtInfo"]) {
            NSUInteger min = textView.selectedRange.location;
            NSUInteger max = textView.selectedRange.location + textView.selectedRange.length;
            if (min > range.location && max < range.location + range.length) {
                NSUInteger location = range.location + range.length;
                NSUInteger length = 0;
                if (textView.selectedRange.location + textView.selectedRange.length > location) {
                    length = textView.selectedRange.location + textView.selectedRange.length - location;
                }
                textView.selectedRange = NSMakeRange(location, length);
                *stop = YES;
            }
        }
    }];
}

// @ feature
- (void)_willInputAt:(UITextView *)aInputView range:(NSRange)range
{
    do {
        AgoraChatGroup *group = [AgoraChatGroup groupWithId:self.conversation.conversationId];
        if (!group) {
            break;
        }
//        [self.view endEditing:YES];
        //选择 @ 某群成员
        ACDAtGroupMembersViewController *controller = [[ACDAtGroupMembersViewController alloc] initWithGroup:group];
        [self.navigationController pushViewController:controller animated:NO];
        [controller setSelectedCompletion:^(NSString * _Nonnull aUserId,NSString* showName) {
            NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:aInputView.attributedText];
            NSString *newStr = [NSString stringWithFormat:@"@%@ ", showName];
            NSAttributedString *newString = [[NSAttributedString alloc] initWithString:newStr attributes:@{
                NSFontAttributeName: aInputView.font,
                @"AtInfo": aUserId,
                NSForegroundColorAttributeName: [UIColor colorWithHexString:@"154dfe"]
            }];
            if (result.length > 0 && [result.string hasSuffix:@"@"]) {
                [result deleteCharactersInRange:NSMakeRange(result.length - 1, 1)];
            }
            //[result replaceCharactersInRange:range withAttributedString:newString];
            [result appendAttributedString:newString];
            NSDictionary* old = aInputView.typingAttributes;
            aInputView.attributedText = result;
            aInputView.typingAttributes = old;
            aInputView.selectedRange = NSMakeRange(result.length, 0);
            [aInputView becomeFirstResponder];
            if ([aUserId isEqualToString:@"ALL"]) {
                self.atAll = YES;
            } else {
                [self.atUserList addObject:aUserId];
            }
        }];
    } while (0);
}

- (BOOL)didSelectMessageItem:(AgoraChatMessage *)message userProfile:(id<EaseUserProfile>)userData {
    return YES;
}
//
//- (AgoraEditBar *)editBar {
//    if (!_editBar) {
//        _editBar = [[AgoraEditBar alloc] initWithFrame:CGRectMake(0, EMScreenHeight-kBottomSafeHeight-54, EMScreenWidth, kBottomSafeHeight+54)];
//    }
//    return _editBar;
//}
//
-(AgoraEditNavigation *)editNavigation {
    if (!_editNavigation) {
        _editNavigation = [[AgoraEditNavigation alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.navigationView.frame)) avatar:self.navigationView.chatImageView.image nickName:self.navigationView.leftLabel.text];
    }
    return _editNavigation;
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
    [self.view addSubview:self.editNavigation];
    __weak typeof(self) weakSelf = self;
    self.editNavigation.cancelClosure = ^{
        for (id model in weakSelf.chatController.dataArray) {
            if ([model isKindOfClass:[EaseMessageModel class]]) {
                ((EaseMessageModel *)model).selected = NO;
            }
        }
        [weakSelf.editNavigation removeFromSuperview];
        [weakSelf.chatController.toolBar dismiss];
        weakSelf.chatController.editMode = NO;
        [weakSelf.chatController.tableView reloadData];
    };
    return YES;
}

- (void)chooseForwardTargets {
    [self fillForwardMessages];
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

- (void)forwardCombineMessages:(NSString *)target chat:(BOOL)chat {
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
    __weak typeof(self) weakSelf = self;
    [AgoraChatClient.sharedClient.chatManager sendMessage:message progress:nil completion:^(AgoraChatMessage * _Nullable message, AgoraChatError * _Nullable error) {
        NSString *alert = @"Forward successful!";
        if (!error && message != nil) {
            [weakSelf.chatController.dataArray addObject:[[EaseMessageModel alloc] initWithAgoraChatMessage:message]];
            [weakSelf.chatController.tableView reloadData];
        } else {
            alert = error.errorDescription;
        }
        [weakSelf showHint:alert];
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
    [self fillForwardMessages];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Message" message:[NSString stringWithFormat:@"Delete %lu messages form database",(unsigned long)self.forwardMessages.count] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        for (AgoraChatMessage *message in self.forwardMessages) {
            [self.conversation deleteMessageWithId:message.messageId error:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - AgoraChatMessageCellDelegate


- (void)messageCellNeedReload:(EaseMessageCell *)cell
{
    NSIndexPath *indexPath = [self.chatController.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.chatController.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

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

- (void)avatarDidLongPress:(id<EaseUserProfile>)userData
{
    if (self.conversation.type == AgoraChatConversationTypeGroupChat && userData) {
        UITextView* inputView = [self.chatController.inputBar valueForKey:@"textView"];
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:inputView.attributedText];
        NSString *newStr = [NSString stringWithFormat:@"@%@ ", userData.showName];
        id font = inputView.font;
        NSAttributedString *newString = [[NSAttributedString alloc] initWithString:newStr attributes:@{
            NSFontAttributeName: inputView.font,
            @"AtInfo": userData.easeId,
            NSForegroundColorAttributeName: [UIColor colorWithHexString:@"154dfe"]
        }];
        [result appendAttributedString:newString];
        NSDictionary* old = inputView.typingAttributes;
        inputView.attributedText = result;
        inputView.typingAttributes = old;
        inputView.selectedRange = NSMakeRange(result.length, 0);
        [inputView becomeFirstResponder];
        [self.atUserList addObject:userData.easeId];
    }
}

# pragma mark - EaseUserUtilsDelegate
- (nullable id<EaseUserProfile>)getUserInfo:(NSString *)easeId moduleType:(EaseUserModuleType)moduleType
{
    if (moduleType == EaseUserModuleTypeGroupChat && self.conversation.type == AgoraChatConversationTypeGroupChat) {
        NSString* alias = [ACDGroupMemberAttributesCache.shareInstance fetchGroupAlias:self.conversationId userId:easeId];
        if (alias.length > 0) {
            return [[AgoraChatUserDataModel alloc] initWithUserId:easeId showName:alias];
        }
    }
    
    return [self userProfile:easeId];
}

- (void)pushToReportMessageViewController:(EaseMessageModel *)messageModel {
    ACDReportMessageViewController *vc = [[ACDReportMessageViewController alloc] initWithReportMessage:messageModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)translateMessage:(EaseMessageModel*)model {
    if (model.message.body.type == AgoraChatMessageBodyTypeText) {
        NSString *text = ((AgoraChatTextMessageBody*)model.message.body).text;
        if (text.length > 0) {
            [self showHudInView:self.view hint:@"Translating..."];
            WEAK_SELF
            [AgoraChatClient.sharedClient.chatManager translateMessage:model.message targetLanguages:@[ACDDemoOptions.sharedOptions.demandLanguage.languageCode] completion:^(AgoraChatMessage * _Nullable message, AgoraChatError * _Nullable error) {
                [weakSelf hideHud];
                if (!error) {
                    model.showTranslation = YES;
                    [weakSelf.chatController refreshTableView:NO];
                } else {
                    [weakSelf showHint:@"Translate failed"];
                }
            }];
        }
    }
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
        if (self.conversationType == AgoraChatConversationTypeGroupChat) {
            _navigationView.chatImageView.layer.cornerRadius = 0;
            [_navigationView.chatImageView setImage:ImageWithName(@"group_default_avatar")];
        }
        if (self.conversationType == AgoraChatConversationTypeChat) {
            UIImage *originImage = nil;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSString *imageName = [userDefault objectForKey:self.conversationId];
            if (imageName && imageName.length > 0) {
                originImage = ImageWithName(imageName);
            } else {
                int random = arc4random() % 7 + 1;
                NSString *imgName = [NSString stringWithFormat:@"defatult_avatar_%@",@(random)];
                [userDefault setObject:imgName forKey:self.conversationId];
                originImage = ImageWithName(imgName);
                [userDefault synchronize];
            }
            
            [_navigationView.chatImageView setImage:originImage];
        }
        ACD_WS
        _navigationView.leftButtonBlock = ^{
            [weakSelf backAction];
        };
        
//        _navigationView.rightButton.hidden = NO;
//        [_navigationView.rightButton setImage:ImageWithName(@"nav_chat_right_bar") forState:UIControlStateNormal];
//        _navigationView.rightButtonBlock = ^{
//            [weakSelf goChatDetailPage];
//        };
        _navigationView.rightButton.hidden = NO;
        [_navigationView.rightButton setImage:ImageWithName(@"thread_more") forState:UIControlStateNormal];
        _navigationView.rightButtonBlock = ^{
            [weakSelf moreAction];
        };
        if (self.conversationType == AgoraChatConversationTypeChat) {
            _navigationView.rightButton2.hidden = NO;
            [_navigationView.rightButton2 setImage:[UIImage imageNamed:@"nav_bar_call"] forState:UIControlStateNormal];
            _navigationView.rightButtonBlock2 = ^{
                [weakSelf callAction];
            };
        } else {
            _navigationView.rightButton2.hidden = NO;
            [_navigationView.rightButton2 setImage:ImageWithName(@"groupThread") forState:UIControlStateNormal];
            _navigationView.rightButtonBlock2 = ^{
                [weakSelf pushThreadListAction];
            };
            
            _navigationView.rightButton3.hidden = NO;
            [_navigationView.rightButton3 setImage:[UIImage imageNamed:@"nav_bar_call"] forState:UIControlStateNormal];
            _navigationView.rightButtonBlock3 = ^{
                [weakSelf callAction];
            };
        }
        _navigationView.chatButtonBlock = ^{
            [weakSelf goInfoPage];
        };
        _navigationView.tag = -1999;
    }
    return _navigationView;
}

- (NSMutableArray<NSString *> *)atUserList
{
    if (!_atUserList) {
        _atUserList = [NSMutableArray array];
    }
    return _atUserList;
}

- (void)pushThreadListAction {
    [AgoraChatClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:self.conversationId fetchMembers:YES completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        if (!aError) {
            AgoraChatThreadListViewController *VC = [[AgoraChatThreadListViewController alloc] initWithGroup:aGroup chatViewModel:self.chatController.viewModel];
            [self.navigationController pushViewController:VC animated:YES];
        } else {
            [self showHint:@"fetch group detail error!"];
        }
    }];
}

- (void)callAction {
    __weak typeof(self)weakSelf = self;
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
}

- (UIAlertAction*)_createAlertActionTitle:(NSString*)title image:(UIImage*)image handler:(void(^ _Nonnull)(UIAlertAction * _Nonnull action))handler
{
    UIAlertAction* action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
    if(image) {
        [action setValue:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    }
    [action setValue:[NSNumber numberWithInt:0] forKey:@"titleTextAlignment"];
    [action setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    return action;
}

- (void)moreAction
{
    __weak typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* searchAction = [self _createAlertActionTitle:@"Search Message History" image:[UIImage imageNamed:@"chat_setting_search"] handler:^(UIAlertAction * _Nonnull action) {
        ACDChatRecordViewController *chatRecordController = [[ACDChatRecordViewController alloc] initWithConversationModel:weakSelf.conversation];
        chatRecordController.searchDoneBlock = ^(NSString* msgId) {
            if (msgId.length > 0) {
                __block NSUInteger index = -1;
                [weakSelf.chatController.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[EaseMessageModel class]]) {
                        AgoraChatMessage* msg = ((EaseMessageModel*)obj).message;
                        if ([msg.messageId isEqualToString:msgId]) {
                            index = idx;
                            *stop = YES;
                            
                        }
                    }
                    
                }];
                if (index == -1) {
                    [weakSelf.conversation loadMessagesStartFromId:msgId count:50 searchDirection:AgoraChatMessageSearchDirectionDown completion:^(NSArray<AgoraChatMessage *> * _Nullable aMessages, AgoraChatError * _Nullable aError) {
                        weakSelf.chatController.dataArray = [aMessages mutableCopy];
                    }];
                }
                if (index != -1) {
                    [weakSelf.chatController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
        };
        [weakSelf.navigationController pushViewController:chatRecordController animated:YES];
    }];
    [alertController addAction:searchAction];
    
    UIAlertAction* clearMessageAction = [self _createAlertActionTitle:@"Clear Message History" image:[UIImage imageNamed:@"delete"] handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController* deleteAlertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to delete all chat history?" preferredStyle:UIAlertControllerStyleAlert];
        [deleteAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            AgoraChatError*err = nil;
            [weakSelf.conversation deleteAllMessages:&err];
            [weakSelf.chatController.dataArray removeAllObjects];
            [weakSelf.chatController refreshTableView:YES];
        }]];
        [deleteAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [weakSelf presentViewController:deleteAlertController animated:NO completion:nil];
    }];
    [alertController addAction:clearMessageAction];
    
    UIAlertAction* stickyAction = [self _createAlertActionTitle:self.conversationModel.isTop ? @"UnSticky" : @"Sticky on Top" image:[UIImage imageNamed:@"chat_setting_top"] handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.conversationModel.isTop = !weakSelf.conversationModel.isTop;
    }];
    [alertController addAction:stickyAction];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [weakSelf presentViewController:alertController animated:YES completion:nil];
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

- (void)cellDidRetryTranslate:(ACDTextTranslationCell *)cell
{
    cell.model.translateStatus = TranslateStatusTranslating;
    WEAK_SELF
    [AgoraChatClient.sharedClient.chatManager translateMessage:cell.model.message targetLanguages:@[ACDDemoOptions.sharedOptions.demandLanguage.languageCode] completion:^(AgoraChatMessage * _Nullable message, AgoraChatError * _Nullable error) {
        if (!error) {
            cell.model.translateStatus = TranslateStatusSuccess;
        } else {
            cell.model.translateStatus = TranslateStatusFailed;
        }
        NSIndexPath* path = [self.chatController.tableView indexPathForCell:cell];
        if (path)
            [weakSelf.chatController.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

@end

