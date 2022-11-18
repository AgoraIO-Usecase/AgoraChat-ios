//
//  NSObject+Hint.m
//  AgoraChat
//
//  Created by liu001 on 2022/1/23.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "NSObject+Hint.h"

@implementation NSObject (Hint)
- (void)showHint:(NSString *)hint
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.f;
    hud.yOffset = 180;
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabelText = hint; //多行显示
    hud.detailsLabelFont = [UIFont systemFontOfSize:14]; //多行显示时设置文字大小
    [hud hide:YES afterDelay:2];
}
@end
