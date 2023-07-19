//
//  ACDGroupInfoViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupInfoViewController.h"
#import "ACDInfoHeaderView.h"
#import "ACDJoinGroupCell.h"
#import "ACDInfoCell.h"
#import "ACDInfoDetailCell.h"
#import "ACDInfoSwitchCell.h"
#import "ACDGroupMembersViewController.h"
#import "ACDChatViewController.h"
#import "ACDGroupTransferOwnerViewController.h"
#import "ACDNotificationSettingViewController.h"
#import "ACDGroupNoticeViewController.h"
#import "ACDTextViewController.h"
#import "ACDTextViewController.h"
#import "ACDGroupSharedFilesViewController.h"
#import "ACDImageTitleContentCell.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"

#define kGroupInfoHeaderViewHeight 360.0

@interface ACDGroupInfoViewController ()
@property (nonatomic, strong) ACDInfoHeaderView *groupInfoHeaderView;
@property (nonatomic, strong) ACDJoinGroupCell *joinGroupCell;
@property (nonatomic, strong) ACDInfoDetailCell *membersCell;
@property (nonatomic, strong) ACDImageTitleContentCell *notificationCell;
@property (nonatomic, strong) ACDImageTitleContentCell *groupNoticesCell;
@property (nonatomic, strong) ACDInfoDetailCell *groupFilesCell;
@property (nonatomic, strong) ACDInfoSwitchCell *allowSearchCell;
@property (nonatomic, strong) ACDInfoSwitchCell *allowInviteCell;
@property (nonatomic, strong) ACDInfoCell *leaveCell;
@property (nonatomic, strong) ACDInfoCell *transferOwnerCell;
@property (nonatomic, strong) ACDInfoCell *disbandCell;
@property (nonatomic, strong) NSArray *cells;
@property (nonatomic, strong) AgoraChatGroup *group;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) ACDGroupMembersViewController *groupMembersVC;

@end

@implementation ACDGroupInfoViewController

- (instancetype)initWithGroupId:(NSString *)aGroupId {
    self = [self init];
    self.groupId = aGroupId;
    return self;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.navigationController.navigationBarHidden = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNotification:) name:KAgora_REFRESH_GROUP_INFO object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupMemberWithNotification:) name:KACD_REFRESH_GROUP_MEMBER object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupDestoryOrKickedOffNotification:) name:KAgora_GROUP_DESTORY_OR_KICKEDOFF object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavbar];
    [self fetchGroupInfo];
}

- (void)setupNavbar {

    self.navigationController.navigationBar.backgroundColor = UIColor.whiteColor;
        
    if (self.accessType == ACDGroupInfoAccessTypeSearch) {
        self.title = @"Public Groups";

        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 0, 20, 20);
        [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateNormal];
        [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateHighlighted];
        [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        [self.navigationItem setLeftBarButtonItem:leftBar];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, 50, 40);
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [cancelButton setTitleColor:ButtonEnableBlueColor forState:UIControlStateNormal];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        
        UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
        rightSpace.width = -2;
        [self.navigationItem setRightBarButtonItems:@[rightSpace,rightBar]];
    }else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ImageWithName(@"black_goBack") style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    }
    self.navigationController.navigationBarHidden = NO;

}

- (void)placeSubViews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark NSNotification
- (void)updateUIWithNotification:(NSNotification *)notification
{
    id obj = notification.object;
    if (obj && [obj isKindOfClass:[AgoraChatGroup class]]) {
        AgoraChatGroup *group = (AgoraChatGroup *)obj;
        if ([group.groupId isEqualToString:self.group.groupId]) {
            self.group = group;
            [self fetchGroupInfo];
        }
    }
}

- (void)updateGroupMemberWithNotification:(NSNotification *)aNotification {
    NSDictionary *dic = (NSDictionary *)aNotification.object;
    NSString* groupId = dic[kACDGroupId];
    ACDGroupMemberListType type = [dic[kACDGroupMemberListType] integerValue];
    
    if (![self.group.groupId isEqualToString:groupId] || type != ACDGroupMemberListTypeBlock) {
        return;
    }
    [self updateUI];
    [self.groupMembersVC updateWithGroup:self.group];

}

