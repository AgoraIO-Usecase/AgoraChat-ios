//
//  ACDGroupMembersViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/28.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDGroupMembersViewController : UIViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup;
- (void)updateWithGroup:(AgoraChatGroup *)agoraGroup;

@end

NS_ASSUME_NONNULL_END
