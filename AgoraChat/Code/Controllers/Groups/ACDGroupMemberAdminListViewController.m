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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupMemberWithNotification:) name:KACD_REFRESH_GROUP_MEMBER object:nil];
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
    NSMutableArray *tempArray = NSMutableArray.new;
    [tempArray addObject:self.group.owner];
    [tempArray addObjectsFromArray:self.group.adminList];
    
    [self sortContacts:tempArray];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.table reloadData];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        [weakSelf actionSheetWithUserId:model.hyphenateId memberListType:ACDGroupMemberListTypeALL group:weakSelf.group];
    };

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark NSNotification
- (void)updateGroupMemberWithNotification:(NSNotification *)aNotification {
    NSDictionary *dic = (NSDictionary *)aNotification.object;
    NSString* groupId = dic[kACDGroupId];
    ACDGroupMemberListType type = [dic[kACDGroupMemberListType] integerValue];
    
    if (![self.group.groupId isEqualToString:groupId] || type != ACDGroupMemberListTypeAdmin) {
        return;
    }
    
    [self tableViewDidTriggerHeaderRefresh];
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
                [weakSelf buildAdmins];
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
