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

        //_defaultAvatarImage = [UIImage imageWithColor:[self generateRandomColor] size:CGSizeMake(40.0, 40.0)];
        _defaultAvatarImage = [self defaultImage];
        
        [self fetchUserInfoData];
    }
    return self;
}

- (instancetype)initWithHyphenateId:(NSString *)hyphenateId nickname:(NSString*)nickname
{
    self = [super init];
    if (self) {
        _hyphenateId = hyphenateId;
        _nickname = nickname;

        //_defaultAvatarImage = [UIImage imageWithColor:[self generateRandomColor] size:CGSizeMake(40.0, 40.0)];
        _defaultAvatarImage = [self defaultImage];
    }
    return self;
}

- (UIImage *)defaultImage {
    UIImage *originImage = nil;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *imageName = [userDefault objectForKey:_hyphenateId];
    if (imageName && imageName.length > 0) {
        originImage = ImageWithName(imageName);
    } else {
        int random = arc4random() % 7 + 1;
        NSString *imgName = [NSString stringWithFormat:@"defatult_avatar_%@",@(random)];
        [userDefault setObject:imgName forKey:_hyphenateId];
        originImage = ImageWithName(imgName);
        [userDefault synchronize];
    }
    
    return [originImage acd_scaleToAssignSize:CGSizeMake(kAvatarHeight, kAvatarHeight)];
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
    self.nickname = self.userInfo.nickname ? : _hyphenateId;
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
