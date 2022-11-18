//
//  ACDNotificationSettingViewController.m
//  AgoraChat
//
//  Created by hxq on 2022/3/16.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDNotificationSettingViewController.h"
#import "ACDSilentModeSetViewController.h"
#import "ACDTitleDetailCell.h"
#import "ACDSubDetailCell.h"
#import "ACDNameSwitchCell.h"
#import "ACDDateHelper.h"

@interface ACDNotificationSettingViewController ()
@property (nonatomic , strong) AgoraChatSilentModeResult *silentModeItem;
@property (nonatomic , strong) NSArray *cells;
@property (nonatomic , strong) ACDTitleDetailCell *remindTypeCell;
@property (nonatomic , strong) ACDSubDetailCell *muteCell;
@property (nonatomic , strong) ACDNameSwitchCell *showPreTextCell;
@property (nonatomic , strong) ACDNameSwitchCell *soundCell;
@property (nonatomic , strong) ACDNameSwitchCell *vibrateCell;
@property (nonatomic , copy) NSString *navTitle;
@property (nonatomic , copy) NSString *muteCellNameTitle;
@property (nonatomic , copy) NSString *remindCellNameTitle;
@end

@implementation ACDNotificationSettingViewController

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
        [[AgoraChatClient sharedClient].pushManager getSilentModeForAllWithCompletion:^(AgoraChatSilentModeResult * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            [weakSelf hideHud];
            if (!aError) {
                weakSelf.silentModeItem = aResult;
                [weakSelf.table reloadData];
            }else{
                [weakSelf showHint:aError.errorDescription];
            }
        }];
    }else{
        
        AgoraChatConversationType chatType = AgoraChatConversationTypeGroupChat;
        if (self.notificationType == AgoraNotificationSettingTypeSingleChat) {
            chatType = AgoraChatConversationTypeChat;
        }
        [[AgoraChatClient sharedClient].pushManager getSilentModeForConversation:self.conversationID conversationType:chatType completion:^(AgoraChatSilentModeResult * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
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
    
    if (self.notificationType != AgoraNotificationSettingTypeSelf) {
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self remindTypeDefault];
        }];
        [alertController addAction:defaultAction];
        [defaultAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    }
    
    UIAlertAction *allAction = [UIAlertAction actionWithTitle:@"All Messages" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self remindTypeChange:AgoraChatPushRemindTypeAll];
    }];
    [alertController addAction:allAction];
    [allAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    if(self.notificationType != AgoraNotificationSettingTypeSingleChat)
    {
        UIAlertAction *metionAction = [UIAlertAction actionWithTitle:@"Only @Metions" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self remindTypeChange:AgoraChatPushRemindTypeMentionOnly];
        }];
        [alertController addAction:metionAction];
        [metionAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    }
    UIAlertAction *noneAction = [UIAlertAction actionWithTitle:@"Nothing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self remindTypeChange:AgoraChatPushRemindTypeNone];
    }];
    [alertController addAction:noneAction];
    
    [noneAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)muteAction {
    NSTimeInterval timestampNow = [[NSDate date] timeIntervalSince1970] * 1000;
    if (self.silentModeItem.expireTimestamp > timestampNow) {
        //先弹窗关闭再进去设置
        NSString *titleStr = @"Turn off Do Not Disturb?";
        NSString *infoStr = [NSString stringWithFormat:@"You have set Do Not Disturb until \n %@",self.muteCell.subDetailLabel.text];
        
        if (self.notificationType != AgoraNotificationSettingTypeSelf) {
            titleStr = [NSString stringWithFormat:@"Unmute this %@?",self.notificationType == AgoraNotificationSettingTypeGroup?@"Group":@"Thread"];
            infoStr = [NSString stringWithFormat:@"You have muted this %@ until \n %@",self.notificationType == AgoraNotificationSettingTypeGroup?@"Group":@"Thread",self.muteCell.subDetailLabel.text];
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleStr message:infoStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self closeMute];
        }];
        // [deleteAction setValue:TextLabelPinkColor forKey:@"titleTextColor"];
        
        [alertController addAction:sureAction];
        
        alertController.modalPresentationStyle = 0;
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
        ACDSilentModeSetViewController *controller = [[ACDSilentModeSetViewController alloc]init];
        controller.conversationID = self.conversationID;
        controller.notificationType = self.notificationType;
        ACD_WS
        controller.doneBlock = ^(AgoraChatSilentModeResult * _Nonnull item) {
            weakSelf.silentModeItem = item;
            [weakSelf.table reloadData];
        };
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}


