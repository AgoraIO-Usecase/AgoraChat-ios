//
//  AgoraChatThreadMembersViewController.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/3/13.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraChatThreadMembersViewController.h"
#import "UIViewController+HUD.h"
#import "AgoraNotificationNames.h"
#import "ACDContainerSearchTableViewController+GroupMemberList.h"
#import "ACDContactCell.h"
#import "NSArray+AgoraSortContacts.h"
#import "AgoraUserModel.h"
#import "AgoraChatThreadListNavgation.h"
#import "UserInfoStore.h"
@interface AgoraChatThreadMembersViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSString *threadId;
@property (nonatomic, strong) AgoraChatCursorResult *cursor;
@property (nonatomic) AgoraChatThreadListNavgation *navView;
@property (nonatomic) BOOL loadMoreFinished;
@property (nonatomic) NSMutableArray *dataArray;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) AgoraChatGroup *group;
@end

@implementation AgoraChatThreadMembersViewController

- (instancetype)initWithThread:(NSString *)threadId group:(AgoraChatGroup *)group{
    if ([super init]) {
        self.threadId = threadId;
        self.group = group;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupMemberWithNotification:) name:KACD_REFRESH_GROUP_MEMBER object:nil];
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navView];
    [self.view addSubview:self.tableView];
    [self tableViewDidTriggerHeaderRefresh];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, EMNavgationHeight, EMScreenWidth, EMScreenHeight - EMNavgationHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollsToTop = NO;
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor blackColor];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"pull down refresh"];
        _tableView.refreshControl = refreshControl;
        [_tableView.refreshControl addTarget:self action:@selector(didStartRefresh) forControlEvents:UIControlEventValueChanged];
    }
    return _tableView;
}

- (void)updateUIWithResultList:(NSArray *)sourceList IsHeader:(BOOL)isHeader {
    [_tableView.refreshControl endRefreshing];
    for (NSString *userName in sourceList) {
        AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:userName];
        [self.dataArray addObject:model];
    }
    [self.tableView reloadData];
}

- (AgoraChatThreadListNavgation *)navView {
    if (!_navView) {
        _navView = [[AgoraChatThreadListNavgation alloc] initWithFrame:CGRectMake(0, 0, EMScreenWidth, EMNavgationHeight)];
        ACD_WS
        _navView.backBlock = ^{
            [weakSelf backAction];
        };
        [_navView setTitle:@"Thead members"];
    }
    return _navView;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateUI {
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark updateUIWithNotification
- (void)updateGroupMemberWithNotification:(NSNotification *)aNotification {
    NSDictionary *dic = (NSDictionary *)aNotification.object;
    NSString* threadId = dic[kACDThreadId];
    
    if (![self.threadId isEqualToString:threadId]) {
        return;
    }
    
    [self tableViewDidTriggerHeaderRefresh];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    AgoraUserModel *model = self.dataArray[indexPath.row];
    cell.model =  model;
    ACD_WS
    cell.tapCellBlock = ^{
        [weakSelf leaveThread:model.hyphenateId];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count - 2 == indexPath.row && self.loadMoreFinished && self.cursor.list.count == 20) {
        [self didStartLoadMore];
    }
}

- (void)leaveThread:(NSString *)member {
    if (!self.group) {
        return;
    }
    NSMutableArray *admins = [NSMutableArray arrayWithArray:self.group.adminList];
    [admins addObject:self.group.owner];
    BOOL contain = NO;
    NSString *userName = [[AgoraChatClient.sharedClient currentUsername] lowercaseString];
    for (NSString *uid in admins) {
        if ([[uid lowercaseString] isEqualToString:userName] && ![uid isEqualToString:member]) {
            contain = YES;
            break;
        }
    }
    if (contain == NO) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:member message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *makeRemoveAction = [UIAlertAction alertActionWithTitle:@"Remove From Thread" iconImage:ImageWithName(@"remove") textColor:TextLabelPinkColor alignment:NSTextAlignmentLeft completion:^{
        [self makeRemoveThread:member];
    }];
   
    [alertController addAction:makeRemoveAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)makeRemoveThread:(NSString *)member  {
    [AgoraChatClient.sharedClient.threadManager removeMemberFromChatThread:member threadId:self.threadId completion:^(AgoraChatError *aError) {
        if (!aError) {
            NSUInteger index = 0;
            for (AgoraUserModel *model in self.dataArray) {
                if ([model isKindOfClass:[AgoraUserModel class]] && [[member lowercaseString] isEqualToString:[model.hyphenateId lowercaseString]]) {
                    index = [self.dataArray indexOfObject:model];
                    break;
                }
            }
            if (index <= self.dataArray.count - 1) {
                [self.dataArray removeObjectAtIndex:index];
                [self.tableView reloadData];
            }
            [self showHint:@"Remove successful!"];
        }
    }];
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
    if (self.cursor) {
        self.cursor.cursor = @"";
        [self.dataArray removeAllObjects];
        [self fetchMembersWithCursor:self.cursor.cursor isHeader:YES];
    } else {
        [self fetchMembersWithCursor:@"" isHeader:YES];
    }

}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithCursor:self.cursor.cursor isHeader:NO];
}


- (void)fetchMembersWithCursor:(NSString *)aCursor
                      isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 20;
    ACD_WS
    [[AgoraChatClient sharedClient].threadManager getChatThreadMemberListFromServerWithId:self.threadId cursor:aCursor pageSize:pageSize completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        self.cursor = aResult;
        self.loadMoreFinished = YES;
        if (!aError) {
            [self updateUIWithResultList:aResult.list IsHeader:aIsHeader];
        } else {
            [self showHint:@"Failed to get the group details, please try again later"];
        }
    }];
}


@end
