//
//  ACDChatsViewController.m
//  ChatDemo-UI3.0
//
//  Created by zhangchong on 2021/11/6.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDChatsViewController.h"
#import "AgoraChatRealtimeSearch.h"
#import "AgoraChatSearchResultController.h"
#import "UserInfoStore.h"
#import "AgoraChatConvUserDataModel.h"
#import "ACDGroupEnterController.h"
#import "ACDChatViewController.h"
#import "ACDNaviCustomView.h"
#import "AgoraChatAvatarView.h"
#import "PresenceManager.h"

@interface ACDChatsViewController() <EaseConversationsViewControllerDelegate, AgoraChatSearchControllerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIButton *addImageBtn;
//@property (nonatomic, strong) AgoraChatInviteGroupMemberViewController *inviteController;
@property (nonatomic, strong) EaseConversationsViewController *easeConvsVC;
@property (nonatomic, strong) EaseConversationViewModel *viewModel;
@property (nonatomic, strong) AgoraChatSearchResultController *resultController;
@property (strong, nonatomic) UIView *networkStateView;
@property (nonatomic,strong) ACDNaviCustomView *navView;
@property (nonatomic,strong) AgoraChatAvatarView* avatarView;
@property (nonatomic,strong) UIButton* presenceButton;

@end

@implementation ACDChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:CHAT_BACKOFF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:GROUP_LIST_FETCHFINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserInfo:) name:USERINFO_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGroupNotification:) name:KAgora_CreateGroup object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presencesUpdated:) name:PRESENCES_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConversationList)
        name:KAgora_UPDATE_CONVERSATIONS object:nil];

    
    [self _setupSubviews];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self refreshTableViewWithData];
    }
}

- (void)viewWillAppear:(BOOL)animated{
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor clearColor];
    self.viewModel = [[EaseConversationViewModel alloc] init];
    self.viewModel.canRefresh = YES;                                //是否可刷新
    self.viewModel.badgeLabelCenterVector = CGVectorMake(-16, 0);   //未读数角标中心偏移量
  
//    self.viewModel.nameLabelColor = [UIColor blueColor];            //会话名称颜色
//    self.viewModel.detailLabelColor = [UIColor redColor];           //会话详情颜色
//    self.viewModel.timeLabelColor = [UIColor systemPinkColor];      //会话时间颜色
//    self.viewModel.cellBgColor = [UIColor lightGrayColor];              //会话cell背景色
//    self.viewModel.badgeLabelBgColor = [UIColor purpleColor];         //未读数背景色

    self.easeConvsVC = [[EaseConversationsViewController alloc] initWithModel:self.viewModel];
    self.easeConvsVC.delegate = self;
    [self addChildViewController:self.easeConvsVC];
    [self.view addSubview:self.easeConvsVC.view];
    [self.view addSubview:self.navView];

    WEAK_SELF
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view);
        make.left.right.equalTo(weakSelf.view);
    }];


    [self.easeConvsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.navView.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view);
    }];
    [self _updateConversationViewTableHeader];
}


- (void)_updateConversationViewTableHeader {
    self.easeConvsVC.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.easeConvsVC.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
    control.clipsToBounds = YES;
    control.layer.cornerRadius = 18;
    control.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonAction)];
    [control addGestureRecognizer:tap];
    WEAK_SELF
    [self.easeConvsVC.tableView.tableHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.easeConvsVC.tableView);
        make.width.equalTo(weakSelf.easeConvsVC.tableView);
        make.top.equalTo(weakSelf.easeConvsVC.tableView);
        make.height.mas_equalTo(54);
    }];
    
    [self.easeConvsVC.tableView.tableHeaderView addSubview:control];
    [control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(36);
        make.top.equalTo(weakSelf.easeConvsVC.tableView.tableHeaderView).offset(8);
        make.bottom.equalTo(weakSelf.easeConvsVC.tableView.tableHeaderView).offset(-8);
        make.left.equalTo(weakSelf.easeConvsVC.tableView.tableHeaderView.mas_left).offset(16);
        make.right.equalTo(weakSelf.easeConvsVC.tableView.tableHeaderView).offset(-16);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"Search";
    label.textColor = [UIColor colorWithHexString:@"#999999"];
    label.textAlignment = NSTextAlignmentLeft;
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIView *subView = [[UIView alloc] init];
    [subView addSubview:imageView];
    [subView addSubview:label];
    [control addSubview:subView];
    
    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.left.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];
    
    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right);
        make.right.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];
    
    [subView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(control);
        make.left.equalTo(control);
    }];
}

