//
//  AgoraChatConvUserDataModel.h
//  EaseIM
//
//  Created by zhangchong on 2020/12/6.
//  Copyright © 2020 zhangchong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraChatConvUserDataModel : NSObject <EaseUserProfile>

@property (nonatomic, copy, readonly) NSString *easeId;           // 环信id
@property (nonatomic, copy, readonly) UIImage *defaultAvatar;     // 默认头像显示
@property (nonatomic, copy) NSString *showName;         // 显示昵称
@property (nonatomic, copy) NSString *avatarURL;        // 显示头像的url

- (instancetype)initWithUserInfo:(AgoraChatUserInfo *)userInfo conversationType:(AgoraChatConversationType)type;

@end

NS_ASSUME_NONNULL_END