- (void)closeMute
{
    AgoraChatSilentModeParam *param = [[AgoraChatSilentModeParam alloc] initWithParamType:AgoraChatSilentModeParamTypeDuration];
    param.silentModeDuration = 0;
    [self silentModeChange:param];
    
}

- (void)remindTypeChange:(AgoraChatPushRemindType)remindType {
    
    AgoraChatSilentModeParam *param = [[AgoraChatSilentModeParam alloc] initWithParamType:AgoraChatSilentModeParamTypeRemindType];
    param.remindType = remindType;
    [self silentModeChange:param];
  
}
- (void)silentModeChange:(AgoraChatSilentModeParam*)param
{
    ACD_WS
    if (self.notificationType == AgoraNotificationSettingTypeSelf) {
        [[AgoraChatClient sharedClient].pushManager setSilentModeForAll:param completion:^(AgoraChatSilentModeResult * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            if (!aError) {
                weakSelf.silentModeItem = aResult;
                [weakSelf.table reloadData];
            }else{
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"Fail")];
            }
        }];
    }else{
        AgoraChatConversationType type = AgoraChatConversationTypeGroupChat;
        if (self.notificationType == AgoraNotificationSettingTypeSingleChat) {
            type = AgoraChatConversationTypeChat;
        }
        [[AgoraChatClient sharedClient].pushManager setSilentModeForConversation:self.conversationID conversationType:type params:param completion:^(AgoraChatSilentModeResult * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            if (!aError) {
                weakSelf.silentModeItem = aResult;
                [weakSelf.table reloadData];
            }else{
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"Fail")];
            }
        }];
    }
}
- (void)remindTypeDefault {
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Waiting..")];
    ACD_WS
    AgoraChatConversationType type = AgoraChatConversationTypeGroupChat;
    if (self.notificationType == AgoraNotificationSettingTypeSingleChat) {
        type = AgoraChatConversationTypeChat;
    }
    [[AgoraChatClient sharedClient].pushManager clearRemindTypeForConversation:self.conversationID conversationType:type completion:^(AgoraChatSilentModeResult * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
        [weakSelf hideHud];
        if (!aError) {
            weakSelf.silentModeItem = aResult;
            [weakSelf.table reloadData];
            
        }else{
            [weakSelf showHint:aError.errorDescription];
        }
    }];
}


- (void)showPreTextAction {
    AgoraChatPushDisplayStyle style = AgoraChatPushDisplayStyleSimpleBanner;
    if (self.showPreTextCell.aSwitch.on) {
        style = AgoraChatPushDisplayStyleMessageSummary;
    }
    ACD_WS
    [[AgoraChatClient sharedClient].pushManager updatePushDisplayStyle:style completion:^(AgoraChatError * _Nonnull aError) {
        if (aError) {
            [weakSelf showHint:aError.errorDescription];
            
        }
    }];
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
            return 3;
        }
        return 2;
        
    }else if (self.notificationType == AgoraNotificationSettingTypeSingleChat)
    {
        return 2;
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
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        cell = self.cells[indexPath.row];
    }else{
        cell =self.cells[indexPath.row + 3];
    }
    
    if (cell == _muteCell) {
        [self changeMuteCell];
    }
    if (cell == _remindTypeCell) {
        [self changeRemindCell];
    }
    if (cell == _showPreTextCell) {
        
        [_showPreTextCell.aSwitch setOn:[AgoraChatClient sharedClient].pushManager.pushOptions.displayStyle == AgoraChatPushDisplayStyleMessageSummary];
    }
    if (cell == _vibrateCell) {
        [_vibrateCell.aSwitch setOn:[ACDDemoOptions sharedOptions].playVibration];
    }
    if (cell == _soundCell) {
        [_soundCell.aSwitch setOn:[ACDDemoOptions sharedOptions].playNewMsgSound];
    }
    return cell;
}