- (void)_setupSearchResultController
{
    __weak typeof(self) weakself = self;
    self.resultController.tableView.rowHeight = 70;
    self.resultController.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.resultController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        NSString *cellIdentifier = @"EaseConversationCell";
        EaseConversationCell *cell = [EaseConversationCell tableView:tableView identifier:cellIdentifier];
        if (cell == nil) {
            cell = [[EaseConversationCell alloc]initWithConversationsViewModel:_viewModel identifier:cellIdentifier];
        }
        NSInteger row = indexPath.row;
        EaseConversationModel *model = [weakself.resultController.dataArray objectAtIndex:row];
        cell.model = model;
        return cell;
    }];
    [self.resultController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
        return YES;
    }];
    [self.resultController setTrailingSwipeActionsConfigurationForRowAtIndexPath:^UISwipeActionsConfiguration *(UITableView *tableView, NSIndexPath *indexPath) {
        EaseConversationModel *model = [weakself.resultController.dataArray objectAtIndex:indexPath.row];
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                                   title:@"delete"
                                                                                 handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
        {
            [weakself.resultController.tableView setEditing:NO];
            int unreadCount = [[AgoraChatClient sharedClient].chatManager getConversationWithConvId:model.easeId].unreadMessagesCount;
            [[AgoraChatClient sharedClient].chatManager deleteConversation:model.easeId isDeleteMessages:YES completion:^(NSString *aConversationId, AgoraChatError *aError) {
                if (!aError) {
                    [weakself.resultController.dataArray removeObjectAtIndex:indexPath.row];
                    [weakself.resultController.tableView reloadData];
                    if (unreadCount > 0 && weakself.deleteConversationCompletion) {
                        weakself.deleteConversationCompletion(YES);
                    }
                }
            }];
        }];
        UIContextualAction *topAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                title:!model.isTop ? @"Sticky" : @"Unsticky"
                                                                              handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL))
        {
            [weakself.resultController.tableView setEditing:NO];
            [model setIsTop:!model.isTop];
            [weakself.easeConvsVC refreshTable];
        }];
        UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction,topAction]];
        actions.performsFirstActionWithFullSwipe = NO;
        return actions;
    }];
    [self.resultController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSInteger row = indexPath.row;
        EaseConversationModel *model = [weakself.resultController.dataArray objectAtIndex:row];
        weakself.resultController.searchBar.text = @"";
        [weakself.resultController.searchBar resignFirstResponder];
        weakself.resultController.searchBar.showsCancelButton = NO;
        [weakself searchBarCancelButtonAction:nil];
        //[weakself.resultController.navigationController popViewControllerAnimated:YES];
        [weakself.resultController dismissViewControllerAnimated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
        ACDChatViewController *chatViewController = [[ACDChatViewController alloc] initWithConversationId:model.easeId conversationType:model.type];
        chatViewController.navTitle = model.showName;

        chatViewController.hidesBottomBarWhenPushed = YES;
        [weakself.navigationController pushViewController:chatViewController animated:YES];
    }];
}

- (void)refreshTableView
{
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.view.window)
            [weakSelf.easeConvsVC refreshTable];
    });
}

- (void)refreshConversationList
{
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        //if(self.view.window)
        [weakSelf.easeConvsVC refreshTabView];
    });
}

#pragma mark NSNotification
- (void)resetUserInfo:(NSNotification *)notification
{
    NSArray *userinfoList = (NSArray *)notification.userInfo[USERINFO_LIST];
    if (!userinfoList && userinfoList.count == 0)
        return;
    
    NSMutableArray *userInfoAry = [[NSMutableArray alloc]init];
    for (AgoraChatUserInfo *userInfo in userinfoList) {
        AgoraChatConvUserDataModel *model = [[AgoraChatConvUserDataModel alloc]initWithUserInfo:userInfo conversationType:AgoraChatConversationTypeChat];
        [userInfoAry addObject:model];
    }
    
    [self.easeConvsVC resetUserProfiles:userInfoAry];
}

