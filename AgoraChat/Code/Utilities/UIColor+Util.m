//
//  UIColor+Util.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/17.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "UIColor+Util.h"

@implementation UIColor (Util)
+ (UIColor *)colorWithHexString:(NSString *)color {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *)avatarRandomColor {
        int randomIndex = arc4random() % 5 + 1;
        UIColor *avatarColor = nil;
        switch (randomIndex) {
            case 1:
                avatarColor = AvatarLightBlueColor;
                break;
            case 2:
                avatarColor = AvatarLightYellowColor;
                break;
            case 3:
                avatarColor = AvatarLightGreenColor;
                break;
            case 4:
                avatarColor = AvatarLightGrayColor;
                break;
            case 5:
                avatarColor = AvatarLightOrangeColor;
                break;

            default:
                avatarColor = AvatarLightBlueColor;
                break;
        }
    return avatarColor;
}


@end
