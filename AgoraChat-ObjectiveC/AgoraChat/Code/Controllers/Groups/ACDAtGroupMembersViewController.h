//
//  ACDAtGroupMembersViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/19.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "ACDContainerSearchTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDAtGroupMembersViewController : ACDContainerSearchTableViewController

@property (nonatomic, copy) void (^selectedCompletion)(NSString *aUserId,NSString* showName);

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup;

- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