- (void)createGroupNotification:(NSNotification *)notification {
    AgoraChatGroup *group = (AgoraChatGroup *)notification.userInfo[@"group"];
    NSMutableArray<NSString *> *invitees = (NSMutableArray<NSString *> *)notification.userInfo[@"invitees"];
    
    NSMutableString *mutableStr = [[NSMutableString alloc]initWithString:@""];
    if (invitees.count > 0) {
        for (NSString *str in invitees) {
            [mutableStr appendString:str];
            [mutableStr appendString:@", "];
        }
        [mutableStr deleteCharactersInRange:NSMakeRange(mutableStr.length - 2, 1)];
    }
    
    NSString *hintMsg = @"";
    if (mutableStr.length > 0) {
        hintMsg = [NSString stringWithFormat:@"You invited %@ to join the group", mutableStr];
    } else {
        hintMsg = [NSString stringWithFormat:@"You have created a group %@", group.groupName];
    }
    AgoraChatTextMessageBody *body = [[AgoraChatTextMessageBody alloc] initWithText:hintMsg];
    AgoraChatMessage *message = [[AgoraChatMessage alloc] initWithConversationID:group.groupId from:AgoraChatClient.sharedClient.currentUsername to:AgoraChatClient.sharedClient.currentUsername body:body ext:@{kMSG_EXT_NEWNOTI : kNOTI_EXT_ADDGROUP, kNOTI_EXT_USERID : mutableStr}];
    message.chatType = AgoraChatTypeGroupChat;
    message.isRead = YES;
    AgoraChatConversation *conversation = [[AgoraChatClient sharedClient].chatManager getConversation:group.groupId type:AgoraChatConversationTypeGroupChat createIfNotExist:YES];
    [conversation insertMessage:message error:nil];
    
    [self goGroupChatPageWithGroup:group];
}


- (void)refreshTableViewWithData
{
    __weak typeof(self) weakself = self;
    [[AgoraChatClient sharedClient].chatManager getConversationsFromServer:^(NSArray *aCoversations, AgoraChatError *aError) {
        if (!aError && [aCoversations count] > 0) {
            [weakself.easeConvsVC.dataAry removeAllObjects];
            NSArray<EaseConversationModel *> *modelAry = [weakself formateConversations:aCoversations];
            if (modelAry.count > 0) {
                [weakself.easeConvsVC.dataAry addObjectsFromArray:modelAry];
                [weakself.easeConvsVC refreshTable];
            }
        }
    }];
}

- (NSArray<EaseConversationModel *> *)formateConversations:(NSArray *)conversations
{
    NSMutableArray<EaseConversationModel *> *convs = [NSMutableArray array];
    
    for (AgoraChatConversation *conv in conversations) {
        if (!conv.latestMessage) {
            continue;
        }
        
        if (conv.type == AgoraChatConversationTypeChatRoom && !self.viewModel.displayChatroom) {
            continue;
        }

        EaseConversationModel *item = [[EaseConversationModel alloc] initWithConversation:conv];
        item.userProfile = [self easeUserProfileAtConversationId:conv.conversationId conversationType:conv.type];
        
        [convs addObject:item];
    }
    
    NSArray<EaseConversationModel *> *normalConvList = [convs sortedArrayUsingComparator:
                               ^NSComparisonResult(EaseConversationModel *obj1, EaseConversationModel *obj2)
                               {
        if (obj1.lastestUpdateTime > obj2.lastestUpdateTime) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    
    return normalConvList;
}

- (void)tableViewDidTriggerHeaderRefresh
{
//    [self refreshTableViewWithData];
}


#pragma mark - searchButtonAction

- (void)searchButtonAction
{
    if (self.resultController == nil) {
        self.resultController = [[AgoraChatSearchResultController alloc] init];
        self.resultController.delegate = self;
        [self _setupSearchResultController];
    }
    [self.resultController.searchBar becomeFirstResponder];
    self.resultController.searchBar.showsCancelButton = YES;
    self.resultController.modalPresentationStyle = 0;
    [self presentViewController:self.resultController animated:YES completion:nil];
}

#pragma mark - Action

//删除会话
- (void)_deleteConversation:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    NSInteger row = indexPath.row;
    EaseConversationModel *model = [self.easeConvsVC.dataAry objectAtIndex:row];
    int unreadCount = [[AgoraChatClient sharedClient].chatManager getConversationWithConvId:model.easeId].unreadMessagesCount;
    [[AgoraChatClient sharedClient].chatManager deleteConversation:model.easeId
                                           isDeleteMessages:YES
                                                 completion:^(NSString *aConversationId, AgoraChatError *aError) {
        if (!aError) {
            [weakSelf.easeConvsVC.dataAry removeObjectAtIndex:row];
            [weakSelf.easeConvsVC refreshTabView];
            if (unreadCount > 0 && weakSelf.deleteConversationCompletion) {
                weakSelf.deleteConversationCompletion(YES);
            }
        }
    }];
}

- (void)networkChanged:(AgoraChatConnectionState)connectionState
{
    if (connectionState == AgoraChatConnectionDisconnected) {
        self.tableView.tableHeaderView = self.networkStateView;
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)chatInfoAction
{
    ACDGroupEnterController *groupEnterVC = ACDGroupEnterController.new;
    groupEnterVC.accessType = ACDGroupEnterAccessTypeChat;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:groupEnterVC];
    nav.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController presentViewController:nav animated:YES completion:nil];

}

