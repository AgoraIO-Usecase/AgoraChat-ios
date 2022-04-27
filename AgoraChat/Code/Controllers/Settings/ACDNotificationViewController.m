//
//  ACDNotificationViewController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/9.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDNotificationViewController.h"
#import "ACDTitleSwitchCell.h"
#import "ACDTitleDetailCell.h"


#define kInfoHeaderViewHeight 320.0
#define kHeaderInSection  30.0

@interface ACDNotificationViewController ()

@property (nonatomic,assign) BOOL isSimpleBanner;
@property (nonatomic,strong) ACDTitleDetailCell *notificationCell;
@property (nonatomic,strong) ACDTitleDetailCell *noDistrubCell;

@end

@implementation ACDNotificationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"Notifications" action:@selector(back) actionTarget:self];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (AgoraChatPushDisplayStyle )pushDisplayStyle {
    return [AgoraChatClient sharedClient].pushManager.pushOptions.displayStyle;
}


#pragma mark actions
- (void)msgRemindChangeWithSwitchOn:(BOOL)isOn {
    ACDDemoOptions *options = [ACDDemoOptions sharedOptions];
    options.isReceiveNewMsgNotice = isOn;
    [options archive];
    [self.table reloadData];
}

- (void)updatePushDisplayStyle:(AgoraChatPushDisplayStyle)pushDisplayStyle {
    [[AgoraChatClient sharedClient].pushManager updatePushDisplayStyle:pushDisplayStyle completion:^(AgoraChatError * _Nonnull error) {
        if (error) {
            [self showHint:error.debugDescription];
        }else {
            [self.table reloadData];
        }
    }];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderInSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kHeaderInSection)];
    
    UILabel *label = [self sectionTitleLabel];
    if (section == 0) {
        label.text = @"Push Notifications";
    }else {
        label.text = @"Sound n’ Vibrate";
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
    label.text = @"setting";
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ACDTitleSwitchCell *cell = (ACDTitleSwitchCell *)[tableView dequeueReusableCellWithIdentifier:[ACDTitleSwitchCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDTitleSwitchCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    ACDDemoOptions *options = [ACDDemoOptions sharedOptions];

    if (indexPath.section == 0 ) {
        if (indexPath.row == 0) {
            return self.notificationCell;
        }else if(indexPath.row == 1){
            return self.noDistrubCell;
        }else {
            cell.nameLabel.text = @"Show Preview Text";
            [cell.aSwitch setOn:![self isSimpleBanner] animated:NO];
            cell.switchActionBlock = ^(BOOL isOn) {
                if (isOn) {
                    [self updatePushDisplayStyle:AgoraChatPushDisplayStyleMessageSummary];
                }else {
                    [self updatePushDisplayStyle:AgoraChatPushDisplayStyleSimpleBanner];
                }
            };
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.nameLabel.text = @"Alert Sound";
            [cell.aSwitch setOn:options.playNewMsgSound animated:NO];
            cell.switchActionBlock = ^(BOOL isOn) {
                options.playNewMsgSound = isOn;
                [self.table reloadData];
            };
        }else {
            cell.nameLabel.text = @"Vibrate";
            [cell.aSwitch setOn:options.playVibration animated:NO];
            cell.switchActionBlock = ^(BOOL isOn) {
                options.playVibration = isOn;
                [self.table reloadData];
            };

        }
    }
    
    return cell;
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
        [_table registerClass:[ACDTitleSwitchCell class] forCellReuseIdentifier:[ACDTitleSwitchCell reuseIdentifier]];
        [_table registerClass:[ACDTitleDetailCell class] forCellReuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];

        _table.rowHeight = [ACDTitleSwitchCell height];
    }
    return _table;
}

- (ACDTitleDetailCell *)notificationCell {
    if (_notificationCell == nil) {
        _notificationCell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
        _notificationCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _notificationCell.nameLabel.text = @"Notification Setting";
        _notificationCell.detailLabel.text = @"All Messages";
        _notificationCell.tapCellBlock = ^{
            
        };
    }
    return _notificationCell;
}

- (ACDTitleDetailCell *)noDistrubCell {
    if (_noDistrubCell == nil) {
        _noDistrubCell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
        _noDistrubCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _noDistrubCell.nameLabel.text = @"Do Not Disturb";
        _noDistrubCell.detailLabel.text = @"Turn On";
        _noDistrubCell.tapCellBlock = ^{
            
        };
    }
    return _noDistrubCell;

}

-  (BOOL)isSimpleBanner {
    return [self pushDisplayStyle] == AgoraChatPushDisplayStyleSimpleBanner;
}


@end
#undef kInfoHeaderViewHeight
#undef kHeaderInSection



