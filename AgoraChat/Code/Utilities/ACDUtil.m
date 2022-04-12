//
//  ACDUtil.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDUtil.h"

@implementation ACDUtil

+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font {
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:content attributes:
        @{NSForegroundColorAttributeName:color,
          NSFontAttributeName:font
        }];
    return attrString;
}

+ (UIBarButtonItem *)customBarButtonItem:(NSString *)title
                                  action:(SEL)action
                            actionTarget:(id)actionTarget {
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 50, 40);
    customButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [customButton setTitleColor:ButtonEnableBlueColor forState:UIControlStateNormal];
    [customButton setTitle:title forState:UIControlStateNormal];
    [customButton setTitle:title forState:UIControlStateHighlighted];
    [customButton addTarget:actionTarget action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customNavItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];

    return customNavItem;
}

+ (UIBarButtonItem *)customLeftButtonItem:(NSString *)title
                                   action:(SEL)action
                             actionTarget:(id)actionTarget {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"black_goBack"] forState:UIControlStateNormal];
    [backButton addTarget:actionTarget action:action forControlEvents:UIControlEventTouchUpInside];

    [backButton setTitle:title forState:UIControlStateNormal];
    [backButton setTitleColor:TextLabelBlackColor forState:UIControlStateNormal];
    UIBarButtonItem *customNavItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    return customNavItem;

    
}


@end