- (void)goGroupChatPageWithGroup:(AgoraChatGroup *)group {
    ACDChatViewController *chatViewController = [[ACDChatViewController alloc] initWithConversationId:group.groupId conversationType:AgoraChatConversationTypeGroupChat];
    chatViewController.navTitle = group.groupName;
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - AgoraChatSearchControllerDelegate

- (void)searchBarWillBeginEditing:(UISearchBar *)searchBar
{
    self.resultController.searchKeyword = nil;
}

- (void)searchBarCancelButtonAction:(UISearchBar *)searchBar
{
    [[AgoraChatRealtimeSearch shared] realtimeSearchStop];
    
    if ([self.resultController.dataArray count] > 0) {
        [self.resultController.dataArray removeAllObjects];
    }
    [self.resultController.tableView reloadData];
    [self.easeConvsVC refreshTabView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchTextDidChangeWithString:(NSString *)aString
{
    self.resultController.searchKeyword = aString;
    
    __weak typeof(self) weakself = self;
    [[AgoraChatRealtimeSearch shared] realtimeSearchWithSource:self.easeConvsVC.dataAry searchText:aString collationStringSelector:@selector(showName) resultBlock:^(NSArray *results) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([weakself.resultController.dataArray count] > 0) {
                 [weakself.resultController.dataArray removeAllObjects];
             }
            [weakself.resultController.dataArray addObjectsFromArray:results];
            [weakself.resultController.tableView reloadData];
        });
    }];
}
   
#pragma mark - EaseConversationsViewControllerDelegate

- (id<EaseUserProfile>)easeUserProfileAtConversationId:(NSString *)conversationId conversationType:(AgoraChatConversationType)type
{
    AgoraChatConvUserDataModel *userData = nil;
    if(type == AgoraChatConversationTypeChat) {
        AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:conversationId];
        if(userInfo) {
            userData = [[AgoraChatConvUserDataModel alloc]initWithUserInfo:userInfo conversationType:type];
        }else{
            [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[conversationId]];
        }
    }
    
    if (type == AgoraChatConversationTypeGroupChat) {
        AgoraChatUserInfo* userInfo = [[AgoraChatUserInfo alloc]init];
        userInfo.userId = conversationId;
        userData = [[AgoraChatConvUserDataModel alloc]initWithUserInfo:userInfo conversationType:type];
    }
    return userData;
}

- (void)easeTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseConversationCell *cell = (EaseConversationCell*)[tableView cellForRowAtIndexPath:indexPath];
    ACDChatViewController *chatViewController = [[ACDChatViewController alloc] initWithConversationId:cell.model.easeId conversationType:cell.model.type];
    chatViewController.navTitle = cell.model.showName;
    
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - getter and setter

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];

        _networkStateView.backgroundColor = KermitGreenTwoColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"Icon_error_white"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    return _networkStateView;
}


