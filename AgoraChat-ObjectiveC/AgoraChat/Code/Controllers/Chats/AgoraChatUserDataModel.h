//
//  AgoraChatUserDataModel.h
//  EaseIM
//
//  Created by zhangchong on 2020/12/3.
//  Copyright © 2020 zhangchong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraChatUserDataModel : NSObject <EaseUserProfile>
@property (nonatomic, copy) NSString *easeId;           // 环信id
@property (nonatomic, copy, readonly) UIImage *defaultAvatar;     // 默认头像显示
@property (nonatomic, copy) NSString *showName;         // 显示昵称
@property (nonatomic, copy) NSString *avatarURL;        // 显示头像的url

- (instancetype)initWithUserInfo:(AgoraChatUserInfo *)userInfo;
- (instancetype)initWithUserId:(NSString*)userId showName:(NSString *)showName;
@end

NS_ASSUME_NONNULL_END
