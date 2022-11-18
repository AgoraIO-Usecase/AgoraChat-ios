//
//  ACDNormalNavigationView.h
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/7.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDCustomBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDNormalNavigationView : ACDCustomBaseView

@property (nonatomic, strong) UIButton* leftButton;
@property (nonatomic, strong) UILabel* leftLabel;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, copy) void (^leftButtonBlock)(void);
@property (nonatomic, copy) void (^rightButtonBlock)(void);

@end

NS_ASSUME_NONNULL_END
