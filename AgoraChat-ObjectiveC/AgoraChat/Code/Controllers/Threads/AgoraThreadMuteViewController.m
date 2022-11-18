//
//  AgoraThreadMuteViewController.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/3/20.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraThreadMuteViewController.h"
#import "AgoraThreadMute.h"
@interface AgoraThreadMuteViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation AgoraThreadMuteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.datas = [NSMutableArray array];
    NSArray *mutes = @[@{@"For 15 Minutes":@(YES)},@{@"For 1 Hour":@(NO)},@{@"For 8 Hours":@(NO)},@{@"For 24 Hours":@(NO)},@{@"Until 8:00 AM Tomorow":@(NO)},@{@"Until I turn it Unmute":@(NO)}];
    for (int i= 0; i < mutes.count; i++) {
        NSDictionary *dic = mutes[i];
        AgoraThreadMute *mute = [AgoraThreadMute new];
        mute.title = dic.allKeys.firstObject;
        mute.selected = [dic.allValues.firstObject boolValue];
        [self.datas addObject:mute];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AgoraThreadMute"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AgoraThreadMute"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    AgoraThreadMute *mute = self.datas[indexPath.row];
    cell.textLabel.text = mute.title;
    UIImageView *view = [self stateView];
    NSString *imgName = @"thread_mute_unselect";
    if (mute.selected == YES) {
        imgName = @"thread_mute_select";
    }
    view.image = [UIImage imageNamed:imgName];
    if (!cell.accessoryView) {
        cell.accessoryView = view;
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIImageView *)stateView {
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    return view;
}

@end
