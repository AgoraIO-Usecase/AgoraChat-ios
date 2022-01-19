//
//  ACDPublicGroupListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDPublicGroupListViewController.h"
#import "MISScrollPage.h"
#import "AgoraGroupCell.h"
#import "AgoraGroupModel.h"
#import "AgoraNotificationNames.h"
#import "AgoraGroupInfoViewController.h"

#import "ACDGroupNewCell.h"
#import "ACDNoDataPromptView.h"
#import "ACDGroupInfoViewController.h"


#define KPUBLICGROUP_PAGE_COUNT    20

@interface ACDPublicGroupListViewController ()<MISScrollPageControllerContentSubViewControllerDelegate>
@property (nonatomic, strong) ACDNoDataPromptView *noDataPromptView;
@property (nonatomic, strong) NSString *cursor;


@end

@implementation ACDPublicGroupListViewController
#pragma mark life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavbar];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self addNotifications];
    [self loadPublicGroupsFromServer];

    self.table.tableFooterView = [[UIView alloc] init];
    
    ACD_WS
    self.searchResultBlock = ^{
        if (weakSelf.searchResults.count == 0) {
            weakSelf.noDataPromptView.hidden = NO;
        }else {
            weakSelf.noDataPromptView.hidden = YES;
        }
        
        [weakSelf.table reloadData];
    };
    
    self.searchCancelBlock = ^{
        weakSelf.noDataPromptView.hidden = YES;
    };
}

- (void)setupNavbar {
    self.title = @"Public Groups";

    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, 50, 40);
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelButton setTitleColor:ButtonEnableBlueColor forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
    rightSpace.width = -2;
    [self.navigationItem setRightBarButtonItems:@[rightSpace,rightBar]];
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

- (void)loadPublicGroupsFromServer {
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
    static NSString *cellIdentifier = @"AgoraGroupCell";
    ACDGroupNewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ACDGroupNewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (self.isSearchState) {
        cell.model = self.searchResults[indexPath.row];
    }else {
        cell.model = self.dataArray[indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

#pragma mark - Data
- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchPublicGroupWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchPublicGroupWithPage:self.page isHeader:NO];
}

- (void)fetchPublicGroupWithPage:(NSInteger)aPage
                        isHeader:(BOOL)aIsHeader
{
    __weak typeof(self) weakSelf = self;
    if (!aIsHeader) {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    
    [[AgoraChatClient sharedClient].groupManager getPublicGroupsFromServerWithCursor:_cursor pageSize:KPUBLICGROUP_PAGE_COUNT completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
//        [self tableViewDidFinishTriggerHeader:YES];
        
        if (!aError) {
            NSArray *groups = [self getGroupsWithResultList:aResult.list];
            if ([_cursor isEqualToString:@""]) {
//                self.showRefreshFooter = NO;
                self.dataArray = [groups mutableCopy];
            }else {
                [self.dataArray addObjectsFromArray:groups];
            }
            weakSelf.cursor = aResult.cursor;
            weakSelf.searchSource = self.dataArray;
            [weakSelf.table reloadData];
        }
    }];
}

- (NSArray *)getGroupsWithResultList:(NSArray *)list {
    NSMutableArray *tGroups = NSMutableArray.new;
    for (AgoraChatGroup *group in list) {
        AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:group];
        if (model) {
            [tGroups addObject:model];
        }
    }
    return [tGroups copy];
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
    }
    return _table;
}

- (ACDNoDataPromptView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = ACDNoDataPromptView.new;
        [_noDataPromptView.noDataImageView setImage:ImageWithName(@"no_search_result")];
        _noDataPromptView.prompt.text = @"The Group Does Not Exist";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}

#pragma mark getter and setter


@end

#undef KPUBLICGROUP_PAGE_COUNT
