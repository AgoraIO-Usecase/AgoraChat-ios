//
//  ACDGroupMemberNavView.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDGroupMemberNavView : ACDCustomBaseView
@property (nonatomic, strong) UILabel* leftLabel;
@property (nonatomic, strong) UILabel* leftSubLabel;
@property (nonatomic, strong) UIButton* rightButton;
@property (nonatomic, copy) void (^leftButtonBlock)(void);
@property (nonatomic, copy ) void (^rightButtonBlock)(void);

@end

NS_ASSUME_NONNULL_END
