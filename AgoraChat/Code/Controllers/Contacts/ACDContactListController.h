//
//  AgoraContactListController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACDContainerSearchTableViewController.h"
#import "AgoraBaseRefreshTableController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDContactListController : ACDContainerSearchTableViewController
@property (nonatomic,copy)void (^selectedBlock)(NSString *contactId);

- (void)reloadContacts;

@end

NS_ASSUME_NONNULL_END
