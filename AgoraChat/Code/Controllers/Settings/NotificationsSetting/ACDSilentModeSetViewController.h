//
//  ACDSilentModeSetViewController.h
//  AgoraChat
//
//  Created by hxq on 2022/3/22.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDBaseTableViewController.h"
#import "ACDNotificationSettingViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDSilentModeSetViewController : ACDBaseTableViewController
@property (nonatomic , copy) NSString *conversationID;
@property (nonatomic , assign)AgoraNotificationSettingType  notificationType;
@property (nonatomic, copy) void(^doneBlock)(AgoraChatSilentModeResult *item);
@end

NS_ASSUME_NONNULL_END
