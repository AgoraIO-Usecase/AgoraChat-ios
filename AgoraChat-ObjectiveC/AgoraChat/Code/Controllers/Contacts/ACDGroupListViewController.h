//
//  AgoraGroupListViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContainerSearchTableViewController.h"
#import "ACDTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDGroupListViewController : ACDContainerSearchTableViewController
@property (nonatomic,copy)void (^selectedBlock)(NSString *groupId);

@property (nonatomic, assign) BOOL forward;

@end

NS_ASSUME_NONNULL_END