- (void)groupDestoryOrKickedOffNotification:(NSNotification *)aNotification{
    AgoraChatGroup *group = (AgoraChatGroup *)aNotification.object;
    if ([self.group.groupId isEqualToString:group.groupId]) {
        [self backAction];
    }
}


- (void)buildCells {
    if (self.accessType == ACDGroupInfoAccessTypeSearch) {
        self.cells = @[self.joinGroupCell];
        self.groupInfoHeaderView.isHideChatButton = YES;
    }else {
        if (self.group.permissionType == AgoraChatGroupPermissionTypeOwner) {
            self.cells = @[self.membersCell,self.notificationCell,self.groupNoticesCell,self.groupFilesCell,self.transferOwnerCell,self.disbandCell];
        } else if(self.group.permissionType == AgoraChatGroupPermissionTypeAdmin){
            self.cells = @[self.membersCell,self.notificationCell,self.groupNoticesCell,self.groupFilesCell,self.leaveCell];
        }else {
            self.cells = @[self.membersCell,self.notificationCell,self.groupNoticesCell,self.groupFilesCell,self.leaveCell];
        }
    }

}

- (void)updateUI {
    [self buildCells];
    self.groupInfoHeaderView.nameLabel.text = self.group.groupName;
    self.groupInfoHeaderView.userIdLabel.text = [NSString stringWithFormat:@"GroupID: %@",self.group.groupId];
    self.groupInfoHeaderView.describeLabel.text = self.group.description;
    self.membersCell.detailLabel.text = [@(self.group.occupantsCount) stringValue];
    self.groupNoticesCell.contentLabel.text = self.group.announcement;
    [self.table reloadData];
}


#pragma mark - Action
- (void)backAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_UPDATE_CONVERSATIONS object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fetchGroupInfo
{
    ACD_WS
    [[AgoraChatClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        if (aError == nil) {
            weakSelf.group = aGroup;
            [weakSelf updateUI];
            if (self.accessType != ACDGroupInfoAccessTypeSearch) {
                [weakSelf.groupMembersVC updateWithGroup:weakSelf.group];
                [weakSelf fetchGroupAnnouncement];
            }
        }else {
            [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
        }
    }];
    
    
}

- (void)fetchGroupAnnouncement {
    [[AgoraChatClient sharedClient].groupManager getGroupAnnouncementWithId:self.groupId completion:^(NSString *aAnnouncement, AgoraChatError *aError) {
        if (!aError) {
            [self updateUI];
        }else {
            [self showHint:aError.description];
        }
    }];
}


- (BOOL)isCanInvite
{
    return (self.group.permissionType == AgoraChatGroupPermissionTypeOwner || self.group.permissionType == AgoraChatGroupPermissionTypeAdmin || self.group.setting.style == AgoraChatGroupStylePrivateMemberCanInvite);
}

- (BOOL)isEditable {
    return (self.group.permissionType == AgoraChatGroupPermissionTypeOwner || self.group.permissionType == AgoraChatGroupPermissionTypeAdmin );
}

- (void)leaveGroup
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Leave this group now?" message:@"No prompt for other members and no group messages after you quit this group." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self leaveGroupWithGroupId:self.groupId];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)leaveGroupWithGroupId:(NSString *)groupId {
    [self showHudInView:self.view hint:NSLocalizedString(@"group.leave", @"Leave group")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        AgoraChatError *error = nil;
        [[AgoraChatClient sharedClient].groupManager leaveGroup:groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
            if (error) {
                [self showHint:NSLocalizedString(@"group.leaveFailure", @"exit the group failure")];
            }
            else{
//                [[AgoraChatClient sharedClient].chatManager deleteConversation:groupId isDeleteMessages:YES completion:nil];
//                [[AgoraChatClient sharedClient].chatManager deleteServerConversation:groupId conversationType:AgoraChatConversationTypeGroupChat isDeleteServerMessages:YES completion:nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_UPDATE_CONVERSATIONS object:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_END_CHAT object:groupId];
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }
        });
    });
}


