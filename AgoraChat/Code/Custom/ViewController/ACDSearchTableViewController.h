//
//  AgoraSearchTableViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDSearchTableViewController : ACDBaseTableViewController
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) NSMutableArray *searchSource;
@property (nonatomic, strong, readonly) NSMutableArray *searchResults;
@property (nonatomic, assign, readonly) BOOL isSearchState;
@property (nonatomic, strong) NSMutableArray *members;


@property (nonatomic, copy) void (^searchResultBlock)(void);
@property (nonatomic, copy) void (^searchCancelBlock)(void);

- (void)cancelSearchState;
- (void)loadAllDatas;
- (void)sortContacts:(NSArray *)contacts;

@end

NS_ASSUME_NONNULL_END
