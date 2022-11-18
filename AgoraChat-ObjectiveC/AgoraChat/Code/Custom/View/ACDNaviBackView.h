//
//  ACDNaviBackView.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/12.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDNaviBackView : ACDCustomBaseView
@property (nonatomic, strong) UILabel* leftLabel;

@property (nonatomic, copy) void (^leftButtonBlock)(void);


@end

NS_ASSUME_NONNULL_END
