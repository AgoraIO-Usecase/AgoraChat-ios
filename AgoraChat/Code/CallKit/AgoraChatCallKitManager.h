//
//  AgoraChatCallKitManager.h
//  AgoraChat
//
//  Created by 冯钊 on 2022/4/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraChatCallKitManager : NSObject

+ (instancetype)shareManager;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

- (void)audioCallToUser:(NSString *)userId;
- (void)videoCallToUser:(NSString *)userId;
- (void)audioCallToGroup:(NSString *)groupId viewController:(UIViewController *)viewController;
- (void)videoCallToGroup:(NSString *)groupId viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
