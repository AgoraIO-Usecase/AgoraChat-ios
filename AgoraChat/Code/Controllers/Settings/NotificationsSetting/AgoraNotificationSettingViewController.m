//
//  AgoraNotificationSettingViewController.m
//  AgoraChat
//
//  Created by hxq on 2022/3/16.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraNotificationSettingViewController.h"
#import "AgoraSilentModeSetViewController.h"
#import "ACDTitleDetailCell.h"
#import "AgoraSubDetailCell.h"
#import "AgoraChatDateHelper.h"

@interface AgoraNotificationSettingViewController ()
@property (nonatomic , strong) AgoraChatSilentModeItem *silentModeItem;
@property (nonatomic , strong) NSArray *cells;
@property (nonatomic , strong) ACDTitleDetailCell *remindTypeCell;
@property (nonatomic , strong) AgoraSubDetailCell *muteCell;
@property (nonatomic , copy) NSString *navTitle;
@property (nonatomic , copy) NSString *muteCellNameTitle;
@property (nonatomic , copy) NSString *remindCellNameTitle;
@end

@implementation AgoraNotificationSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if(@available(iOS 15.0,*) ){
        self.table.sectionHeaderTopPadding = 0.0f;
    }
    [self setNavBar];
    [self getDataFromSever];
    
}

- (void)setNavBar {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"black_goBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [backButton setTitle:self.navTitle forState:UIControlStateNormal];
    [backButton setTitleColor:TextLabelBlackColor forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)getDataFromSever
{
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Loading..")];
    ACD_WS
    if (self.notificationType == AgoraNotificationSettingTypeSelf) {
        [[AgoraChatClient sharedClient].pushManager getSilentModeForSelfWithCompletion:^(AgoraChatSilentModeItem * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            [weakSelf hideHud];
            if (!aError) {
                weakSelf.silentModeItem = aResult;
                [weakSelf.table reloadData];
            }else{
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"fail")];
            }
        }];
    }else{
        
        AgoraChatConversationType chatType = AgoraChatConversationTypeGroupChat;
        if (self.notificationType == AgoraNotificationSettingTypeSingleChat) {
            chatType = AgoraChatConversationTypeChat;
        }
        [[AgoraChatClient sharedClient].pushManager getSilentModeForConversation:self.conversationID conversationType:chatType Completion:^(AgoraChatSilentModeItem * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            [weakSelf hideHud];
            if (!aError) {
                weakSelf.silentModeItem = aResult;
                [weakSelf.table reloadData];
            }else{
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"fail")];
            }
        }];
    }
}

#pragma mark - action
- (void)remindTypeAction {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
   
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self remindTypeChange:AgoraChatPushRemindTypeDefault];
    }];
    [alertController addAction:defaultAction];
    
    UIAlertAction *allAction = [UIAlertAction actionWithTitle:@"All Messages" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self remindTypeChange:AgoraChatPushRemindTypeAll];
    }];
    [alertController addAction:allAction];
    
    UIAlertAction *metionAction = [UIAlertAction actionWithTitle:@"Only @Metions" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self remindTypeChange:AgoraChatPushRemindTypeMentionOnly];
    }];
    [alertController addAction:metionAction];
    
    UIAlertAction *noneAction = [UIAlertAction actionWithTitle:@"Nothing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self remindTypeChange:AgoraChatPushRemindTypeNone];
    }];
    [alertController addAction:noneAction];
    
    [defaultAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    [allAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    [metionAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    [noneAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
   
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)muteAction {
    AgoraSilentModeSetViewController *controller = [[AgoraSilentModeSetViewController alloc]init];
    controller.conversationID = self.conversationID;
    controller.notificationType = self.notificationType;
    ACD_WS
    controller.doneBlock = ^(AgoraChatSilentModeItem * _Nonnull item) {
        weakSelf.silentModeItem.expireTimestamp = item.expireTimestamp;
        [weakSelf.table reloadData];
    };
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)remindTypeChange:(AgoraChatPushRemindType)remindType
{
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Waiting..")];
    ACD_WS
    AgoraChatSilentModeParam *param = [[AgoraChatSilentModeParam alloc] init];
    param.paramType = AgoraChatSilentModeParamTypeRemindType;
    param.remindType = remindType;
    if (self.notificationType == AgoraNotificationSettingTypeSelf) {
        [[AgoraChatClient sharedClient].pushManager setSilentModeForSelf:param completion:^(AgoraChatSilentModeItem * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            [weakSelf hideHud];
            if (!aError) {
                weakSelf.silentModeItem.remindType = aResult.remindType;
                [weakSelf.table reloadData];
            }else{
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"fail")];
            }
        }];
    }else{
        AgoraChatConversationType type = AgoraChatConversationTypeGroupChat;
        if (self.notificationType == AgoraNotificationSettingTypeSingleChat) {
            type = AgoraChatConversationTypeChat;
        }
        [[AgoraChatClient sharedClient].pushManager setSilentModeForConversation:self.conversationID conversationType:type parms:param completion:^(AgoraChatSilentModeItem * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            [weakSelf hideHud];
            if (!aError) {
                weakSelf.silentModeItem.remindType = aResult.remindType;
                [weakSelf.table reloadData];
            }else{
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"fail")];
            }
        }];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.notificationType == AgoraNotificationSettingTypeSelf) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.notificationType == AgoraNotificationSettingTypeSelf) {
        if (section == 0) {
            return 2;
        }
        return 0;
        
    }else if (self.notificationType == AgoraNotificationSettingTypeSingleChat)
    {
        return 1;
    }else{
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.notificationType == AgoraNotificationSettingTypeSelf) {
        return 30.0f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.notificationType != AgoraNotificationSettingTypeSelf) {
        return [UIView new];
    }
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30.0f)];
    
    UILabel *label = [self sectionTitleLabel];
    if (section == 0) {
        label.text = @"Push Notifications";
    }else {
        label.text = @"In-App Notifications";
    }
    [sectionView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sectionView);
        make.left.equalTo(sectionView).offset(16.0);
    }];
    
    return sectionView;
}

