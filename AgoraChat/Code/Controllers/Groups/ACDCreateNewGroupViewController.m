//
//  AgoraCreateNewGroupNewViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCreateNewGroupViewController.h"
#import "AgoraUserModel.h"
#import "AgoraMemberCollectionCell.h"
#import "AgoraGroupPermissionCell.h"
#import "AgoraNotificationNames.h"
#import "AgoraMemberSelectViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+DismissKeyboard.h"
#import "ACDTextFieldCell.h"
#import "ACDTextViewCell.h"
#import "ACDMAXGroupNumberCell.h"
#import "ACDGroupMemberSelectViewController.h"

#define KAgora_GROUP_MAgoraBERSCOUNT     3000


static NSString *agoraGroupPermissionCellIdentifier = @"AgoraGroupPermissionCell";

@interface ACDCreateNewGroupViewController () <UITextFieldDelegate, UINavigationControllerDelegate, AgoraGroupUIProtocol>


@property (strong, nonatomic) ACDTextFieldCell *groupNameCell;
@property (strong, nonatomic) ACDTextViewCell *descriptionCell;
@property (strong, nonatomic) ACDMAXGroupNumberCell *maxGroupNumberCell;

@property (nonatomic, strong) NSMutableArray<AgoraUserModel *> *occupants;
@property (nonatomic, strong) NSMutableArray *groupPermissions;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, assign) BOOL isAllowMemberInvite;
@property (nonatomic, strong) NSMutableArray<NSString *> *invitees;
@property (nonatomic, strong) UIButton *createBtn;
@property (nonatomic, strong) AgoraChatGroupOptions *groupOptions;



@end

@implementation ACDCreateNewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavbar];
    [self setupForDismissKeyboard];
    [self initBasicData];
    
}

- (void)prepare {
    [self.view addSubview:self.table];
}

- (void)placeSubViews {
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupNavbar {
    self.title =  @"New Group";
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
    
    self.createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.createBtn.frame = CGRectMake(0, 0, 50, 40);
    self.createBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.createBtn setTitleColor:ButtonDisableGrayColor forState:UIControlStateNormal];
    [self.createBtn setTitle:@"Next" forState:UIControlStateNormal];
    [self.createBtn setTitle:@"Next" forState:UIControlStateHighlighted];
    [self.createBtn addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:self.createBtn];
    
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
    rightSpace.width = -2;
    [self.navigationItem setRightBarButtonItems:@[rightSpace,rightBar]];
}

- (void)updateCreateButtonStatus:(BOOL)enabled {
    self.createBtn.userInteractionEnabled = enabled;
    if (enabled) {
        [self.createBtn setTitleColor:TextLabelBlueColor forState:UIControlStateNormal];
        [self.createBtn setTitleColor:TextLabelBlueColor forState:UIControlStateHighlighted];
    }
    else {
        [self.createBtn setTitleColor:CoolGrayColor forState:UIControlStateNormal];
        [self.createBtn setTitleColor:CoolGrayColor forState:UIControlStateHighlighted];
    }
}


- (void)initBasicData {
    _occupants = [NSMutableArray array];
    AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:[AgoraChatClient sharedClient].currentUsername];
    if (model) {
        [_occupants addObject:model];
    }
    [self reloadPermissions];
}

- (void)reloadPermissions {
    _groupPermissions = [NSMutableArray array];
    AgoraGroupPermissionModel *model = [[AgoraGroupPermissionModel alloc] init];
    model.title = @"Set to a Public Group";
    model.isEdit = YES;
    model.switchState = NO;
    model.type = AgoraGroupInfoType_groupType;
    [_groupPermissions addObject:model];
    
    model = [[AgoraGroupPermissionModel alloc] init];
    model.title = @"Allow members to invite";
    model.isEdit = YES;
    model.switchState = NO;
    model.type = AgoraGroupInfoType_canAllInvite;
    [_groupPermissions addObject:model];
}

- (void)updatePermission {
    AgoraGroupPermissionModel *model = _groupPermissions.firstObject;
    model.switchState = _isPublic;
    [_groupPermissions replaceObjectAtIndex:0 withObject:model];
    
    model = _groupPermissions.lastObject;
    if (_isPublic) {
        model.title = @"Authorizated to join";
        model.type = AgoraGroupInfoType_openJoin;
    }
    else {
        model.title = @"Allow members to invite";
        model.type = AgoraGroupInfoType_canAllInvite;
    }
    [_groupPermissions replaceObjectAtIndex:1 withObject:model];
    [self.table reloadData];
}


#pragma mark - Action
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonAction {
    if (self.groupNameCell.titleTextField.text.length == 0) {
        [self showAlertWithMessage:@"please input group name"];
        return;
    }
    
    if (self.maxGroupNumberCell.maxGroupMemberField.text.length > 0) {

        NSInteger maxNumber = [self.maxGroupNumberCell.maxGroupMemberField.text integerValue];
        if (maxNumber < 3 || maxNumber > 3000) {
            [self showHint:KACDGroupCreateMemberLimit];
            self.groupOptions.maxUsersCount = 200;
            return;
        }
        
        self.groupOptions.maxUsersCount = maxNumber;
    }

    
    AgoraMemberSelectViewController *selectVC = [[AgoraMemberSelectViewController alloc] initWithInvitees:@[] maxInviteCount:self.groupOptions.maxUsersCount];
    selectVC.style = AgoraContactSelectStyle_Add;
    selectVC.title = @"Add Members";
    selectVC.delegate = self;
    [self.navigationController pushViewController:selectVC animated:YES];
  
//    ACDGroupMemberSelectViewController *selectVC = [[ACDGroupMemberSelectViewController alloc] initWithInvitees:@[] maxInviteCount:0];
//    selectVC.style = AgoraContactSelectStyle_Add;
//    selectVC.title = @"Add Members";
//    selectVC.delegate = self;
//    [self.navigationController pushViewController:selectVC animated:YES];
}


