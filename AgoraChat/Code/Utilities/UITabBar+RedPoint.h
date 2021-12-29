//
//  UITabBar+RedPoint.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/18.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (RedPoint)
- (void)showBadgeOnItemIndex:(int)index;   //显示小红点
- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end

NS_ASSUME_NONNULL_END
