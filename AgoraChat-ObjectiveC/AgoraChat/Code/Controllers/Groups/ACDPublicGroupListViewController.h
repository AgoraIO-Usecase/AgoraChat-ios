//
//  ACDPublicGroupListViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContainerSearchTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDPublicGroupListViewController : ACDContainerSearchTableViewController

@property (nonatomic,copy)void (^selectedBlock)(NSString *groupId);

@end

NS_ASSUME_NONNULL_END
