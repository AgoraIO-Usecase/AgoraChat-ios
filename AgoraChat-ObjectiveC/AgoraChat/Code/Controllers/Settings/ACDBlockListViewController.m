//
//  AgoraBlackListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDBlockListViewController.h"
#import "AgoraBlackListCell.h"
#import "AgoraUserModel.h"
#import "AgoraRealtimeSearchUtils.h"
#import "NSArray+AgoraSortContacts.h"
#import "ACDContactCell.h"

static NSString *cellIndentifier = @"AgoraBlackListCellIndentifier";

@interface ACDBlockListViewController ()

@end

@implementation ACDBlockListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"Blocked List" action:@selector(back) actionTarget:self];
    
    [self useRefresh];
    [self tableDidTriggerHeaderRefresh];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
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
    [[AgoraChatClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, AgoraChatError *aError) {
        if (aError == nil) {
            [weakSelf updateContacts:aList];
            [weakSelf.table reloadData];
        }
        else {

        }
        [weakSelf endRefresh];
    }];
}

- (void)loadBlockContactsFromServer
{
    [self tableDidTriggerHeaderRefresh];
}

- (void)reloadBlockContacts {
    NSArray *bubbyList = [[AgoraChatClient sharedClient].contactManager getBlackList];
    [self updateContacts:bubbyList];
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^(){
        [weakSelf.table reloadData];
    });
}


- (void)updateContacts:(NSArray *)bubbyList {
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:bubbyList];
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
    [self reloadBlockContacts];
}

- (void)tapActionWithUserId:(NSString *)userId {
   
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:userId message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *unBlockAction = [UIAlertAction alertActionWithTitle:@"Unblock" iconImage:ImageWithName(@"blocked") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self unBlockActionWithUserId:userId];
    }];
    [alertController addAction:unBlockAction];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)unBlockActionWithUserId:(NSString *)userId {
    [[AgoraChatClient sharedClient].contactManager removeUserFromBlackList:userId completion:^(NSString *aUsername, AgoraChatError *aError) {
        if (aError == nil) {
            [self tableDidTriggerHeaderRefresh];
            [[NSNotificationCenter defaultCenter] postNotificationName:KACD_REFRESH_CONTACTS object:nil];
        }else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.unblockFailure", @"Unblock failure")];
        }
    }];
}


- (void)deleteActionWithUserId:(NSString *)userId  {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete this contact now?" message:@"Delete this contact and associated Chats." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteContactWithUserId:userId];
    }];
    [deleteAction setValue:TextLabelPinkColor forKey:@"titleTextColor"];

    [alertController addAction:deleteAction];
    
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)deleteContactWithUserId:(NSString *)userId {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AgoraChatClient sharedClient].contactManager deleteContact:userId isDeleteConversation:YES completion:^(NSString *aUsername, AgoraChatError *aError) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!aError) {
            [self tableDidTriggerHeaderRefresh];
            [[NSNotificationCenter defaultCenter] postNotificationName:KACD_REFRESH_CONTACTS object:nil];
        }
        else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.deleteFailure", @"Delete contacts failed")];
        }
    }];
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
    
    cell.tapCellBlock = ^{
//        if (self.selectedBlock) {
//            self.selectedBlock(model.hyphenateId);
//        }
        [self tapActionWithUserId:model.hyphenateId];
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ACDContactCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell && cell.tapCellBlock) {
        cell.tapCellBlock();
    }
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

@end

