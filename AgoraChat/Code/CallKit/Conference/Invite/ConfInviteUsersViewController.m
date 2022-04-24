//
//  ConfInviteUsersViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "ConfInviteUsersViewController.h"

#import "EMRealtimeSearch.h"
#import "ConfInviteUserCell.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"

@interface ConfInviteUsersViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) NSArray *excludeUsers;
@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) NSString *cursor;
@property (nonatomic) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *searchDataArray;
@property (nonatomic, strong) NSMutableArray *inviteUsers;

@end

@implementation ConfInviteUsersViewController

- (instancetype)initWithGroupId:(NSString *)groupId excludeUsers:(NSArray *)excludeUserList {
    if (self = [super init]) {
        _groupId = groupId;
        _excludeUsers = excludeUserList;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:USERINFO_UPDATE object:nil];
    // Do any additional setup after loading the view.
    _dataArray = [NSMutableArray array];
    _searchDataArray = [NSMutableArray array];
    self.inviteUsers = [NSMutableArray array];
    
    [self _setupSubviews];
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)dealloc
{
    self.searchBar.delegate = nil;
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.text = NSLocalizedString(@"title.selectMembers", nil);
    
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(45);
        make.right.equalTo(self.view).offset(-45);
        make.top.equalTo(self.view).offset(13);
        make.height.equalTo(@25);
    }];
    
    UIButton *confirmButton = [[UIButton alloc] init];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [confirmButton setTitle:NSLocalizedString(@"close", nil) forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor colorWithRed:8 / 255.0 green:115 / 255.0 blue:222 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.equalTo(self.titleLabel.mas_right);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.titleLabel);
        make.bottom.equalTo(self.titleLabel);
    }];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    CGFloat color = 245 / 255.0;
    searchField.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
    self.searchBar.placeholder = NSLocalizedString(@"serchContact", nil);
    [self.view addSubview:self.searchBar];
    [self.view sendSubviewToBack:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
    }];
    
    self.searchTableView = [[UITableView alloc] init];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.rowHeight = 54;
    
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 54;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UINib *nib = [UINib nibWithNibName:@"ConfInviteUserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
    [self.searchTableView registerNib:nib forCellReuseIdentifier:@"ConfInviteUserCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? [self.searchDataArray count] : [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConfInviteUserCell";
    ConfInviteUserCell *cell = (ConfInviteUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *username = self.isSearching ? [self.searchDataArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = username;
    cell.imgView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.isChecked = [self.inviteUsers containsObject:username];
    AgoraChatUserInfo *userInfo = [UserInfoStore.sharedInstance getUserInfoById:username];
    if (userInfo) {
        if (userInfo.nickname.length > 0) {
            cell.nameLabel.text = userInfo.nickname;
        }
        if (userInfo.avatarUrl.length > 0) {
            NSURL *url = [NSURL URLWithString:userInfo.avatarUrl];
            if (url) {
                [cell.imgView sd_setImageWithURL:url];
            }
        }
    } else {
        [UserInfoStore.sharedInstance fetchUserInfosFromServer:@[username]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *username = self.isSearching ? [self.searchDataArray objectAtIndex:indexPath.row] : [self.dataArray objectAtIndex:indexPath.row];
    ConfInviteUserCell *cell = (ConfInviteUserCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL isChecked = [self.inviteUsers containsObject:username];
    if (isChecked) {
        [self.inviteUsers removeObject:username];
    } else {
        [self.inviteUsers addObject:username];
    }
    cell.isChecked = !isChecked;
    
    NSUInteger count = self.inviteUsers.count;
    self.titleLabel.text = count == 0 ? NSLocalizedString(@"title.selectMembers", nil) : [NSString stringWithFormat:@"%@(%lu)", NSLocalizedString(@"title.selectMembers", nil), (unsigned long)count];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!self.isSearching) {
        self.isSearching = YES;
        [self.view addSubview:self.searchTableView];
        [self.searchTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tableView);
            make.left.equalTo(self.tableView);
            make.right.equalTo(self.tableView);
            make.bottom.equalTo(self.tableView);
        }];
    }
    
    __weak typeof(self) weakSelf = self;
    [EMRealtimeSearch.shared realtimeSearchWithSource:self.dataArray searchText:searchBar.text collationStringSelector:nil resultBlock:^(NSArray *results) {
        if ([results count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchDataArray removeAllObjects];
                [weakSelf.searchDataArray addObjectsFromArray:results];
                [self.searchTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [[EMRealtimeSearch shared] realtimeSearchStop];
    [searchBar setShowsCancelButton:NO];
    [searchBar resignFirstResponder];

    self.isSearching = NO;
    [self.searchDataArray removeAllObjects];
    [self.searchTableView removeFromSuperview];
    [self.searchTableView reloadData];
    [self.tableView reloadData];
}

- (void)refreshTableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.view.window)
            [self.tableView reloadData];
    });
}

#pragma mark - Data

- (NSArray *)_getInvitableUsers:(NSArray *)aAllUsers
{
    NSMutableArray *retNames = [[NSMutableArray alloc] init];
    [retNames addObjectsFromArray:aAllUsers];
    
    NSString *loginName = [AgoraChatClient.sharedClient.currentUsername lowercaseString];
    if ([retNames containsObject:loginName]) {
        [retNames removeObject:loginName];
    }
    
    for (NSString *name in self.excludeUsers) {
        if ([retNames containsObject:name]) {
            [retNames removeObject:name];
        }
    }
    
    return retNames;
}

- (void)_fetchGroupMembersWithIsHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"fetchingGroupMember...", nil)];
    [AgoraChatClient.sharedClient.groupManager getGroupMemberListFromServerWithId:self.groupId cursor:self.cursor pageSize:pageSize completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        if (aError) {
            [weakSelf hideHud];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            
            [weakSelf showHint:[[NSString alloc] initWithFormat:NSLocalizedString(@"fetchGroupMemberFail", nil), aError.errorDescription]];
            return ;
        }
        
        weakSelf.cursor = aResult.cursor;
        
        if (aIsHeader) {
            [weakSelf.dataArray removeAllObjects];
            
            AgoraChatError *error = nil;
            AgoraChatGroup *group = [AgoraChatClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:weakSelf.groupId error:&error];
            if (!error) {
                NSArray *owners = [weakSelf _getInvitableUsers:@[group.owner]];
                [weakSelf.dataArray addObjectsFromArray:owners];
                
                NSArray *admins = [weakSelf _getInvitableUsers:group.adminList];
                [weakSelf.dataArray addObjectsFromArray:admins];
            }
        }
        
        [weakSelf hideHud];
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        
        NSArray *usernames = [weakSelf _getInvitableUsers:aResult.list];
        [weakSelf.dataArray addObjectsFromArray:usernames];
        [weakSelf.tableView reloadData];
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = @"";
    [self _fetchGroupMembersWithIsHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self _fetchGroupMembersWithIsHeader:NO];
}

#pragma mark - Action

- (void)confirmAction
{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.didSelectedUserList) {
            weakSelf.didSelectedUserList(self.inviteUsers);
        }
    }];
}

@end