- (ACDNaviCustomView *)navView {
    if (_navView == nil) {
        _navView = [[ACDNaviCustomView alloc] init];
        ACD_WS
        _navView.addActionBlock = ^{
            [weakSelf chatInfoAction];
        };
        
        [_navView.titleImageView setImage:ImageWithName(@"nav_title_chats")];
        
        [_navView.addButton setImage:ImageWithName(@"chat_nav_add") forState:UIControlStateNormal];
        
        self.avatarView = [[AgoraChatAvatarView alloc] init];
        NSInteger avatarViewHeight = 34;
        self.avatarView.layer.cornerRadius = avatarViewHeight/2;
        self.avatarView.clipsToBounds = YES;
        [_navView addSubview:self.avatarView];
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_navView).offset(10);
            make.bottom.equalTo(_navView);
            make.width.height.equalTo(@(avatarViewHeight));
        }];
        AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:[AgoraChatClient sharedClient].currentUsername];
        if (userInfo.avatarUrl) {
            [self.avatarView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:ImageWithName(@"defatult_avatar_1")];
        }else {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            
            NSString *imageName = [userDefault valueForKey:[NSString stringWithFormat:@"%@_avatar",[AgoraChatClient sharedClient].currentUsername]];
                     
            if (imageName == nil) {
                imageName = @"defatult_avatar_1";
            }
            [self.avatarView sd_setImageWithURL:nil placeholderImage:ImageWithName(imageName)];
        }
        self.presenceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if([AgoraChatClient sharedClient].isConnected) {
            [self.presenceButton setTitle:kPresenceOnlineDescription forState:UIControlStateNormal];
            NSString* imageName = [[PresenceManager whiteStrokePresenceImages] objectForKey:[NSNumber numberWithInteger:1]];
            UIImage* image = [UIImage imageNamed:imageName];
            [self.avatarView setPresenceImage:image];
        }else{
            [self.presenceButton setTitle:kPresenceOfflineDescription forState:UIControlStateNormal];
            NSString* imageName = [[PresenceManager whiteStrokePresenceImages] objectForKey:[NSNumber numberWithInteger:0]];
            UIImage* image = [UIImage imageNamed:imageName];
            [self.avatarView setPresenceImage:image];
        }
        NSString* presence = [AgoraChatClient sharedClient].isConnected ? kPresenceOnlineDescription :kPresenceOfflineDescription;
        self.presenceButton.titleLabel.font = [UIFont systemFontOfSize:12];
        self.presenceButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.presenceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.presenceButton addTarget:self action:@selector(setPresence) forControlEvents:UIControlEventTouchUpInside];
        self.presenceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.presenceButton setImage:[UIImage imageNamed:@"go_small_black_mobile"] forState:UIControlStateNormal];
        
        [_navView addSubview:self.presenceButton];
        self.presenceButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.presenceButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        self.presenceButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        
        [self.presenceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(3);
            make.bottom.equalTo(self.avatarView.mas_bottom);
            make.height.equalTo(@15);
            make.width.equalTo(@100);
        }];
        [self _updatePresenceStatus];
    }
    return _navView;
}

- (void)presencesUpdated:(NSNotification*)noti
{
    NSArray*array = noti.object;
    if([AgoraChatClient sharedClient].currentUsername.length > 0 && [array containsObject:[AgoraChatClient sharedClient].currentUsername]) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself _updatePresenceStatus];
        });
    }
}

- (void)_updatePresenceStatus
{
    AgoraChatPresence*presence = [[PresenceManager sharedInstance].presences objectForKey:[AgoraChatClient sharedClient].currentUsername];
    if(presence) {
        NSInteger status = [PresenceManager fetchStatus:presence];
        NSString* imageName = [[PresenceManager whiteStrokePresenceImages] objectForKey:[NSNumber numberWithInteger:status]];
        [self.avatarView setPresenceImage:[UIImage imageNamed:imageName]];
        NSString* showStatus = [[PresenceManager showStatus] objectForKey:[NSNumber numberWithInteger:status]];
        if(status == 0)
            showStatus = [PresenceManager formatOfflineStatus:presence.lastTime];
        if(status != PRESENCESTATUS_OFFLINE && presence.statusDescription.length > 0) {
            [self.presenceButton setTitle:presence.statusDescription forState:UIControlStateNormal];
        }else
            [self.presenceButton setTitle:showStatus forState:UIControlStateNormal];
    }
}

