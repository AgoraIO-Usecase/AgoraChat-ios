//
//  AgoraChatNewContactsViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDContactsViewController : UIViewController

- (void)loadContactsFromServer;

- (void)reloadContacts;

- (void)reloadContactRequests;

- (void)reloadGroupNotifications;

- (void)navBarUnreadRequestIsShow:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
