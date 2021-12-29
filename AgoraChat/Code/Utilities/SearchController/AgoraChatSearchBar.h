//
//  AgoraChatSearchBar.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraChatSearchBarDelegate;
@interface AgoraChatSearchBar : UIView

@property (nonatomic, weak) id<AgoraChatSearchBarDelegate> delegate;

@property (nonatomic, strong) UITextField *textField;

@end

@protocol AgoraChatSearchBarDelegate <NSObject>

@optional

- (void)searchBarShouldBeginEditing:(AgoraChatSearchBar *)searchBar;

- (void)searchBarCancelButtonAction:(AgoraChatSearchBar *)searchBar;

- (void)searchBarSearchButtonClicked:(NSString *)aString;

- (void)searchTextDidChangeWithString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
