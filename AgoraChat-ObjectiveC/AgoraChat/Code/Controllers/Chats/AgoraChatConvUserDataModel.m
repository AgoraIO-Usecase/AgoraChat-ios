//
//  AgiraChatConvUserDataModel.m
//  EaseIM
//
//  Created by zhangchong on 2020/12/6.
//  Copyright © 2020 zhangchong. All rights reserved.
//

#import "AgoraChatConvUserDataModel.h"

@implementation AgoraChatConvUserDataModel

- (instancetype)initWithUserInfo:(AgoraChatUserInfo *)userInfo conversationType:(AgoraChatConversationType)type
{
    if (self = [super init]) {
        _easeId = userInfo.userId;
        _showName = userInfo.nickname;
        _avatarURL = userInfo.avatarUrl;
        _defaultAvatar = nil;
        
        if(type == AgoraChatConversationTypeGroupChat) {
            AgoraChatGroup* group = [AgoraChatGroup groupWithId:userInfo.userId];
            _showName = [group groupName];
            
            _defaultAvatar = ImageWithName(@"group_default_avatar");
        }
        
        if (type == AgoraChatConversationTypeChat) {
            UIImage *originImage = nil;
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSString *imageName = [userDefault objectForKey:userInfo.userId];
            if (imageName && imageName.length > 0) {
                originImage = ImageWithName(imageName);
            } else {
                int random = arc4random() % 7 + 1;
                NSString *imgName = [NSString stringWithFormat:@"defatult_avatar_%@",@(random)];
                [userDefault setObject:imgName forKey:userInfo.userId];
                originImage = ImageWithName(imgName);
                [userDefault synchronize];
            }
            
            _defaultAvatar = [originImage acd_scaleToAssignSize:CGSizeMake(kAvatarHeight, kAvatarHeight)];
        }
    }
    return self;
}

- (UIImage*)_getDefaultAvatarImage:(NSString*)easeId conversationType:(AgoraChatConversationType)type
{
    if (type == AgoraChatConversationTypeChat) {
        return [UIImage imageNamed:@"defaultAvatar"];
    }
    if (type == AgoraChatConversationTypeGroupChat) {
        return [UIImage imageNamed:@"groupConversation"];
    }
    if (type == AgoraChatConversationTypeChatRoom) {
        return [UIImage imageNamed:@"chatroomConversation"];
    }
    return [UIImage imageNamed:@"defaultAvatar"];
}

@end
