//
//  ACDAppStyle.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDAppStyle.h"

@implementation ACDAppStyle
+ (instancetype)shareAppStyle {
    static ACDAppStyle *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = ACDAppStyle.new;
    });
    
    return instance;
}


- (void)defaultStyle {
    //hidden navigation bottom line
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    [UITabBarItem.appearance setTitleTextAttributes:@{
                                                      NSFontAttributeName : NFont(12.0f),
                                                      NSForegroundColorAttributeName : TextLabelBlackColor
                                                      } forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:@{
                                                      NSFontAttributeName : NFont(12.0f),
                                                      NSForegroundColorAttributeName : COLOR_HEX(0x114EFF)
                                                      } forState:UIControlStateSelected];

    UITabBar.appearance.shadowImage = [[UIImage alloc] init];
    UITabBar.appearance.backgroundColor = UIColor.whiteColor;

    UITabBarItem.appearance.badgeColor = TextLabelPinkColor;

}

- (void)matchNavigation {
    //make navigation not
    if(@available(iOS 15.0, *)) {
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor= [UIColor whiteColor];
    appearance.shadowColor= [UIColor clearColor];
    UINavigationBar.appearance.standardAppearance = appearance;
    UINavigationBar.appearance.scrollEdgeAppearance = appearance;
    }

}


@end
