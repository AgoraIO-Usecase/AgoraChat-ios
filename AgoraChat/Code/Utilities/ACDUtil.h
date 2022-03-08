//
//  ACDUtil.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDUtil : NSObject
+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font;

+ (UIBarButtonItem *)customBarButtonItem:(NSString *)title
                                  action:(SEL)action
                            actionTarget:(id)actionTarget;

+ (UIBarButtonItem *)customLeftButtonItem:(NSString *)title
                                   action:(SEL)action
                             actionTarget:(id)actionTarget;

@end

NS_ASSUME_NONNULL_END
