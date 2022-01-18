//
//  ACDGroupMemberAdminListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberAdminListViewController.h"
#import "AgoraMemberCell.h"
#import "UIViewController+HUD.h"
#import "AgoraAddAdminViewController.h"
#import "AgoraNotificationNames.h"
#import "ACDContactCell.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"
#import "AgoraUserModel.h"

@interface ACDGroupMemberAdminListViewController ()

@property (nonatomic, strong) AgoraChatGroup *group;

@end

@implementation ACDGroupMemberAdminListViewController

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
    [self buildAdmins];
}

- (void)buildAdmins {
    [self.dataArray addObject:self.group.owner];
    [self.dataArray addObjectsFromArray:self.group.adminList];
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        [weakSelf actionSheetWithUserId:name memberListType:ACDGroupMemberListTypeALL group:weakSelf.group];
    };

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)updateUIWithNotification:(NSNotification *)aNotification
{
    id obj = aNotification.object;
    if (obj && [obj isKindOfClass:[AgoraChatGroup class]]) {
        self.group = (AgoraChatGroup *)obj;
    }
    [self.dataArray removeAllObjects];
    [self.dataArray addObject:self.group.owner];
    [self.dataArray addObjectsFromArray:self.group.adminList];
    [self.table reloadData];
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        AgoraChatError *error = nil;
        AgoraChatGroup *group = [[AgoraChatClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.group.groupId error:&error];
       
        
        if (!error) {
            weakSelf.group = group;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:weakSelf.group.adminList];
                [weakSelf.table reloadData];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showHint:NSLocalizedString(@"group.admin.fetchFail", @"failed to get the admin list, please try again later")];
            });
        }
    });
}


@end
