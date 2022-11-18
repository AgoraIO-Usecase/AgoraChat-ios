//
//  ConfInviteUsersViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface ConfInviteUsersViewController : UIViewController

@property (copy) void (^didSelectedUserList)(NSArray *aInviteUsers);

- (instancetype)initWithGroupId:(NSString *)groupId
                   excludeUsers:(nullable NSArray *)excludeUserList;

@end

NS_ASSUME_NONNULL_END