#pragma mark Change cell data
- (void)changeMuteCell
{
    NSTimeInterval timestampNow = [[NSDate date] timeIntervalSince1970] * 1000;
    if (self.silentModeItem.expireTimestamp == 0 || self.silentModeItem.expireTimestamp < timestampNow) {
        if(self.notificationType == AgoraNotificationSettingTypeSelf)
        {
            self.muteCell.detailLabel.text = @"Turn On";
        }else{
            self.muteCell.detailLabel.text = @"Mute";
        }
        self.muteCell.subDetailLabel.text =  @"";
        self.muteCell.showSubDetailLabel = NO;
    }else{
        if(self.notificationType == AgoraNotificationSettingTypeSelf)
        {
            self.muteCell.detailLabel.text = @"Turn Off";
        }else{
            self.muteCell.detailLabel.text = @"Unmute";
        }
        self.muteCell.subDetailLabel.text = [ACDDateHelper stringMonthEnglishFromTimestamp:self.silentModeItem.expireTimestamp];
        self.muteCell.showSubDetailLabel = YES;
    }
}

- (void)changeRemindCell
{
    
    NSString * typeStr = @"All Messages";
    switch (self.silentModeItem.remindType) {
        case AgoraChatPushRemindTypeAll:
            typeStr = @"All Messages";
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
    
    if (self.notificationType != AgoraNotificationSettingTypeSelf) {
        if (!self.silentModeItem.isConversationRemindTypeEnabled) {
            typeStr = @"Default";
        }
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

-(ACDSubDetailCell *)muteCell{
    if (_muteCell == nil) {
        _muteCell = [[ACDSubDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDSubDetailCell reuseIdentifier]];
        _muteCell.nameLabel.text = self.muteCellNameTitle;
        ACD_WS
        _muteCell.tapCellBlock = ^{
            [weakSelf muteAction];
        };
    }
    return _muteCell;
}
-(ACDNameSwitchCell *)showPreTextCell{
    if (_showPreTextCell == nil) {
        _showPreTextCell = [[ACDNameSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDNameSwitchCell reuseIdentifier]];
        _showPreTextCell.nameLabel.text = @"Show Preview Text";
        ACD_WS
        _showPreTextCell.switchActionBlock = ^(BOOL isOn) {
            [weakSelf showPreTextAction];
        };
    }
    return _showPreTextCell;
}
-(ACDNameSwitchCell *)soundCell{
    if (_soundCell == nil) {
        _soundCell = [[ACDNameSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDNameSwitchCell reuseIdentifier]];
        _soundCell.nameLabel.text = @"Alert Sound";
        _soundCell.switchActionBlock = ^(BOOL isOn) {
            [ACDDemoOptions sharedOptions].playNewMsgSound = isOn;
        };
    }
    return _soundCell;
}
-(ACDNameSwitchCell *)vibrateCell{
    if (_vibrateCell == nil) {
        _vibrateCell = [[ACDNameSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDNameSwitchCell reuseIdentifier]];
        _vibrateCell.nameLabel.text = @"Vibrate";
        _vibrateCell.switchActionBlock = ^(BOOL isOn) {
            [ACDDemoOptions sharedOptions].playVibration = isOn;
        };
    }
    return _vibrateCell;
}
-(NSArray *)cells
{
    if (_cells == nil) {
        switch (self.notificationType) {
            case AgoraNotificationSettingTypeSelf:
                _cells = @[self.muteCell,self.remindTypeCell,self.showPreTextCell,self.soundCell,self.vibrateCell];
                break;
            case AgoraNotificationSettingTypeSingleChat:
                _cells = @[self.muteCell,self.remindTypeCell];
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
                self.remindCellNameTitle = @"Notification Setting";
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
