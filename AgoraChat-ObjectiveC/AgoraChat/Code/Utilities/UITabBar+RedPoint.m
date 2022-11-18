//
//  UITabBar+RedPoint.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/18.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "UITabBar+RedPoint.h"
#define TabbarItemNums 3.0

@implementation UITabBar (RedPoint)

- (void)showBadgeOnItemIndex:(int)index{
    [self removeBadgeOnItemIndex:index];
   
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5;
    badgeView.backgroundColor = TextLabelPinkColor;
    CGRect tabFrame = self.frame;
   
    float percentX = (index +0.6) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 10, 10);
    [self addSubview:badgeView];
}

- (void)hideBadgeOnItemIndex:(int)index{
    [self removeBadgeOnItemIndex:index];
}

- (void)removeBadgeOnItemIndex:(int)index{
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

@end

#undef TabbarItemNums

