//
//  AgoraChatAvatarNameModel.m
//  EaseIM
//
//  Created by zhangchong on 2020/8/19.
//  Copyright © 2020 zhangchong. All rights reserved.
//

#import "AgoraChatAvatarNameModel.h"

@implementation AgoraChatAvatarNameModel

- (instancetype)initWithInfo:(NSString *)keyWord img:(UIImage *)img msg:(AgoraChatMessage *)msg time:(NSString *)timestamp
{
    self = [super init];
    if (self) {
        _avatarImg = [UIImage imageWithColor:AvatarLightGreenColor size:CGSizeMake(40.0, 40.0)];
        _from = msg.from;
        _msg = msg;
        NSString *text = ((AgoraChatTextMessageBody *)msg.body).text;
        NSRange range = [text rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:text];
        if(range.length > 0) {
            [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0]} range:NSMakeRange(range.location, keyWord.length)];
        }
        _detail = attributedStr;
        _timestamp = timestamp;
    }
    return self;
}

@end
