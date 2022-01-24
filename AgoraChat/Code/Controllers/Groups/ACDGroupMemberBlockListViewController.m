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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupMemberWithNotification:) name:KACD_REFRESH_GROUP_MEMBER object:nil];
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



#pragma mark NSNotification
- (void)updateGroupMemberWithNotification:(NSNotification *)aNotification {
    NSDictionary *dic = (NSDictionary *)aNotification.object;
    NSString* groupId = dic[kACDGroupId];
    ACDGroupMemberListType type = [dic[kACDGroupMemberListType] integerValue];
    
    if (![self.group.groupId isEqualToString:groupId] || type != ACDGroupMemberListTypeBlock) {
        return;
    }
    
    [self tableViewDidTriggerHeaderRefresh];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    if (self.isSearchState) {
        return 1;
    }
    return  self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchState) {
        return self.searchResults.count;
    }
    return ((NSArray *)self.dataArray[section]).count;
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
    
    AgoraUserModel *model = nil;
    if (self.isSearchState) {
        model = self.searchResults[indexPath.row];
    }else {
        model = self.dataArray[indexPath.section][indexPath.row];
    }

    cell.model = model;
    
    ACD_WS
    cell.tapCellBlock = ^{
        [weakSelf actionSheetWithUserId:model.hyphenateId memberListType:ACDGroupMemberListTypeBlock group:weakSelf.group];
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

    [[AgoraChatClient sharedClient].groupManager getGroupBlacklistFromServerWithId:self.group.groupId pageNumber:self.page pageSize:pageSize completion:^(NSArray *aMembers, AgoraChatError *aError) {
        
        [self endRefresh];
        if (!aError) {
            [self updateUIWithResultList:aMembers IsHeader:aIsHeader];
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

- (void)updateUIWithResultList:(NSArray *)sourceList IsHeader:(BOOL)isHeader {
    
    if (isHeader) {
        [self.members removeAllObjects];
    }
    [self.members addObjectsFromArray:sourceList];
    
    [self sortContacts:self.members];

    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.table reloadData];
    });
}

@end
