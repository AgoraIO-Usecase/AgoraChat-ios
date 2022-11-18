//
//  ACDTableViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDTableViewController : ACDBaseTableViewController
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;

@end

NS_ASSUME_NONNULL_END
