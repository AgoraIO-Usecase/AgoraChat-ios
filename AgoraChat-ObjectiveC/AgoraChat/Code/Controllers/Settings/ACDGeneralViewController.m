//
//  ACDGeneralViewController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/8.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDGeneralViewController.h"
#import "ACDTitleDetailCell.h"
#import "ACDNoDisturbViewController.h"
#import "ACDTitleSwitchCell.h"
#import "AgoraTranslateSettingViewController.h"


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
    if (ACDDemoOptions.sharedOptions.enableTranslate)
        return 5;
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ACDTitleSwitchCell *cell = nil;
    if(indexPath.row < 4)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:[ACDTitleSwitchCell reuseIdentifier]];
        if (cell == nil) {
            cell =[[ACDTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDTitleSwitchCell reuseIdentifier]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:[ACDTitleDetailCell reuseIdentifier]];
        if (cell == nil) {
            cell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    ACDDemoOptions *options = [ACDDemoOptions sharedOptions];

    if(indexPath.row == 0) {
        cell.nameLabel.text = @"Typing Indicator";
        [cell.aSwitch setOn:options.isChatTyping animated:NO];
        
        cell.switchActionBlock  = ^(BOOL isOn) {
            options.isChatTyping = isOn;
            [[ACDDemoOptions sharedOptions] archive];
            [self.table reloadData];
        };
    }else if(indexPath.row == 1) {
        cell.nameLabel.text = @"Need approval when join a group";

        [cell.aSwitch setOn:options.isAutoAcceptGroupInvitation animated:NO];
        cell.switchActionBlock = ^(BOOL isOn) {
            [AgoraChatClient.sharedClient.options setAutoAcceptGroupInvitation:isOn];
            options.isAutoAcceptGroupInvitation = isOn;
            [options archive];
            [self.table reloadData];
        };
    }else if(indexPath.row == 2) {
        cell.nameLabel.text = NSLocalizedString(@"setting.deleteChatAfterLeaveGroup", nil);
        [cell.aSwitch setOn:options.deleteMessagesOnLeaveGroup animated:NO];
        cell.switchActionBlock  = ^(BOOL isOn) {
            [AgoraChatClient.sharedClient.options setDeleteMessagesOnLeaveGroup:isOn];
            options.deleteMessagesOnLeaveGroup = isOn;
            [options archive];

            [self.table reloadData];
        };
    } else if(indexPath.row == 3){
        cell.nameLabel.text = NSLocalizedString(@"translate", nil);
        [cell.aSwitch setOn:options.enableTranslate animated:NO];
        cell.switchActionBlock  = ^(BOOL isOn) {
            options.enableTranslate = isOn;
            [options archive];

            [self.table reloadData];
        };
    } else if(indexPath.row == 4) {
        cell.nameLabel.text = NSLocalizedString(@"translate.setting", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        WEAK_SELF
        cell.tapCellBlock = ^{
            [weakSelf pushTranslateSettingVC];
        };
    }
    
    return cell;
}

- (void)pushTranslateSettingVC
{
    AgoraTranslateSettingViewController* translateVC = [[AgoraTranslateSettingViewController alloc] initWithNibName:@"AgoraTranslateSettingViewController" bundle:nil];
    [self.navigationController pushViewController:translateVC animated:YES];
}

@end
