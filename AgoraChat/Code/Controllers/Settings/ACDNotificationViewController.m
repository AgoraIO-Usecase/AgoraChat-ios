//
//  ACDNotificationViewController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/9.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDNotificationViewController.h"
#import "ACDTitleSwitchCell.h"


#define kInfoHeaderViewHeight 320.0
#define kHeaderInSection  30.0

@interface ACDNotificationViewController ()

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
    
    if (indexPath.section == 0 ) {
        if (indexPath.row == 0) {
            cell.nameLabel.text = @"Messages";
            [cell.aSwitch setOn:YES animated:YES];
            cell.switchActionBlock = ^(BOOL isOn) {
                
            };
        }else if(indexPath.row == 1){
            cell.nameLabel.text = @"Only Show Unread Messages";
            [cell.aSwitch setOn:YES animated:YES];
            cell.switchActionBlock = ^(BOOL isOn) {
                
            };

        }else {
            cell.nameLabel.text = @"Show Preview Text";
            [cell.aSwitch setOn:YES animated:YES];
            cell.switchActionBlock = ^(BOOL isOn) {
                
            };

        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.nameLabel.text = @"Message Tone";
            [cell.aSwitch setOn:YES animated:YES];
            cell.switchActionBlock = ^(BOOL isOn) {
                
            };
        }else {
            cell.nameLabel.text = @"Vibrate";
            [cell.aSwitch setOn:YES animated:YES];
            cell.switchActionBlock = ^(BOOL isOn) {
                
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
        _table.rowHeight = [ACDTitleSwitchCell height];
    }
    return _table;
}


@end
#undef kInfoHeaderViewHeight
#undef kHeaderInSection




