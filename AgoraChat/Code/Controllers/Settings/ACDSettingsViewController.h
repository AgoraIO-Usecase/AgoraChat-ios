//
//  ACDSettingsViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDSettingsViewController : UIViewController
- (void)reloadNotificationStatus;
- (void)networkChanged:(AgoraChatConnectionState)connectionState;

@end

NS_ASSUME_NONNULL_END
