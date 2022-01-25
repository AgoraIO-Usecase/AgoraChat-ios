/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraUserModel.h"

@interface AgoraUserModel ()
@property(nonatomic, strong)AgoraChatUserInfo *userInfo;

@end

@implementation AgoraUserModel

- (instancetype)initWithHyphenateId:(NSString *)hyphenateId {
    self = [super init];
    if (self) {
        _hyphenateId = hyphenateId;
        _nickname = @"";

        _defaultAvatarImage = [UIImage imageWithColor:[self generateRandomColor] size:CGSizeMake(40.0, 40.0)];
        
        [self fetchUserInfoData];
    }
    return self;
}

- (void)fetchUserInfoData {
    if (_hyphenateId == nil) {
        return;
    }
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [AgoraChatUserInfoManagerHelper fetchUserInfoWithUserIds:@[_hyphenateId] completion:^(NSDictionary * _Nonnull userInfoDic) {
        if (userInfoDic) {
            self.userInfo = userInfoDic[_hyphenateId];
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    self.nickname = self.userInfo.nickName ? : _hyphenateId;
    self.avatarURLPath = self.userInfo.avatarUrl ? : @"";
    
}


- (NSString *)searchKey {
    if (_nickname.length > 0) {
        return _nickname;
    }
    return _hyphenateId;
}

- (UIColor *)generateRandomColor {
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
