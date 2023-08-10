//
//  ACDAtGroupMembersViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "ACDAtGroupMembersViewController.h"

#import "UIViewController+HUD.h"
#import "AgoraNotificationNames.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"
#import "ACDContactCell.h"
#import "NSArray+AgoraSortContacts.h"
#import "AgoraUserModel.h"
#import "ACDGroupMemberAttributesCache.h"
#import "UserInfoStore.h"

@interface ACDAtGroupMembersViewController ()

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) AgoraChatGroup *group;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, strong) AgoraUserModel* allModel;

@end

@implementation ACDAtGroupMembersViewController

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
    [self _setupViews];
}

- (void)_setupViews
{
    self.title = @"@Mention";
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"154dfe"];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (AgoraUserModel *)allModel {
    if (!_allModel) {
        _allModel = [[AgoraUserModel alloc] initWithHyphenateId:@"ALL"];
        _allModel.nickname = @"ALL";
    }
    return _allModel;
}

- (void)cancelAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateUIWithResultList:(NSArray *)sourceList IsHeader:(BOOL)isHeader {
    NSMutableArray* members = [sourceList mutableCopy];
    if (isHeader) {
        [members addObject:self.group.owner];
        [members addObjectsFromArray:self.group.adminList];
        [self.dataArray removeAllObjects];
    }

    if (AgoraChatClient.sharedClient.currentUsername.length > 0)
        [members removeObject:AgoraChatClient.sharedClient.currentUsername];
    
    [ACDGroupMemberAttributesCache.shareInstance fetchCacheValueGroupId:self.groupId userIds:members key:GROUP_NICKNAME_KEY completion:^(AgoraChatError * _Nullable error, NSDictionary<NSString *,NSString *> * _Nonnull value) {
        NSMutableArray<NSString* >* usersNeedUserInfo = [NSMutableArray array];
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.length <= 0) {
                AgoraChatUserInfo* userInfo = [UserInfoStore.sharedInstance getUserInfoById:key];
                AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:key nickname:(userInfo.nickname.length > 0 ? userInfo.nickname : key)];
                [self.dataArray addObject:model];
                if (!userInfo || userInfo.nickname.length == 0)
                {
                    [usersNeedUserInfo addObject:key];
                }
            } else {
                AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:key nickname:obj];
                if (model) {
                    [self.dataArray addObject:model];
                }
            }
        }];
        if (usersNeedUserInfo.count > 0) {
            [UserInfoStore.sharedInstance fetchUserInfosFromServer:usersNeedUserInfo];
        }
        self.searchSource = self.dataArray;
        [self.table reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark reload data
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
//    if (self.isSearchState) {
//        return 1;
//    }
//    return  self.sectionTitles.count + 1;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchState) {
        return self.searchResults.count;
    }
    return self.dataArray.count + 1;
//    if (section == 0)
//        return 1;
//    return ((NSArray *)self.dataArray[section-1]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
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
        if (indexPath.row == 0 && indexPath.section == 0) {
            model = self.allModel;
        } else {
            model = self.dataArray[indexPath.row - 1];
        }
        
    }
    
    cell.model =  model;

    ACD_WS
    cell.tapCellBlock = ^{
        if (weakSelf.selectedCompletion) {
            weakSelf.selectedCompletion(model.hyphenateId,model.nickname);
        }
        [weakSelf cancelAction];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDContactCell*cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell && cell.tapCellBlock) {
        cell.tapCellBlock();
    }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//        return @"";
//    if (section-1 < self.sectionTitles.count) {
//        return self.sectionTitles[section-1];
//    }
//    return @"";
//}
//
//- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
//     return self.sectionTitles;
//}

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
    NSInteger pageSize = 20;
        
    ACD_WS

    [[AgoraChatClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupId cursor:aCursor pageSize:pageSize completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        weakSelf.cursor = aResult.cursor;

        [self endRefresh];
        
        if (!aError) {
            [weakSelf updateUIWithResultList:aResult.list IsHeader:aIsHeader];
        } else {
            [weakSelf showHint:@"Failed to get the group details, please try again later"];
        }
        

        if ([aResult.list count] < pageSize || aResult.cursor.length == 0) {
            [weakSelf endLoadMore];
            [weakSelf loadMoreCompleted];
            [weakSelf.table reloadData];
        } else {
            [weakSelf useLoadMore];
            [self tableViewDidTriggerFooterRefresh];
        }

    }];
}

@end
