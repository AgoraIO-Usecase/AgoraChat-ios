//
//  EMSecurityPrivacyViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/6/10.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "ACDPrivacyViewController.h"
#import "ACDBlockListViewController.h"
#import "ACDTitleDetailCell.h"

@interface ACDPrivacyViewController ()

@end

@implementation ACDPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"Privacy" action:@selector(back) actionTarget:self];

    [self _setupSubviews];
}

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];

    self.table.scrollEnabled = NO;
    self.table.rowHeight = 66;
    self.table.tableFooterView = [[UIView alloc] init];
    self.table.backgroundColor = [UIColor whiteColor];
    self.table.scrollEnabled = NO;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@70);
    }];

}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ACDTitleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[ACDTitleDetailCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    if (indexPath.row == 0) {
        cell.nameLabel.text = NSLocalizedString(@"Blocked List", nil);
        ACD_WS
        cell.tapCellBlock = ^{
            [weakSelf goBlockListPage];
        };
    }
    return cell;
}

- (void)goBlockListPage {
    ACDBlockListViewController *controller = [[ACDBlockListViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];

}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
    }
}

@end
