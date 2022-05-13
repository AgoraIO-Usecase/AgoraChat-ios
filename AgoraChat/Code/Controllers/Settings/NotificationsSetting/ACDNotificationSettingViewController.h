//
//  ACDNotificationSettingViewController.h
//  AgoraChat
//
//  Created by hxq on 2022/3/16.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AgoraNotificationSettingType) {
    AgoraNotificationSettingTypeSelf = 0,
    AgoraNotificationSettingTypeSingleChat,
    AgoraNotificationSettingTypeGroup,
    AgoraNotificationSettingTypeThread,
};

@interface ACDNotificationSettingViewController : ACDBaseTableViewController
@property (nonatomic , copy) NSString *conversationID;
@property (nonatomic , assign)AgoraNotificationSettingType  notificationType;
@end

NS_ASSUME_NONNULL_END
