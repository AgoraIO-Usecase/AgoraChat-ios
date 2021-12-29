//
//  AgoraContactInfoNewViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACDBaseTableViewController.h"

@class AgoraUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface ACDContactInfoViewController : ACDBaseTableViewController
@property (nonatomic,copy) void (^addBlackListBlock)(void);
@property (nonatomic,copy) void (^deleteContactBlock)(void);
@property (nonatomic,assign) BOOL isHideChatButton;

- (instancetype)initWithUserModel:(AgoraUserModel *)model;

@end

NS_ASSUME_NONNULL_END
