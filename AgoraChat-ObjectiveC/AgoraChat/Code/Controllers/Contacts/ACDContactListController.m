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
#import "ACDContactInfoViewController.h"

#import "AgoraChatroomsViewController.h"
#import "ACDContactCell.h"
#import "AgoraUserModel.h"
#import "AgoraApplyManager.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraRealtimeSearchUtils.h"
#import "NSArray+AgoraSortContacts.h"
#import "ACDContactCell.h"
#import "PresenceManager.h"


@interface ACDContactListController()
@property (nonatomic,strong) NSArray<NSString*>* contacts;
@end

@implementation ACDContactListController

#pragma mark life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingBlackListDidChange) name:@"AgoraSettingBlackListDidChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presencesUpdated:) name:PRESENCES_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactListDidChange) name:KACD_REFRESH_CONTACTS object:nil];
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
    self.contacts = bubbyList;
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
    [[PresenceManager sharedInstance] subscribe:contacts completion:nil];
    self.sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    self.searchSource = [NSMutableArray arrayWithArray:searchSource];
}

- (void)viewDidAppearForIndex:(NSUInteger)index{
    //[self reloadContacts];
}

#pragma mark NSNotification
- (void)contactListDidChange {
    [self reloadContacts];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearchState) {
        return 1;
    }
    return  self.sectionTitles.count;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
     return self.sectionTitles;
}


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
    AgoraChatPresence*presence = [[PresenceManager sharedInstance].presences objectForKey:model.hyphenateId];
    if(presence) {
        NSInteger status = [PresenceManager fetchStatus:presence];
        NSString* imageName = [[PresenceManager whiteStrokePresenceImages] objectForKey:[NSNumber numberWithInteger:status]];
        [cell.iconImageView setPresenceImage:[UIImage imageNamed:imageName]];
        NSString* showStatus = [[PresenceManager showStatus] objectForKey:[NSNumber numberWithInteger:status]];
        if(status == 0)
            showStatus = [PresenceManager formatOfflineStatus:presence.lastTime];
        if(status != PRESENCESTATUS_OFFLINE && presence.statusDescription.length > 0)
            cell.detailLabel.text = presence.statusDescription;
        else
            cell.detailLabel.text = showStatus;
    }
    
    cell.tapCellBlock = ^{
        if (self.selectedBlock) {
            self.selectedBlock(model.hyphenateId);
        }
    };
    
    return cell;
}

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

- (void)presencesUpdated:(NSNotification*)noti
{
    NSArray*array = noti.object;
    NSMutableSet *set1 = [NSMutableSet setWithArray:array];
    NSMutableSet *set2 = [NSMutableSet setWithArray:self.contacts];
    [set1 intersectSet:set2];
    if(set1.count > 0) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.table reloadData];
        });
        
    }
}

@end
