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

static NSString *agoraGroupPermissionCellIdentifier = @"AgoraGroupPermissionCell";

@interface ACDGeneralViewController ()
@property (nonatomic,strong) NSString *noDisturbState;

@end

@implementation ACDGeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.noDisturbState = AgoraChatClient.sharedClient.pushManager.pushOptions.silentModeEnabled ?@"ON":@"Off";
    [self.table reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ACDTitleDetailCell *noDisturbCell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
    noDisturbCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    AgoraGroupPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:agoraGroupPermissionCellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraGroupPermissionCell" owner:self options:nil] lastObject];
        cell.permissionSwitch.hidden = NO;
        cell.permissionDescriptionLabel.hidden = YES;
    }
    
    if (indexPath.row == 0) {
        noDisturbCell.nameLabel.text = @"Do Not Disturb";
        noDisturbCell.detailLabel.text = self.noDisturbState;
        return noDisturbCell;
    }else if(indexPath.row == 1) {
        cell.permissionTitleLabel.text = @"Show Typing";
        [cell.permissionSwitch setOn:NO animated:NO];
        cell.switchStateBlock = ^(BOOL isOn) {
            
        };
    }else if(indexPath.row == 2) {
        cell.permissionTitleLabel.text = @"Add Group Request";
        BOOL autoAcceptGroupRequest = AgoraChatClient.sharedClient.options.autoAcceptGroupInvitation;
        [cell.permissionSwitch setOn:autoAcceptGroupRequest animated:NO];
        cell.switchStateBlock = ^(BOOL isOn) {
            [AgoraChatClient.sharedClient.options setAutoAcceptGroupInvitation:isOn];
        };
    }else if(indexPath.row == 3) {
        cell.permissionTitleLabel.text = @"Delete the Chat after Leaving Group";
        BOOL deleteMessagesOnLeaveGroup = AgoraChatClient.sharedClient.options.deleteMessagesOnLeaveGroup;
        [cell.permissionSwitch setOn:deleteMessagesOnLeaveGroup animated:NO];
        cell.switchStateBlock = ^(BOOL isOn) {
            [AgoraChatClient.sharedClient.options setDeleteMessagesOnLeaveGroup:isOn];
        };
    }
    
    return cell;
}

@end