- (void)dismissGroupWithGroupId:(NSString *)groupId {
    [self showHudInView:self.view hint:NSLocalizedString(@"group.destroy", @"dissolution of the group")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        AgoraChatError *error = [[AgoraChatClient sharedClient].groupManager destroyGroup:groupId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
            if (error) {
                [self showHint:NSLocalizedString(@"group.destroyFailure", @"dissolution of group failure")];
            }
            else{
//                [[AgoraChatClient sharedClient].chatManager deleteConversation:groupId isDeleteMessages:YES completion:nil];
//                [[AgoraChatClient sharedClient].chatManager deleteServerConversation:groupId conversationType:AgoraChatConversationTypeGroupChat isDeleteServerMessages:YES completion:nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_UPDATE_CONVERSATIONS object:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_END_CHAT object:groupId];
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    });
}

- (void)transferOwner {
    [self goTransferOwnerWithIsLeaveGroup:NO];
}

- (void)goTransferOwnerWithIsLeaveGroup:(BOOL)isLeaveGroup {
    ACDGroupTransferOwnerViewController *vc = [[ACDGroupTransferOwnerViewController alloc] initWithGroup:self.group];
    vc.isLeaveGroup = isLeaveGroup;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)disBandGroup {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Disband this group now?" message:@"Delete this group and associated Chats." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    
    UIAlertAction *disBandAction = [UIAlertAction actionWithTitle:@"Disband" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissGroupWithGroupId:self.groupId];
    }];
    
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:@"Transfer Ownership and Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self goTransferOwnerWithIsLeaveGroup:YES];
    }];
    

    [alertController addAction:cancelAction];
    [alertController addAction:disBandAction];
    [alertController addAction:leaveAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changeGroupName {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change Group Name" message:@"Latin letters and numbers only" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {

    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.ok", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *messageTextField = alertController.textFields.firstObject;
        [self updateGroupWithSubject:messageTextField.text];

    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateGroupDescription {
    ACDTextViewController *vc = [[ACDTextViewController alloc] initWithString:self.group.description placeholder:@"" isEditable:[self isEditable]];
    vc.navTitle = @"Group Description";
    vc.doneCompletion = ^BOOL(NSString * _Nonnull aString) {
        
        AgoraChatError *error = nil;
        AgoraChatGroup * group = [AgoraChatClient.sharedClient.groupManager changeDescription:aString forGroup:self.group.groupId error:&error];
        if (error == nil) {
            self.group = group;
            [self updateUI];
            return YES;
        }else {
            return NO;
        }
        
    };

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)updateGroupWithSubject:(NSString *)subject {
    
    ACD_WS
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AgoraChatClient sharedClient].groupManager updateGroupSubject:subject forGroup:self.groupId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        if (!aError) {
            [weakSelf fetchGroupInfo];
        }else {
            [self showAlertWithMessage:aError.description];
        }
    }];
}

- (void)headerViewTapAction {
   
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
        ACD_WS
        if (self.group.permissionType == AgoraChatGroupPermissionTypeOwner || self.group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
            
            UIAlertAction *changeNicknameAction = [UIAlertAction alertActionWithTitle:@"Change Group Name" iconImage:ImageWithName(@"action_icon_edit") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
                [self changeGroupName];
            }];
            [alertController addAction:changeNicknameAction];

            
            UIAlertAction *changDescriptionAction = [UIAlertAction alertActionWithTitle:@"Change the Description" iconImage:ImageWithName(@"action_icon_edit") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
                [self updateGroupDescription];
            }];
            [alertController addAction:changDescriptionAction];
            
        }
                
    
    UIAlertAction *copyAction = [UIAlertAction alertActionWithTitle:@"Copy GroupID" iconImage:ImageWithName(@"action_icon_copy") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [UIPasteboard generalPasteboard].string = self.group.groupId;
    }];
   
    
    [alertController addAction:copyAction];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)goGroupChatPage {
    ACDChatViewController *chatViewController = [[ACDChatViewController alloc] initWithConversationId:self.group.groupId conversationType:AgoraChatConversationTypeGroupChat];
    chatViewController.navTitle = self.group.groupName;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)goNotification {
    ACDNotificationSettingViewController *controller = [[ACDNotificationSettingViewController alloc] init];
    controller.notificationType = AgoraNotificationSettingTypeGroup;
    controller.conversationID = self.groupId;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goGroupNotice {
    ACDGroupNoticeViewController *controller = [[ACDGroupNoticeViewController alloc] initWithGroup:self.group];
    WEAK_SELF
    controller.updateNoticeBlock = ^(AgoraChatGroup* group) {
        [weakSelf updateUI];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goGroupShareFilePage {
    ACDGroupSharedFilesViewController *vc = [[ACDGroupSharedFilesViewController alloc] initWithGroup:self.group];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - Join Public Group
- (void)requestJoinGroup {
    if (self.group.setting.style == AgoraChatGroupStylePublicOpenJoin) {
        [self joinToPublicGroup:self.group.groupId];
    }
    else {
        [self requestToJoinPublicGroup:self.groupId message:[NSString stringWithFormat:@"%@ request join the group",AgoraChatClient.sharedClient.currentUsername]];
    }
}

- (void)joinToPublicGroup:(NSString *)groupId {
    ACD_WS
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                         animated:YES];
    [[AgoraChatClient sharedClient].groupManager joinPublicGroup:groupId
                                               completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
           [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
           if (!aError) {
               [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
    //               [weakSelf updateUI];
               
           }
           else {
               [weakSelf showHint:aError.errorDescription];
           }
       }
     ];
}

- (void)requestToJoinPublicGroup:(NSString *)groupId message:(NSString *)message {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                         animated:YES];
    [[AgoraChatClient sharedClient].groupManager requestToJoinPublicGroup:groupId
           message:message
        completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
            [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

            if (!aError) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
            }
            else {
                [weakSelf showHint:aError.errorDescription];
                
            }
        }];
}

- (void)showAlertView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Requesting message" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {

    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *messageTextField = alertController.textFields.firstObject;
        [self requestToJoinPublicGroup:self.groupId message:messageTextField.text];

    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cells[indexPath.row];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 || indexPath.row == 2) {
        return UITableViewAutomaticDimension;
    }
    return 54.0f;
}

