//
//  AgoraContactListController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContactListController.h"
#import "MISScrollPage.h"
#import "AgoraContactListSectionHeader.h"
#import "AgoraAddContactViewController.h"
#import "ACDContactInfoViewController.h"

#import "AgoraChatroomsViewController.h"
#import "AgoraGroupTitleCell.h"
#import "ACDContactCell.h"
#import "AgoraUserModel.h"
#import "AgoraApplyManager.h"
#import "AgoraApplyRequestCell.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraRealtimeSearchUtils.h"
#import "NSArray+AgoraSortContacts.h"
#import "ACDContactCell.h"


@interface ACDContactListController()

@end

@implementation ACDContactListController

#pragma mark life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingBlackListDidChange) name:@"AgoraSettingBlackListDidChange" object:nil];
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self useRefresh];
    
    [self tableDidTriggerHeaderRefresh];
}


#pragma mark refresh and load more
- (void)didStartRefresh {
    [self tableDidTriggerHeaderRefresh];
}

- (void)tableDidTriggerHeaderRefresh {
    if (self.isSearchState) {
        [self endRefresh];
        return;
    }
    
    ACD_WS
    [[AgoraChatClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, AgoraChatError *aError) {
        if (aError == nil) {
            [weakSelf updateContacts:aList];
            [weakSelf.table reloadData];
        }
        else {
//            [weakSelf tableViewDidFinishTriggerHeader:YES];
        }
        [weakSelf endRefresh];
    }];
}

- (void)loadContactsFromServer
{
    [self tableDidTriggerHeaderRefresh];
}

- (void)reloadContacts {
    NSArray *bubbyList = [[AgoraChatClient sharedClient].contactManager getContacts];
    [self updateContacts:bubbyList];
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^(){
        [weakSelf.table reloadData];
    });
}


- (void)updateContacts:(NSArray *)bubbyList {
    NSArray *blockList = [[AgoraChatClient sharedClient].contactManager getBlackList];
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:bubbyList];
    for (NSString *blockId in blockList) {
        [contacts removeObject:blockId];
    }
    [self sortContacts:contacts];
    
}

- (void)sortContacts:(NSArray *)contacts {
    if (contacts.count == 0) {
        self.dataArray = [@[] mutableCopy];
        self.sectionTitles = [@[] mutableCopy];
        self.searchSource = [@[] mutableCopy];
        return;
    }
    
    NSMutableArray *sectionTitles = nil;
    NSMutableArray *searchSource = nil;
    NSArray *sortArray = [NSArray sortContacts:contacts
                                 sectionTitles:&sectionTitles
                                  searchSource:&searchSource];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:sortArray];
    self.sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    self.searchSource = [NSMutableArray arrayWithArray:searchSource];
}

- (void)viewDidAppearForIndex:(NSUInteger)index{
    [self reloadContacts];
}

#pragma mark NSNotification
- (void)settingBlackListDidChange {
    [self reloadContacts];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearchState) {
        return 1;
    }
    return  self.sectionTitles.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [self.sectionTitles objectAtIndex:section];
//}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
     return self.sectionTitles;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *contentView = UIView.new;
//    contentView.backgroundColor = UIColor.whiteColor;
//    UILabel *label = UILabel.new;
//    label.font = Font(@"PingFangSC-Regular", 15.0f);
//    label.textColor = COLOR_HEX(0x242424);
//    label.text = self.sectionTitles[section];
//    [contentView addSubview:label];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(contentView).insets(UIEdgeInsetsMake(0, 20.0f, 0, -20.0));
//    }];
//    return contentView;
//}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isSearchState) {
        return self.searchResults.count;
    }
    return ((NSArray *)self.dataArray[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ACDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[ACDContactCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDContactCell reuseIdentifier]];
    }
    AgoraUserModel *model = nil;

    if (self.isSearchState) {
        model = self.searchResults[indexPath.row];
        cell.model = model;
    }else {
        model = self.dataArray[indexPath.section][indexPath.row];
        cell.model = model;
    }
    
    cell.tapCellBlock = ^{
        if (self.selectedBlock) {
            self.selectedBlock(model.hyphenateId);
        }
    };
    
    return cell;
}

//#pragma mark - Table view delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    AgoraUserModel *model = nil;
//    if (self.isSearchState) {
//        model = self.searchResults[indexPath.row];
//    }else {
//        model = self.dataArray[indexPath.section][indexPath.row];
//    }
//
//    if (self.selectedBlock) {
//        self.selectedBlock(model.hyphenateId);
//    }
//}

#pragma mark getter and setter
- (UITableView *)table {
    if (_table == nil) {
        _table  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.clipsToBounds = YES;
        _table.rowHeight = 54.0f;
        [_table registerClass:[ACDContactCell class] forCellReuseIdentifier:[ACDContactCell reuseIdentifier]];
        _table.sectionIndexColor = SectionIndexTextColor;
        _table.sectionIndexBackgroundColor = [UIColor clearColor];
        _table.allowsMultipleSelection = NO;

    }
    return _table;
}

@end
