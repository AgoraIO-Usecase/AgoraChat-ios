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

@interface ACDChatsViewController() <EaseConversationsViewControllerDelegate, AgoraChatSearchControllerDelegate>

@property (nonatomic, strong) UIButton *addImageBtn;
//@property (nonatomic, strong) AgoraChatInviteGroupMemberViewController *inviteController;
@property (nonatomic, strong) EaseConversationsViewController *easeConvsVC;
@property (nonatomic, strong) EaseConversationViewModel *viewModel;
@property (nonatomic, strong) AgoraChatSearchResultController *resultController;
@property (strong, nonatomic) UIView *networkStateView;
@property (nonatomic,strong) ACDNaviCustomView *navView;


@end

@implementation ACDChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:CHAT_BACKOFF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:GROUP_LIST_FETCHFINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserInfo:) name:USERINFO_UPDATE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGroupNotification:) name:KAgora_CreateGroup object:nil];

    
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
    
//    self.viewModel.avatarType = Rectangular;                        //头像类型
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

    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
    }];


    [self.easeConvsVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(15);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
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
    
    [self.easeConvsVC.tableView.tableHeaderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.easeConvsVC.tableView);
        make.width.equalTo(self.easeConvsVC.tableView);
        make.top.equalTo(self.easeConvsVC.tableView);
        make.height.mas_equalTo(54);
    }];
    
    [self.easeConvsVC.tableView.tableHeaderView addSubview:control];
    [control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(36);
        make.top.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(8);
        make.bottom.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(-8);
        make.left.equalTo(self.easeConvsVC.tableView.tableHeaderView.mas_left).offset(16);
        make.right.equalTo(self.easeConvsVC.tableView.tableHeaderView).offset(-16);
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.easeConvsVC refreshTable];
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

- (void)createGroupNotification:(NSNotification *)notify {
    AgoraChatGroup *group = (AgoraChatGroup *)notify.object;
    [self goGroupChatPageWithGroup:group];
}


- (void)refreshTableViewWithData
{
    __weak typeof(self) weakself = self;
    [[AgoraChatClient sharedClient].chatManager getConversationsFromServer:^(NSArray *aCoversations, AgoraChatError *aError) {
        if (!aError && [aCoversations count] > 0) {
            [weakself.easeConvsVC.dataAry removeAllObjects];
            [weakself.easeConvsVC.dataAry addObjectsFromArray:aCoversations];
            [weakself.easeConvsVC refreshTable];
        }
    }];
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
    }
    return _navView;
}
@end
