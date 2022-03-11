//
//  ACDChatDetailViewController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDChatDetailViewController.h"
#import "ACDTitleDetailCell.h"
#import "AgoraGroupPermissionCell.h"
#import "ACDNoDisturbViewController.h"
#import "ACDInfoSwitchCell.h"
#import "ACDInfoDetailCell.h"


@interface ACDChatDetailViewController ()
@property (nonatomic,strong) NSString *noDisturbState;
@property (nonatomic,strong) ACDInfoDetailCell *searchHistoryCell;
@property (nonatomic,strong) ACDInfoSwitchCell *silentModeCell;
@property (nonatomic,strong) ACDInfoSwitchCell *pinTopCell;

@end

@implementation ACDChatDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"Back" action:@selector(back) actionTarget:self];

    self.noDisturbState = AgoraChatClient.sharedClient.pushManager.pushOptions.silentModeEnabled ?@"ON":@"Off";
    [self.table reloadData];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark private method
- (void)goNodisturbPage {
    ACDNoDisturbViewController *vc = ACDNoDisturbViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return self.searchHistoryCell;
        case 1:
            return self.silentModeCell;
        case 2:
            return self.pinTopCell;
        default:
            break;
    }
    
    return UITableViewCell.new;
}

#pragma mark getter and setter
- (ACDInfoDetailCell *)searchHistoryCell {
    if (_searchHistoryCell == nil) {
        _searchHistoryCell = [[ACDInfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        _searchHistoryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [_searchHistoryCell.iconImageView setImage:ImageWithName(@"chat_setting_search")];
        _searchHistoryCell.nameLabel.text = @"Search Message History";
        _searchHistoryCell.detailLabel.text = @"";
        ACD_WS
        _searchHistoryCell.tapCellBlock = ^{

        };
        
    }
    return _searchHistoryCell;
}


- (ACDInfoSwitchCell *)silentModeCell {
    if (_silentModeCell == nil) {
        _silentModeCell = [[ACDInfoSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoSwitchCell reuseIdentifier]];
        [_silentModeCell.iconImageView setImage:ImageWithName(@"chat_setting_mute")];
        _silentModeCell.nameLabel.text = @"Mute Notification";
        
    }
    return _silentModeCell;
}

- (ACDInfoSwitchCell *)pinTopCell {
    if (_pinTopCell == nil) {
        _pinTopCell = [[ACDInfoSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoSwitchCell reuseIdentifier]];
        [_pinTopCell.iconImageView setImage:ImageWithName(@"chat_setting_top")];
        _pinTopCell.nameLabel.text = @"Sticky on Top";
    }
    return _pinTopCell;

}
@end

