//
//  AgoraChatSearchViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AgoraChatRefreshViewController.h"

#import "AgoraChatSearchBar.h"
#import "AgoraChatRealtimeSearch.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraChatSearchViewController : AgoraChatRefreshViewController<AgoraChatSearchBarDelegate>

@property (nonatomic) BOOL isSearching;

@property (nonatomic, strong) AgoraChatSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) UITableView *searchResultTableView;

- (void)keyBoardWillShow:(NSNotification *)note;

- (void)keyBoardWillHide:(NSNotification *)note;

@end

NS_ASSUME_NONNULL_END
