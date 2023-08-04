//
//  AgoraGroupListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupListViewController.h"
#import "MISScrollPage.h"
#import "AgoraGroupModel.h"
#import "AgoraNotificationNames.h"
#import "ACDGroupCell.h"
#import "ACDNoDataPlaceHolderView.h"
#import "ACDGroupInfoViewController.h"


@interface ACDGroupListViewController ()
@property (nonatomic, strong) ACDNoDataPlaceHolderView *noDataPromptView;

@end

@implementation ACDGroupListViewController
#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.searchBar.hidden = self.forward;
    if (self.forward) {
        [self.table mas_makeConstraints:^(MASConstraintMaker* make) {
            make.top.bottom.left.right.equalTo(self.view);
        }];
    }
    [self addNotifications];
    [self loadGroupsFromServer];

    self.table.tableFooterView = [[UIView alloc] init];
}

- (void)prepare {
    [super prepare];
    [self.view addSubview:self.noDataPromptView];
}

- (void)placeSubViews {
    [super placeSubViews];
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(48.0);
        make.centerX.left.right.equalTo(self.view);
    }];
}


- (void)dealloc {
    [self removeNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)loadGroupsFromServer {
    [self useRefresh];
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList:) name:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
    
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
}

#pragma mark - Action

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notification Method
- (void)refreshGroupList:(NSNotification *)notification {
    NSArray *groupList = [[AgoraChatClient sharedClient].groupManager getJoinedGroups];
    [self.dataArray removeAllObjects];
    for (AgoraChatGroup *group in groupList) {
        AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:group];
        if (model) {
            [self.dataArray addObject:model];
        }
    }
    self.searchSource = self.dataArray;
    [self.table reloadData];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchState) {
        return [self.searchResults count];
    }
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ACDGroupCell";
    ACDGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ACDGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.sender.hidden = !self.forward;
    if (self.isSearchState) {
        cell.model = self.searchResults[indexPath.row];
    }else {
        cell.model = self.dataArray[indexPath.row];
    }
    NSString *groupId = cell.model.group.groupId;
    cell.tapCellBlock = ^{
        if (self.selectedBlock) {
            self.selectedBlock(groupId);
        }
    };
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.forward) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AgoraGroupModel *model = nil;
    if (self.isSearchState) {
        model = self.searchResults[indexPath.row];
    }else {
        model = self.dataArray[indexPath.row];
    }
    
    if (self.selectedBlock) {
        self.selectedBlock(model.group.groupId);
    }
}

#pragma mark refresh and load more
- (void)didStartRefresh {
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didStartLoadMore {
    [self tableViewDidTriggerFooterRefresh];
}

#pragma mark - Data
- (void)tableViewDidTriggerHeaderRefresh
{
    if (self.isSearchState) {
        [self endRefresh];
        return;
    }

    self.page = 1;
    [self fetchJoinedGroupWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchJoinedGroupWithPage:self.page isHeader:NO];
}

- (void)fetchJoinedGroupWithPage:(NSInteger)aPage
                        isHeader:(BOOL)aIsHeader
{
    ACD_WS
    if (!aIsHeader) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    
    NSInteger pageSize = 50;
    [[AgoraChatClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:self.page pageSize:pageSize completion:^(NSArray *aList, AgoraChatError *aError) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];

        [self endRefresh];
        
        if (!aError && aList.count > 0) {
            if (aIsHeader) {
                [weakSelf.dataArray removeAllObjects];
            }
            for (AgoraChatGroup *group in aList) {
                AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:group];
                if (model) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            
            if (aList.count <= pageSize) {
                [self useLoadMore];
            }else {
                [self endLoadMore];
            }
            
            weakSelf.searchSource = [NSMutableArray arrayWithArray:weakSelf.dataArray];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [weakSelf.table reloadData];
            });
        }
    }];
}

#pragma mark getter and setter
- (UITableView *)table {
    if (_table == nil) {
        _table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.clipsToBounds = YES;
        _table.rowHeight = 54.0f;
    }
    return _table;
}

- (ACDNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = ACDNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:ImageWithName(@"no_search_result")];
        _noDataPromptView.prompt.text = @"The Group Does Not Exist";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}

@end