#pragma mark getter and setter
- (ACDInfoHeaderView *)groupInfoHeaderView {
    if (_groupInfoHeaderView == nil) {
        _groupInfoHeaderView = [[ACDInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kGroupInfoHeaderViewHeight) withType:ACDHeaderInfoTypeGroup];
        _groupInfoHeaderView.isHideChatButton = self.isHideChatButton;
        
        [_groupInfoHeaderView.avatarImageView setImage:ImageWithName(@"group_default_avatar")];
        ACD_WS
        _groupInfoHeaderView.tapHeaderBlock = ^{
            [weakSelf headerViewTapAction];
        };

        _groupInfoHeaderView.goChatPageBlock = ^{
            [weakSelf goGroupChatPage];
        };

        _groupInfoHeaderView.goBackBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _groupInfoHeaderView;
}


- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = COLOR_HEX(0xFFFFFF);
        _table.tableHeaderView = [self headerView];
        _table.rowHeight = UITableViewAutomaticDimension;
        _table.estimatedRowHeight = 40.0f;
    }
    return _table;
}

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kGroupInfoHeaderViewHeight)];
        [_headerView addSubview:self.groupInfoHeaderView];
        [self.groupInfoHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerView);
        }];
    }
    return _headerView;
}

- (ACDJoinGroupCell *)joinGroupCell {
    if (_joinGroupCell == nil) {
        _joinGroupCell = [[ACDJoinGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDJoinGroupCell reuseIdentifier]];
        [_joinGroupCell.iconImageView setImage:ImageWithName(@"request_join_group")];
        _joinGroupCell.nameLabel.text = @"Join this Group";
        ACD_WS
        _joinGroupCell.joinGroupBlock = ^{
            [weakSelf requestJoinGroup];
        };
    }
    return _joinGroupCell;
}