- (UILabel *)sectionTitleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = TextLabelGrayColor;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = self.cells[indexPath.row];
    if (cell == self.muteCell) {
        [self changeMuteCell];
    }
    if (cell == self.remindTypeCell) {
        [self changeRemindCell];
    }
    return cell;
}


#pragma mark other
- (void)changeMuteCell
{
    if (self.silentModeItem.expireTimestamp == 0) {
        self.muteCell.detailLabel.text = @"Mute";
        self.muteCell.subDetailLabel.text =  @"";
        self.muteCell.showSubDetailLabel = NO;
    }else{
        self.muteCell.detailLabel.text = @"Unmute";
        self.muteCell.subDetailLabel.text = [AgoraChatDateHelper stringMonthEnglishFromTimestamp:self.silentModeItem.expireTimestamp];
        self.muteCell.showSubDetailLabel = YES;
    }
}

- (void)changeRemindCell
{
    NSString * typeStr = @"";
    switch (self.silentModeItem.remindType) {
        case AgoraChatPushRemindTypeAll:
            typeStr = @"All Messages";
            break;
        case AgoraChatPushRemindTypeDefault:
            typeStr = @"Default";
            break;
        case AgoraChatPushRemindTypeMentionOnly:
            typeStr = @"Only @Metions";
            break;
        case AgoraChatPushRemindTypeNone:
            typeStr = @"Nothing";
            break;
        default:
            break;
    }
    self.remindTypeCell.detailLabel.text = typeStr;
}


#pragma mark getter and setter

- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = COLOR_HEX(0xFFFFFF);
        _table.rowHeight = 54.0f;
    }
    return _table;
}

-(ACDTitleDetailCell *)remindTypeCell
{
    if (_remindTypeCell == nil) {
        _remindTypeCell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
        _remindTypeCell.nameLabel.text = self.remindCellNameTitle;
        _remindTypeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        ACD_WS
        _remindTypeCell.tapCellBlock = ^{
            [weakSelf remindTypeAction];
        };
    }
    return _remindTypeCell;
}

-(AgoraSubDetailCell *)muteCell{
    if (_muteCell == nil) {
        _muteCell = [[AgoraSubDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[AgoraSubDetailCell reuseIdentifier]];
        _muteCell.nameLabel.text = self.muteCellNameTitle;
        ACD_WS
        _muteCell.tapCellBlock = ^{
            [weakSelf muteAction];
        };
    }
    return _muteCell;
}

-(NSArray *)cells
{
    if (_cells == nil) {
        switch (self.notificationType) {
            case AgoraNotificationSettingTypeSelf:
                _cells = @[self.muteCell,self.remindTypeCell];
                break;
            case AgoraNotificationSettingTypeSingleChat:
                _cells = @[self.muteCell];
                break;
            case AgoraNotificationSettingTypeGroup:
                _cells = @[self.muteCell,self.remindTypeCell];
                break;
            case AgoraNotificationSettingTypeThread:
                _cells = @[self.muteCell,self.remindTypeCell];
                break;
            default:
                break;
        }
    }
    return _cells;
}

-(NSString *)navTitle
{
    if (_navTitle == nil) {
        switch (self.notificationType) {
            case AgoraNotificationSettingTypeSelf:
                _navTitle = @"Notifications";
                self.muteCellNameTitle = @"Do Not Disturb";
                self.remindCellNameTitle = @"Notification Setting";
                break;
            case AgoraNotificationSettingTypeSingleChat:
                _navTitle = @"Contact Notifications";
                self.muteCellNameTitle = @"Mute this Contact";
                break;
            case AgoraNotificationSettingTypeGroup:
                _navTitle = @"Group Notifications";
                self.muteCellNameTitle = @"Mute this Group";
                self.remindCellNameTitle = @"Frequency";
                break;
            case AgoraNotificationSettingTypeThread:
                _navTitle = @"Thead Notifications";
                self.muteCellNameTitle = @"Mute this Thread";
                self.remindCellNameTitle = @"Frequency";
                break;
            default:
                break;
        }
    }
    return _navTitle;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end