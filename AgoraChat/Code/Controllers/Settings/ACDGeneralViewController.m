//
//  ACDGeneralViewController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/8.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDGeneralViewController.h"
#import "ACDTitleDetailCell.h"
#import "AgoraGroupPermissionCell.h"
#import "ACDNoDisturbViewController.h"

static NSString *agoraGroupPermissionCellIdentifier = @"AgoraGroupPermissionCell";

@interface ACDGeneralViewController ()
@property (nonatomic,strong) NSString *noDisturbState;

@end

@implementation ACDGeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"General" action:@selector(back) actionTarget:self];

    self.noDisturbState = AgoraChatClient.sharedClient.pushManager.pushOptions.silentModeEnabled ?@"ON":@"Off";
    [self.table reloadData];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark private method
- (void)goNodisturbPage {
    ACDNoDisturbViewController *vc = ACDNoDisturbViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
    AgoraGroupPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:agoraGroupPermissionCellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraGroupPermissionCell" owner:self options:nil] lastObject];
        cell.permissionSwitch.hidden = NO;
        cell.permissionDescriptionLabel.hidden = YES;
    }
    
    ACDDemoOptions *options = [ACDDemoOptions sharedOptions];

    if(indexPath.row == 0) {
        cell.permissionTitleLabel.text = @"Show Typing";
        [cell.permissionSwitch setOn:options.isChatTyping animated:NO];
        
        cell.switchStateBlock = ^(BOOL isOn) {
            options.isChatTyping = isOn;
            [[ACDDemoOptions sharedOptions] archive];
            [self.table reloadData];
        };
    }else if(indexPath.row == 1) {
        cell.permissionTitleLabel.text = @"Add Group Request";
        BOOL autoAcceptGroupRequest = AgoraChatClient.sharedClient.options.autoAcceptGroupInvitation;
        [cell.permissionSwitch setOn:autoAcceptGroupRequest animated:NO];
        cell.switchStateBlock = ^(BOOL isOn) {
            [AgoraChatClient.sharedClient.options setAutoAcceptGroupInvitation:isOn];
            options.isAutoAcceptGroupInvitation = isOn;
            [options archive];
            [self.table reloadData];
        };
    }else {
        cell.permissionTitleLabel.text = @"Delete the Chat after Leaving Group";
        BOOL deleteMessagesOnLeaveGroup = AgoraChatClient.sharedClient.options.deleteMessagesOnLeaveGroup;
        [cell.permissionSwitch setOn:deleteMessagesOnLeaveGroup animated:NO];
        cell.switchStateBlock = ^(BOOL isOn) {
            [AgoraChatClient.sharedClient.options setDeleteMessagesOnLeaveGroup:isOn];
            [self.table reloadData];
        };
    }
    
    return cell;
}

@end