- (void)setPresence
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Status" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    AgoraChatPresence* presence = [[PresenceManager sharedInstance].presences objectForKey:[AgoraChatClient sharedClient].currentUsername];
    
    WEAK_SELF
    void (^handleBlock) (NSInteger,NSString*) = ^(NSInteger status,NSString* presenceDescription) {
        if(presence.statusDescription.length > 0 && ![presence.statusDescription isEqualToString:kPresenceBusyDescription] && ![presence.statusDescription isEqualToString:kPresenceDNDDescription] && ![presence.statusDescription isEqualToString:kPresenceLeaveDescription]) {
            NSString* message = [NSString stringWithFormat:@"Clear your '%@',change to %@",presence.statusDescription,presenceDescription];
            if(presenceDescription.length == 0) {
                message = [message stringByAppendingString:kPresenceOnlineDescription];
            }
            UIAlertController* tipControler = [UIAlertController alertControllerWithTitle:@"Clear your Custom Status" message:message preferredStyle:UIAlertControllerStyleAlert];
            [tipControler addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [tipControler addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [[PresenceManager sharedInstance] publishPresenceWithDescription:presenceDescription completion:nil];
            }]];
            [weakSelf presentViewController:tipControler animated:YES completion:nil];
        }else{
            [[PresenceManager sharedInstance] publishPresenceWithDescription:presenceDescription completion:nil];
        }
    };
    
    [alertController addAction:[self _createStatusAlertActionTitle:kPresenceOnlineDescription image:[UIImage imageNamed:kPresenceOnlineDescription] handler:^(UIAlertAction * _Nonnull action) {
        handleBlock(PRESENCESTATUS_ONLINE,@"");
        
    }]];
    
    [alertController addAction:[self _createStatusAlertActionTitle:kPresenceBusyDescription image:[UIImage imageNamed:kPresenceBusyDescription] handler:^(UIAlertAction * _Nonnull action) {
        handleBlock(PRESENCESTATUS_BUSY,kPresenceBusyDescription);
    }]];
    
    [alertController addAction:[self _createStatusAlertActionTitle:kPresenceDNDDescription image:[UIImage imageNamed:kPresenceDNDDescription] handler:^(UIAlertAction * _Nonnull action) {
        handleBlock(PRESENCESTATUS_DONOTDISTURB,kPresenceDNDDescription);
    }]];
    
    [alertController addAction:[self _createStatusAlertActionTitle:kPresenceLeaveDescription image:[UIImage imageNamed:kPresenceLeaveDescription] handler:^(UIAlertAction * _Nonnull action) {
        handleBlock(PRESENCESTATUS_LEAVE,kPresenceLeaveDescription);
    }]];
    
    NSString* customtitle = @"Custom Status";
    if(presence.statusDescription.length > 0 && ![presence.statusDescription isEqualToString:kPresenceBusyDescription] && ![presence.statusDescription isEqualToString:kPresenceDNDDescription] && ![presence.statusDescription isEqualToString:kPresenceLeaveDescription])
        customtitle = presence.statusDescription;
    UIAlertAction* customAction = [self _createStatusAlertActionTitle:customtitle image:[UIImage imageNamed:@"custom"] handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf _updateCustomStatus];
    }];
    [alertController addAction:customAction];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];

    [self presentViewController:alertController animated:YES completion:nil];
    return;
}

- (UIAlertAction*)_createStatusAlertActionTitle:(NSString*)title image:(UIImage*)image handler:(void(^ _Nonnull)(UIAlertAction * _Nonnull action))handler
{
    UIAlertAction* action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
    if(image) {
        [action setValue:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    }
    [action setValue:[NSNumber numberWithInt:0] forKey:@"titleTextAlignment"];
    [action setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    return action;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(str.length > 64)
        return NO;
    return YES;
}

- (void)_updateCustomStatus
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Custom Status" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Input custom status";
        textField.delegate = self;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        [[PresenceManager sharedInstance] publishPresenceWithDescription:textField.text completion:nil];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
