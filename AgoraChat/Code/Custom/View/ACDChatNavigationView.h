//
//  ACDChatNavigationView.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDChatNavigationView : ACDCustomBaseView
@property (nonatomic, strong) UILabel* leftLabel;
@property (nonatomic, strong) UIButton* chatButton;
@property (nonatomic, strong, readonly) UIButton* rightButton;
@property (nonatomic, strong) UIImageView *chatImageView;

@property (nonatomic, copy) void (^leftButtonBlock)(void);
@property (nonatomic, copy) void (^rightButtonBlock)(void);
@property (nonatomic, copy) void (^chatButtonBlock)(void);


@end

NS_ASSUME_NONNULL_END
