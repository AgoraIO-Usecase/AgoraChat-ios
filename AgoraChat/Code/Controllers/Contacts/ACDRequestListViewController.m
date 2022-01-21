//
//  AgoraRequestListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDRequestListViewController.h"
#import "MISScrollPage.h"
#import "ACDRequestCell.h"
#import "AgoraApplyManager.h"
#import "AgoraApplyModel.h"

@interface ACDRequestListViewController ()

@end

@implementation ACDRequestListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}


- (void)updateUI {
    [self.dataArray removeAllObjects];
    
    NSArray *contactApplys = [[AgoraApplyManager defaultManager] contactApplys];
    NSArray *groupApplys = [[AgoraApplyManager defaultManager] groupApplys];
    [self.dataArray addObjectsFromArray:contactApplys];
    [self.dataArray addObjectsFromArray:groupApplys];
    
    self.searchSource = [NSMutableArray arrayWithArray:self.dataArray];
    [self.table reloadData];
}

#pragma mark action
- (void)declineAction:(AgoraApplyModel *)model {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    switch (model.style) {
        case AgoraApplyStyle_contact:
        {
            [[AgoraChatClient sharedClient].contactManager declineFriendRequestFromUser:model.applyHyphenateId completion:^(NSString *aUsername, AgoraChatError *aError) {
                [weakSelf declineApplyFinished:aError model:model];
            }];

            break;
        }
        case AgoraApplyStyle_joinGroup:
        {
            [[AgoraChatClient sharedClient].groupManager declineJoinGroupRequest:model.groupId sender:model.applyHyphenateId reason:nil completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
                [weakSelf declineApplyFinished:aError model:model];
            }];
            break;
        }
        default:
        {
            [[AgoraChatClient sharedClient].groupManager declineGroupInvitation:model.groupId inviter:model.applyHyphenateId reason:nil completion:^(AgoraChatError *aError) {
                [weakSelf declineApplyFinished:aError model:model];
            }];
            break;
        }
    }
}


- (void)acceptAction:(AgoraApplyModel *)model {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    switch (model.style) {
        case AgoraApplyStyle_contact:
        {
            [[AgoraChatClient sharedClient].contactManager approveFriendRequestFromUser:model.applyHyphenateId completion:^(NSString *aUsername, AgoraChatError *aError) {
                [weakSelf acceptApplyFinished:aError model:model];
            }];
            break;
        }
        case AgoraApplyStyle_joinGroup:
        {
            [[AgoraChatClient sharedClient].groupManager approveJoinGroupRequest:model.groupId sender:model.applyHyphenateId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
                [weakSelf acceptApplyFinished:aError model:model];
            }];
            break;
        }
        default:
        {
            [[AgoraChatClient sharedClient].groupManager acceptInvitationFromGroup:model.groupId inviter:model.applyHyphenateId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
                [weakSelf acceptApplyFinished:aError model:model];
            }];
            break;
        }
    }
}

- (void)declineApplyFinished:(AgoraChatError *)error
                       model:(AgoraApplyModel*)model{
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    if (!error) {
        [[AgoraApplyManager defaultManager] removeApplyRequest:model];
    }
    else {
        [self showAlertWithMessage:@"Refused to apply for failure"];
    }
    
    [self.table reloadData];
}

- (void)acceptApplyFinished:(AgoraChatError *)error
                      model:(AgoraApplyModel*)model {
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    if (!error) {
        [[AgoraApplyManager defaultManager] removeApplyRequest:model];
    }
    else {
        [self showAlertWithMessage:@"Failed to agree to apply"];
    }
    
    [self.table reloadData];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchState) {
        return [self.searchResults count];
    }
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AgoraGroupCell";
    ACDRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ACDRequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    AgoraApplyModel *applyModel = nil;
    if (self.isSearchState) {
        applyModel = self.searchResults[indexPath.row];
    }else {
        applyModel = self.dataArray[indexPath.row];
    }
    
    [cell updateWithObj:applyModel];
    ACD_WS
    cell.acceptBlock = ^(AgoraApplyModel * _Nonnull model) {
        applyModel.applyStatus = ACDApplyStatusAgreed;
        [weakSelf acceptAction:model];
    };
    
    cell.rejectBlock = ^(AgoraApplyModel * _Nonnull model) {
        applyModel.applyStatus = ACDApplyStatusDeclined;
        [weakSelf declineAction:model];
    };
    
    return cell;
}


#pragma mark getter and setter
- (UITableView *)table {
    if (_table == nil) {
        _table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_table registerClass:[ACDRequestCell class] forCellReuseIdentifier:[ACDRequestCell reuseIdentifier]];
        _table.rowHeight = 102.0f;
    }
    return _table;
}


#pragma mark MISScrollPageControllerContentSubViewControllerDelegate
- (void)viewDidAppearForIndex:(NSUInteger)index{
    [self updateUI];
    [[AgoraChatDemoHelper shareHelper] hiddenApplyRedPoint];
}

- (void)viewDidDisappearForIndex:(NSUInteger)index {
    [self updateUI];
    [[AgoraChatDemoHelper shareHelper] setupUntreatedApplyCount];

}

@end
