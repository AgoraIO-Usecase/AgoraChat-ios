//
//  ACDGroupMemberAllViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSearchTableViewController.h"
#import "ACDContainerSearchTableViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class AgoraUserModel;

@interface ACDGroupMemberAllViewController : ACDContainerSearchTableViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup;

- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
