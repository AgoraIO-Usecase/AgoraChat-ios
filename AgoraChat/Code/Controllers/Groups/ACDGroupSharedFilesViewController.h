//
//  AgoraChatGroupSharedFilesViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "ACDBaseTableViewController.h"
#import "ACDContainerSearchTableViewController.h"

@interface ACDGroupSharedFilesViewController : ACDContainerSearchTableViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup;

@end
