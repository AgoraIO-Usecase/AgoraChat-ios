//
//  AgoraThreadNotificationsViewController.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/3/20.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraThreadNotificationsViewController.h"
#import "AgoraThreadMuteViewController.h"

@interface AgoraThreadNotificationsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation AgoraThreadNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.datas = @[@{@"title":@"Mute this Thread",@"detail":@"Mute"},@{@"title":@"Frequency",@"detail":@"All Messages"}];
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, EMNavgationHeight, EMScreenWidth, EMScreenHeight-EMNavgationHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AgoraThreadNotificationsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AgoraThreadNotificationsCell"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    cell.textLabel.text = [self.datas[indexPath.row] valueForKey:@"title"];
    cell.detailTextLabel.text = [self.datas[indexPath.row] valueForKey:@"detail"];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        AgoraThreadMuteViewController *VC = [AgoraThreadMuteViewController new];
        [self.navigationController pushViewController:VC animated:YES];
    } else {
        [self showActionSheet];
    }
}

- (void)showActionSheet {
    UIButton *button; // the button you want to show the popup sheet from

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Default"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *action) {
                                               // do destructive stuff here
                                           }];
    UIAlertAction *allMessagesAction = [UIAlertAction actionWithTitle:@"All Messages"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             // do something here
                                         }];
    UIAlertAction *onlyRemindMetions = [UIAlertAction actionWithTitle:@"Only @Mentions"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             // do something here
                                         }];
    UIAlertAction *nothing = [UIAlertAction actionWithTitle:@"Nothing"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             // do something here
                                         }];
    [alertController addAction:defaultAction];
    [alertController addAction:allMessagesAction];
    [alertController addAction:onlyRemindMetions];
    [alertController addAction:nothing];
    [alertController setModalPresentationStyle:UIModalPresentationPopover];

    UIPopoverPresentationController *popPresenter = [alertController
                                                  popoverPresentationController];
    popPresenter.sourceView = button;
    popPresenter.sourceRect = button.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
