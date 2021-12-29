//
//  SelectUserViewController.m
//  EaseIM
//
//  Created by lixiaoming on 2021/3/18.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "SelectUserViewController.h"
#import "AgoraChatAvatarNameCell.h"
#import "AgoraChatRealtimeSearch.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewController+Util.h"

@interface SelectUserViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchDataArray;
@end

@implementation SelectUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
}

- (void)setupSubViews
{
    [self addPopBackLeftItem];
    self.title = @"选择联系人";
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    CGFloat color = 245 / 255.0;
    searchField.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
    self.searchBar.placeholder = @"Search contacts";
    [self.view addSubview:self.searchBar];
    [self.view sendSubviewToBack:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
    self.tableView.scrollEnabled = YES;
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    self.dataArray = [[[[AgoraChatClient sharedClient] contactManager] getContacts] mutableCopy];
}

- (NSMutableArray*)searchDataArray
{
    if(!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString* searchText = self.searchBar.text;
    NSLog(@"search:%@",self.searchBar.text);
    return searchText.length > 0 ? [self.searchDataArray count] : [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"AgoraChatAvatarNameCell";
    AgoraChatAvatarNameCell *cell = (AgoraChatAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AgoraChatAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    NSString *contact = self.dataArray[row];
    cell.avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
    cell.nameLabel.text = contact;
    AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:contact];
    if(userInfo) {
        if(userInfo.avatarUrl.length > 0) {
            NSURL* url = [NSURL URLWithString:userInfo.avatarUrl];
            [cell.avatarView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            
            }];
        }
        if(userInfo.nickName.length > 0)
        {
            cell.nameLabel.text = userInfo.nickName;
            cell.detailLabel.text = contact;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AgoraChatAvatarNameCell *cell = (AgoraChatAvatarNameCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString* remoteUser = cell.detailLabel.text;
    if(remoteUser.length == 0)
        remoteUser = cell.nameLabel.text;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    [[AgoraChatRealtimeSearch shared] realtimeSearchWithSource:self.dataArray searchText:searchBar.text collationStringSelector:nil resultBlock:^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.searchDataArray removeAllObjects];
            [weakSelf.searchDataArray addObjectsFromArray:results];
            [weakSelf.tableView reloadData];
        });
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
    [searchBar setShowsCancelButton:NO];
    [searchBar resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
