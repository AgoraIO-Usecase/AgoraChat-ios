//
//  ACDTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDTableViewController.h"

@interface ACDTableViewController ()<UISearchBarDelegate>

@end

@implementation ACDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepare {
    [super prepare];
}

- (void)placeSubViews {
    [self.table mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(40, 0, 0, 0));
    }];

}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}

@end


