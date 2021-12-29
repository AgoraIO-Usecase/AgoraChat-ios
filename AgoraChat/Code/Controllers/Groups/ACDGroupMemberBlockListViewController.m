//
//  ACDGroupMemberBlockViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberBlockListViewController.h"
#import "ACDContactCell.h"
#import "UIViewController+HUD.h"
#import "AgoraNotificationNames.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"
#import "AgoraUserModel.h"

@interface ACDGroupMemberBlockListViewController ()

@property (nonatomic, strong) AgoraChatGroup *group;

@end

@implementation ACDGroupMemberBlockListViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNotification:) name:KAgora_REFRESH_GROUP_INFO object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self useRefresh];
    
    if (self.group.permissionType == AgoraChatGroupPermissionTypeOwner || self.group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark refresh and load more
- (void)didStartRefresh {
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didStartLoadMore {
    [self tableViewDidTriggerFooterRefresh];
}



#pragma mark updateUIWithNotification
- (void)updateUIWithNotification:(NSNotification *)notify {
    [self tableViewDidTriggerHeaderRefresh];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearchState) {
        return self.searchResults.count;
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ACDContactCell height];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDContactCell *cell = (ACDContactCell *)[tableView dequeueReusableCellWithIdentifier:[ACDContactCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDContactCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *name = self.dataArray[indexPath.row];
    AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:name];
    cell.model = model;
    
    ACD_WS
    cell.tapCellBlock = ^{
        [weakSelf actionSheetWithUserId:name memberListType:ACDGroupMemberListTypeBlock group:weakSelf.group];
    };
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchBlocksWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchBlocksWithPage:self.page isHeader:NO];
}

- (void)fetchBlocksWithPage:(NSInteger)aPage
                 isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    ACD_WS
    [self showHint:NSLocalizedString(@"hud.load", @"Load data...")];
    //[self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];

    [[AgoraChatClient sharedClient].groupManager getGroupBlacklistFromServerWithId:self.group.groupId pageNumber:self.page pageSize:pageSize completion:^(NSArray *aMembers, AgoraChatError *aError) {
        [self hideHud];
        
        [self endRefresh];
        if (!aError) {
            if (aIsHeader) {
                [weakSelf.dataArray removeAllObjects];
            }

            [weakSelf.dataArray addObjectsFromArray:aMembers];
            [weakSelf.table reloadData];
        } else {
            NSString *errorStr = [NSString stringWithFormat:NSLocalizedString(@"group.ban.fetchFail", @"Fail to get blacklist: %@"), aError.errorDescription];
            [weakSelf showHint:errorStr];
        }
        
        if ([aMembers count] < pageSize) {
            [self endLoadMore];
        } else {
            [self useLoadMore];
        }
    }];
}

@end
