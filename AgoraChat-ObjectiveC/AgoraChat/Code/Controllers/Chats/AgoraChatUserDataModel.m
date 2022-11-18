//
//  AgoraChatUserDataModel.m
//  EaseIM
//
//  Created by zhangchong on 2020/12/3.
//  Copyright © 2020 zhangchong. All rights reserved.
//

#import "AgoraChatUserDataModel.h"

@implementation AgoraChatUserDataModel

- (instancetype)initWithUserInfo:(AgoraChatUserInfo *)userInfo
{
    if (self = [super init]) {
        _easeId = userInfo.userId;
        _showName = userInfo.nickName;
        _avatarURL = userInfo.avatarUrl;
        _defaultAvatar = [self getAvatar:userInfo.userId];
    }
    return self;
}

- (UIImage *)getAvatar:(NSString *)uName
{
    if ([uName isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *imageName = [userDefault valueForKey:[NSString stringWithFormat:@"%@_avatar",AgoraChatClient.sharedClient.currentUsername]];
        return ImageWithName(imageName);
    } else {
        UIImage *originImage = nil;
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *imageName = [userDefault objectForKey:uName];
        if (imageName && imageName.length > 0) {
            originImage = ImageWithName(imageName);
        } else {
            int random = arc4random() % 7 + 1;
            NSString *imgName = [NSString stringWithFormat:@"defatult_avatar_%@",@(random)];
            [userDefault setObject:imgName forKey:uName];
            originImage = ImageWithName(imgName);
            [userDefault synchronize];
        }
        
        return [originImage acd_scaleToAssignSize:CGSizeMake(kAvatarHeight, kAvatarHeight)];
    }
    
    return ImageWithName(@"defaultAvatar");
}

@end
