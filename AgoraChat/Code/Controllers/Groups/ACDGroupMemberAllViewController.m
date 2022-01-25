//
//  ACDGroupMemberAllViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberAllViewController.h"
#import "AgoraGroupOccupantsViewController.h"
#import "UIViewController+HUD.h"
#import "AgoraNotificationNames.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"
#import "ACDContactCell.h"
#import "NSArray+AgoraSortContacts.h"
#import "AgoraUserModel.h"

@interface ACDGroupMemberAllViewController ()

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) AgoraChatGroup *group;
@property (nonatomic, strong) NSString *cursor;

@end

@implementation ACDGroupMemberAllViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
        self.groupId = self.group.groupId;
        
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
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)updateUIWithResultList:(NSArray *)sourceList IsHeader:(BOOL)isHeader {
    
    if (isHeader) {
        [self.members removeAllObjects];
        [self.members addObject:self.group.owner];
        [self.members addObjectsFromArray:self.group.adminList];
    }

    [self.members addObjectsFromArray:sourceList];
    
    [self sortContacts:self.members];

    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.table reloadData];
    });
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateUI {
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark updateUIWithNotification
- (void)updateGroupMemberWithNotification:(NSNotification *)aNotification {
    NSDictionary *dic = (NSDictionary *)aNotification.object;
    NSString* groupId = dic[kACDGroupId];
    
    if (![self.group.groupId isEqualToString:groupId]) {
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
    
    cell.model =  model;
    if (model.hyphenateId == self.group.owner) {
        cell.detailLabel.text = @"owner";
    } else if([self.group.adminList containsObject:model.hyphenateId]){
        cell.detailLabel.text = @"admin";
    }else {
        cell.detailLabel.text = @"";
    }

    ACD_WS
    cell.tapCellBlock = ^{
        [weakSelf actionSheetWithUserId:model.hyphenateId memberListType:ACDGroupMemberListTypeALL group:weakSelf.group];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark refresh and load more
- (void)didStartRefresh {
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didStartLoadMore {
    [self tableViewDidTriggerFooterRefresh];
}


#pragma mark - private
- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = @"";
    [self fetchMembersWithCursor:self.cursor isHeader:YES];

}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithCursor:self.cursor isHeader:NO];
}


- (void)fetchMembersWithCursor:(NSString *)aCursor
                      isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
        
    ACD_WS

    [[AgoraChatClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupId cursor:aCursor pageSize:pageSize completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        weakSelf.cursor = aResult.cursor;

        [self endRefresh];
        
        if (!aError) {
            [weakSelf updateUIWithResultList:aResult.list IsHeader:aIsHeader];
        } else {
            [weakSelf showHint:@"Failed to get the group details, please try again later"];
        }
        

        if ([aResult.list count] < pageSize) {
            [weakSelf endLoadMore];
            [weakSelf loadMoreCompleted];
        } else {
            [weakSelf useLoadMore];
        }

        [weakSelf.table reloadData];

    }];
}


@end
