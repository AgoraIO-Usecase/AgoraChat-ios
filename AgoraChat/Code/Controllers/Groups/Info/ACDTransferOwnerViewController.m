//
//  ACDTransViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDTransferOwnerViewController.h"
#import "ACDInfoDetailCell.h"
#import "UIViewController+HUD.h"
#import "AgoraNotificationNames.h"
#import "AgoraUserModel.h"

@interface ACDTransferOwnerViewController ()

@property (nonatomic, strong) AgoraChatGroup *group;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, copy) NSString *aOwner;

@end

@implementation ACDTransferOwnerViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.showRefreshHeader = YES;
//    self.showRefreshFooter = YES;
        
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchState) {
        return self.searchResults.count;
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ACDInfoDetailCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDInfoDetailCell *cell = (ACDInfoDetailCell *)[tableView dequeueReusableCellWithIdentifier:[ACDInfoDetailCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDInfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *name = self.dataArray[indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:@"default_avatar"];
    cell.nameLabel.text = name;

    if (name == self.group.owner) {
        cell.detailLabel.text = @"owner";
    } else if([self.group.adminList containsObject:name]){
        cell.detailLabel.text = @"admin";
    }else {
        cell.detailLabel.text = @"";
    }
    
    ACD_WS
    cell.tapCellBlock = ^{
        weakSelf.aOwner = name;
        if (weakSelf.isLeaveGroup) {
            [weakSelf transferAndLeaveAlert];
        }else {
            [weakSelf transferAlert];
        }
    };
    return cell;
}

#pragma mark - Action
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


//- (void)doneAction
//{
//    if (self.selectedIndexPath) {
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        NSString *aOwner = [self.dataArray objectAtIndex:self.selectedIndexPath.row];
//
//        __weak typeof(self) weakSelf = self;
//        [[AgoraChatClient sharedClient].groupManager updateGroupOwner:self.group.groupId aOwner:aOwner completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
//            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//            weakSelf.group = aGroup;
//            if (aError) {
//                [weakSelf showHint:NSLocalizedString(@"group.changeOwnerFail", @"Failed to change owner")];
//            } else {
//                if (self.transferOwnerBlock) {
//                    self.transferOwnerBlock();
//                }
//                [weakSelf backAction];
//            }
//        }];
//    }
//}

- (void)transferAlert {
    NSString *title = [NSString stringWithFormat:@"Transfer Ownership to %@ ",self.aOwner];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    
    UIAlertAction *transferAction = [UIAlertAction actionWithTitle:@"Transfer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self transferWithNewOwner:self.aOwner];
    }];
        
    [transferAction setValue:TextLabelPinkColor forKey:@"titleTextColor"];

    [alertController addAction:cancelAction];
    [alertController addAction:transferAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)transferAndLeaveAlert {
    NSString *title = [NSString stringWithFormat:@"Transfer Ownership to %@ and Leave this Group?",self.aOwner];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    
    UIAlertAction *transferAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [transferAction setValue:TextLabelPinkColor forKey:@"titleTextColor"];

    [alertController addAction:cancelAction];
    [alertController addAction:transferAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)transferWithNewOwner:(NSString *)aOwner {
    ACD_WS
    [[AgoraChatClient sharedClient].groupManager updateGroupOwner:self.group.groupId newOwner:aOwner completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        weakSelf.group = aGroup;
        if (aError) {
            [weakSelf showHint:@"Failed to change owner"];
        } else {
            if (self.isLeaveGroup) {
                [self leaveGroupWithGroupId:self.group.groupId];
            }else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

- (void)leaveGroupWithGroupId:(NSString *)groupId {
    [self showHudInView:self.view hint:@"Leave group"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        AgoraChatError *error = nil;
        [[AgoraChatClient sharedClient].groupManager leaveGroup:groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
            if (error) {
                [self showHint:@"leave the group failure"];
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_END_CHAT object:groupId];
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
    });
}


#pragma mark - Data
- (void)updateUIWithResultList:(NSArray *)sourceList IsHeader:(BOOL)isHeader {
    
    if (isHeader) {
        [self.dataArray removeAllObjects];
        [self.dataArray addObject:self.group.owner];
        [self.dataArray addObjectsFromArray:self.group.adminList];
    }
    
    [self.dataArray addObjectsFromArray:sourceList];
}


- (void)tableViewDidTriggerHeaderRefresh{
    self.cursor = @"";
    [self fetchMembersWithCursor:self.cursor isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithCursor:self.cursor isHeader:NO];
}

- (void)fetchMembersWithCursor:(NSString *)cursor
                      isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    ACD_WS
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[AgoraChatClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.group.groupId cursor:cursor pageSize:pageSize completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        weakSelf.cursor = aResult.cursor;
        [weakSelf hideHud];
//        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        if (!aError) {
            [weakSelf updateUIWithResultList:aResult.list IsHeader:aIsHeader];
            [weakSelf.table reloadData];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.member.fetchFail", @"failed to get the member list, please try again later")];
        }
        
        if ([aResult.list count] < pageSize) {
//            weakSelf.showRefreshFooter = NO;
        } else {
//            weakSelf.showRefreshFooter = YES;
        }
    }];
}

@end