- (void)permissionSelectAction:(UISwitch *)permissionSwitch {
    if (permissionSwitch.tag == AgoraGroupInfoType_groupType) {
        _isPublic = permissionSwitch.isOn;
        [self updatePermission];
    }
    else {
        _isAllowMemberInvite = permissionSwitch.isOn;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.maxGroupNumberCell.maxGroupMemberField) {

        NSInteger maxNumber = [textField.text integerValue];
        self.groupOptions.maxUsersCount = maxNumber;
    }
    
    if (textField == self.groupNameCell.titleTextField) {
        BOOL enable = textField.text.length > 0;
        [self updateCreateButtonStatus:enable];

    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return self.groupNameCell;
    }
    
    if (indexPath.row == 1) {
        return self.descriptionCell;
    }
    
    if (indexPath.row == 2) {
        return self.maxGroupNumberCell;
    }
    
    
    AgoraGroupPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:agoraGroupPermissionCellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraGroupPermissionCell" owner:self options:nil] lastObject];
    }
    
    if (indexPath.row == 3) {
        cell.model = _groupPermissions[0];
    }
    
    if (indexPath.row == 4) {
        cell.model = _groupPermissions[1];
    }

    cell.permissionSwitch.tag = cell.model.type;
    [cell.permissionSwitch addTarget:self
                              action:@selector(permissionSelectAction:)
                    forControlEvents:UIControlEventValueChanged];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 134.0f;
    }
    return 54.0f;
}


#pragma mark - AgoraGroupUIProtocol
- (void)addSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray {
    
//    [self.occupants addObjectsFromArray:modelArray];
//    [self.membersCollection reloadSections:[NSIndexSet indexSetWithIndex:1]];
//    for (AgoraUserModel *model in modelArray) {
//        [_invitees addObject:model.hyphenateId];
//    }
//    [self updateMemberCountLabel];
    
    for (AgoraUserModel *model in modelArray) {
        if (![self.invitees containsObject:model.hyphenateId]) {
            [self.invitees addObject:model.hyphenateId];
        }
    }
    
  
    if (_isPublic) {
        self.groupOptions.style = _isAllowMemberInvite ? AgoraChatGroupStylePublicJoinNeedApproval : AgoraChatGroupStylePublicOpenJoin;
    }
    else {
        self.groupOptions.style = _isAllowMemberInvite ? AgoraChatGroupStylePrivateMemberCanInvite : AgoraChatGroupStylePrivateOnlyOwnerInvite;
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.inviteToJoin", @"%@ invite you to join the group [%@]"),[AgoraChatClient sharedClient].currentUsername, self.groupNameCell.titleTextField.text];

    ACD_WS
    [[AgoraChatClient sharedClient].groupManager createGroupWithSubject:self.groupNameCell.titleTextField.text
                                                     description:self.descriptionCell.contentTextView.text
                                                        invitees:self.invitees
                                                         message:message
                                                         setting:self.groupOptions
                                                      completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
      if (!aError) {
        dispatch_async(dispatch_get_main_queue(), ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_CreateGroup object:aGroup];

        });
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
      }
      else {
         [weakSelf showAlertWithMessage:NSLocalizedString(@"group.createFailure", @"Create group failure")];
     }
        
    }];
}





#pragma mark getter
- (UITableView *)table {
    if (!_table) {
        _table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = UIColor.whiteColor;
    }
    return _table;
}

- (ACDTextFieldCell *)groupNameCell {
    if (_groupNameCell == nil) {
        _groupNameCell = ACDTextFieldCell.new;
        _groupNameCell.nameLabel.text = @"Group Name";
        _groupNameCell.titleTextField.delegate = self;
    }
    return _groupNameCell;
}

- (ACDTextViewCell *)descriptionCell {
    if (_descriptionCell == nil) {
        _descriptionCell = ACDTextViewCell.new;
    }
    return _descriptionCell;
}

- (ACDMAXGroupNumberCell *)maxGroupNumberCell {
    if (_maxGroupNumberCell == nil) {
        _maxGroupNumberCell = ACDMAXGroupNumberCell.new;
        _maxGroupNumberCell.nameLabel.text = @"Maximum Mumber";
        _maxGroupNumberCell.maxGroupMemberField.delegate = self;
    }
    return _maxGroupNumberCell;
}

- (NSMutableArray<NSString *> *)invitees {
    if (_invitees == nil) {
        _invitees = [NSMutableArray array];
    }
    return _invitees;
}

- (AgoraChatGroupOptions *)groupOptions {
    if (_groupOptions == nil) {
        _groupOptions = AgoraChatGroupOptions.new;
    }
    return _groupOptions;
}

@end
