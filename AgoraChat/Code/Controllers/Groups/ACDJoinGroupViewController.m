//
//  ACDJoinGroupViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/25.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDJoinGroupViewController.h"
#import "ACDSearchResultView.h"
#import "ACDSearchTableViewController.h"
#import "AgoraRealtimeSearchUtils.h"
#import "ACDSearchJoinCell.h"

#define kSearchBarHeight 40.0f

@interface ACDJoinGroupViewController ()
@property (nonatomic, strong) ACDSearchResultView *resultView;

@end

@implementation ACDJoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isSearchGroup) {
        self.title = @"Join a Group";
    }else {
        self.title = @"Add Contacts";
    }
    
    [self setNavBar];
    [self.table registerClass:[ACDSearchJoinCell class] forCellReuseIdentifier:[ACDSearchJoinCell reuseIdentifier]];
}

- (void)setNavBar {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ImageWithName(@"gray_goBack") style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTitleColor:TextLabelBlueColor forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)joinToPublicGroup:(NSString *)groupId {
    ACD_WS
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                         animated:YES];
    
    [[AgoraChatClient sharedClient].groupManager requestToJoinPublicGroup:groupId message:@"" completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        if (!aError) {

        }
        else {
            NSString *msg = aError.errorDescription;
            [self showHint:msg];
        }
    }];
}


- (void)sendAddContact:(NSString *)contactName {
    NSString *requestMessage = [NSString stringWithFormat:@"%@ add you as a friend",AgoraChatClient.sharedClient.currentUsername];
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[AgoraChatClient sharedClient].contactManager addContact:contactName
                                               message:requestMessage
                                            completion:^(NSString *aUsername, AgoraChatError *aError) {
        [MBProgressHUD hideHUDForView:weakSelf.navigationController.view animated:YES];
        if (!aError) {
            NSString *msg =  @"You request has been sent.";
            [weakSelf showAlertWithMessage:msg];
        }
        else {
            [weakSelf showAlertWithMessage:aError.errorDescription];
        }
    }];
}



#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.dataArray = [@[searchText] mutableCopy];
    self.searchSource = self.dataArray;
    self.table.userInteractionEnabled = YES;
    [self.table reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    self.searchSource = [@[] mutableCopy];
    self.table.scrollEnabled = NO;
    [self.table reloadData];
}



#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ACDSearchJoinCell *cell = [tableView dequeueReusableCellWithIdentifier:[ACDSearchJoinCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDSearchJoinCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDSearchJoinCell reuseIdentifier]];
    }
    cell.isSearchGroup = self.isSearchGroup;
    
    NSString *title = @"";
    if (self.isSearchGroup) {
        title = [NSString stringWithFormat:@"GroupID：%@",self.searchSource[0]];
    }else {
        title = [NSString stringWithFormat:@"AgoraID：%@",self.searchSource[0]];
    }

    ACD_WS
    cell.addGroupBlock = ^{
        if (weakSelf.isSearchGroup) {
            [weakSelf joinToPublicGroup:weakSelf.searchSource[0]];

        }else {
            [weakSelf sendAddContact:weakSelf.searchSource[0]];
        }

    };

    [cell updateSearchName:title];
    return cell;
    
}


#pragma mark getter and setter
- (ACDSearchResultView *)resultView {
    if (_resultView == nil) {
        _resultView = [[ACDSearchResultView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30.0)];
    }
    
    return _resultView;
}


@end

#undef kSearchBarHeight