- (ACDInfoDetailCell *)membersCell {
    if (_membersCell == nil) {
        _membersCell = [[ACDInfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        _membersCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [_membersCell.iconImageView setImage:ImageWithName(@"groupInfo_members")];
        _membersCell.nameLabel.text = @"Members";
        _membersCell.detailLabel.text = @"100";
        ACD_WS
        _membersCell.tapCellBlock = ^{
        
        [weakSelf.navigationController pushViewController:weakSelf.groupMembersVC animated:YES];
            
        };
    }
    return _membersCell;
}

- (ACDImageTitleContentCell *)notificationCell
{
    if (_notificationCell == nil) {
        _notificationCell = [[ACDImageTitleContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDImageTitleContentCell reuseIdentifier]];
        _notificationCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [_notificationCell.iconImageView setImage:ImageWithName(@"notifications_yellow")];
        _notificationCell.nameLabel.text = @"Notifications";
        ACD_WS
        _notificationCell.tapCellBlock = ^{
            [weakSelf goNotification];
        };
    }
    return _notificationCell;
}

- (ACDImageTitleContentCell *)groupNoticesCell {
    if (_groupNoticesCell == nil) {
        _groupNoticesCell = [[ACDImageTitleContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDImageTitleContentCell reuseIdentifier]];
        _groupNoticesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [_groupNoticesCell.iconImageView setImage:ImageWithName(@"groupInfo_notice")];
        _groupNoticesCell.nameLabel.text = @"Group Notice";
        _groupNoticesCell.contentLabel.text = self.group.announcement;
        ACD_WS
        _groupNoticesCell.tapCellBlock = ^{
            [weakSelf goGroupNotice];
        };
    }
    return _groupNoticesCell;
}

- (ACDInfoDetailCell *)groupFilesCell {
    if (_groupFilesCell == nil) {
        _groupFilesCell = [[ACDInfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        _groupFilesCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [_groupFilesCell.iconImageView setImage:ImageWithName(@"groupInfo_files")];
        _groupFilesCell.nameLabel.text = @"Group Files";
        _groupFilesCell.detailLabel.text = @"";
        ACD_WS
        _groupFilesCell.tapCellBlock = ^{
            [weakSelf goGroupShareFilePage];
        };
        
    }
    return _groupFilesCell;
}
    
    
- (ACDInfoSwitchCell *)allowSearchCell {
    if (_allowSearchCell == nil) {
        _allowSearchCell = [[ACDInfoSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoSwitchCell reuseIdentifier]];
        [_allowSearchCell.iconImageView setImage:ImageWithName(@"groupInfo_search")];
        _allowSearchCell.nameLabel.text = @"Allow Search";
        
    }
    return _allowSearchCell;
}


- (ACDInfoSwitchCell *)allowInviteCell {
    if (_allowInviteCell == nil) {
        _allowInviteCell = [[ACDInfoSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoSwitchCell reuseIdentifier]];
        [_allowInviteCell.iconImageView setImage:ImageWithName(@"groupInfo_invite")];
        _allowInviteCell.nameLabel.text = @"Allow Members to Invite";

    }
    return _allowInviteCell;
}

- (ACDInfoCell *)leaveCell {
    if (_leaveCell == nil) {
        _leaveCell = [[ACDInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoCell reuseIdentifier]];
        [_leaveCell.iconImageView setImage:ImageWithName(@"groupInfo_leave")];
        _leaveCell.nameLabel.text = @"Leave this Group";
        ACD_WS
        _leaveCell.tapCellBlock = ^{
            [weakSelf leaveGroup];
        };
    }
    return _leaveCell;
}

- (ACDInfoCell *)transferOwnerCell {
    if (_transferOwnerCell == nil) {
        _transferOwnerCell = [[ACDInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoCell reuseIdentifier]];
        [_transferOwnerCell.iconImageView setImage:ImageWithName(@"groupInfo_trans")];
        _transferOwnerCell.nameLabel.text = @"Transfer Ownership";
        ACD_WS
        _transferOwnerCell.tapCellBlock = ^{
            [weakSelf transferOwner];
        };
    }
    return _transferOwnerCell;
}

- (ACDInfoCell *)disbandCell {
    if (_disbandCell == nil) {
        _disbandCell = [[ACDInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoCell reuseIdentifier]];
        [_disbandCell.iconImageView setImage:ImageWithName(@"groupInfo_deband")];
        _disbandCell.nameLabel.text = @"Disband this Group";
        _disbandCell.nameLabel.textColor = TextLabelPinkColor;
        ACD_WS
        _disbandCell.tapCellBlock = ^{
            [weakSelf disBandGroup];
        };
    }
    return _disbandCell;
}

- (NSArray *)cells {
    if (_cells == nil) {
        _cells = NSArray.new;
    }
    return _cells;
}

- (ACDGroupMembersViewController *)groupMembersVC {
    if (_groupMembersVC == nil) {
        _groupMembersVC = [[ACDGroupMembersViewController alloc] initWithGroup:self.group];
    }
    return _groupMembersVC;
}

    
@end

#undef kGroupInfoHeaderViewHeight
