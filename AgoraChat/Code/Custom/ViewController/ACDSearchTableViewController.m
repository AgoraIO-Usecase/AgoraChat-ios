//
//  AgoraSearchTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSearchTableViewController.h"
#import "AgoraRealtimeSearchUtils.h"

#define kSearchBarHeight 32.0

@interface ACDSearchTableViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL isSearchState;

@end

@implementation ACDSearchTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepare {
    [super prepare];
    [self.view addSubview:self.searchBar];
}

- (void)placeSubViews {
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(kSearchBarHeight);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(self.searchBar.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-5.0);

    }];

}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

    _isSearchState = YES;
    if ([searchBar.text isEqualToString:@""]) {
        self.table.userInteractionEnabled = NO;
        [self.searchResults removeAllObjects];
        [self.table reloadData];
    }else {
        self.table.userInteractionEnabled = YES;
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    self.table.userInteractionEnabled = YES;
    [self.searchBar resignFirstResponder];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.table.userInteractionEnabled = YES;
    
    [_searchResults removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.table reloadData];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_searchSource searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _searchResults = [NSMutableArray arrayWithArray:results];
                if (weakSelf.searchResultBlock) {
                    weakSelf.searchResultBlock();
                }
                
                [weakSelf.table reloadData];
            });
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    _isSearchState = NO;
    if (self.searchCancelBlock) {
        self.searchCancelBlock();
    }
    [self.searchResults removeAllObjects];
    self.table.scrollEnabled = !_isSearchState;
    [self.table reloadData];
}

#pragma mark public method
- (void)cancelSearchState {
    self.searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:NO];
    [self.searchBar resignFirstResponder];
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    _isSearchState = NO;
    if (self.searchCancelBlock) {
        self.searchCancelBlock();
    }
    [self.searchResults removeAllObjects];
    self.table.scrollEnabled = !_isSearchState;
    [self.table reloadData];
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

#pragma mark getter and setter
- (UISearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kSearchBarHeight)];
        _searchBar.placeholder = @"Search";
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.bounds.size];
        [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
                
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
          if (searchField) {
                  if (@available(iOS 13.0, *)){
                      _searchBar.searchTextField.backgroundColor= COLOR_HEX(0xF2F2F2);
                  }else{
                      searchField.backgroundColor = COLOR_HEX(0xF2F2F2);
                  }

              searchField.layer.cornerRadius = kSearchBarHeight * 0.5;
              searchField.layer.masksToBounds = YES;
          }
    }
    return _searchBar;
}


- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}


- (NSMutableArray *)searchResults {
    if (_searchResults == nil) {
        _searchResults = NSMutableArray.new;
    }
    return _searchResults;
}

- (NSMutableArray *)members {
    if (_members == nil) {
        _members = NSMutableArray.new;
    }
    return _members;
}


@end
#undef kSearchBarHeight

