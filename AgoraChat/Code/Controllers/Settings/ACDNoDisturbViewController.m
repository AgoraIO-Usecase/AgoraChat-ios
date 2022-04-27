//
//  ACDNoDisturbViewController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDNoDisturbViewController.h"
#import "ACDTitleDetailCell.h"
#import "AgoraGroupPermissionCell.h"
#import "ACDNodisturbTimeCell.h"
#import "SPDateTimePickerView.h"

static NSString *agoraGroupPermissionCellIdentifier = @"AgoraGroupPermissionCell";

@interface ACDNoDisturbViewController ()<SPDateTimePickerViewDelegate>
@property (nonatomic,strong) NSString *noDisturbState;
@property (nonatomic,assign) BOOL silentModeEnable;

@end

@implementation ACDNoDisturbViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"Do Not Disturb" action:@selector(back) actionTarget:self];

    self.silentModeEnable = AgoraChatClient.sharedClient.pushManager.pushOptions.silentModeEnabled;
    self.noDisturbState = self.silentModeEnable ?@"ON":@"Off";
    [self.table reloadData];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Action
- (void)disturbValueChanged
{
   
    if (self.silentModeEnable) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            AgoraChatError *error = [[AgoraChatClient sharedClient].pushManager enableOfflinePush];
            if (error == nil) {
                self.silentModeEnable = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.table reloadData];
                });
            } else {
                [self showHint:error.errorDescription];
            }
        });
        
    }else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            int noDisturbingStartH = 0;
            int noDisturbingEndH = 24;
            
            AgoraChatError *error = [[AgoraChatClient sharedClient].pushManager disableOfflinePushStart:noDisturbingStartH end:noDisturbingEndH];
            if (error == nil) {
                self.silentModeEnable = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.table reloadData];
                });
            }else {
                [self showHint:error.errorDescription];
            }
        });
    }
}


- (void)changeDisturbDateAction
{
    SPDateTimePickerView *pickerView = [[SPDateTimePickerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  self.view.frame.size.height)];
    pickerView.pickerViewMode = SPDatePickerModeTime;
    pickerView.delegate = self;
    pickerView.title = NSLocalizedString(@"setTime", nil);
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

#pragma mark - SPDateTimePickerViewDelegate
- (void)didClickFinishDateTimePickerView:(NSString *)date {
    NSLog(@"%@",date);
    NSRange range = [date rangeOfString:@"-"];
    NSString *start = [date substringToIndex:range.location];
    NSString *end = [date substringFromIndex:range.location + 1];
    if ([start isEqualToString:end]) {
        [self showHint:NSLocalizedString(@"timeWrong", nil)];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int noDisturbingStartH = [start intValue];;
        int noDisturbingEndH = [end intValue];
        AgoraChatError *error = [[AgoraChatClient sharedClient].pushManager disableOfflinePushStart:noDisturbingStartH end:noDisturbingEndH];
        if (!error) {
            [self hideHud];
            self.silentModeEnable = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table reloadData];
            });
        } else {
            [self showHint:error.description];
        }
    });
    
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
   
    ACDNodisturbTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:[ACDNodisturbTimeCell reuseIdentifier]];
    if (!timeCell) {
        timeCell = [[ACDNodisturbTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDNodisturbTimeCell reuseIdentifier]];
        timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    
    AgoraGroupPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:agoraGroupPermissionCellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraGroupPermissionCell" owner:self options:nil] lastObject];
        cell.permissionSwitch.hidden = NO;
        cell.permissionDescriptionLabel.hidden = YES;
    }
    
    if (indexPath.row == 0) {
        cell.permissionTitleLabel.text = @"Do Not Disturb";
        [cell.permissionSwitch setOn:self.silentModeEnable animated:NO];
        cell.switchStateBlock = ^(BOOL isOn) {
            self.silentModeEnable = isOn;
            [self disturbValueChanged];
        };
        return cell;
    }else if(indexPath.row == 1) {
        NSString *silentStartTime = [@(AgoraChatClient.sharedClient.pushManager.pushOptions.silentModeStart) stringValue];
        
        timeCell.nameLabel.text = @"From";
        [timeCell.timeButton setTitle:silentStartTime forState:UIControlStateNormal];
        timeCell.timeButtonBlock = ^{
            [self changeDisturbDateAction];
        };
        return timeCell;
    }else {
        NSString *silentEndTime = [@(AgoraChatClient.sharedClient.pushManager.pushOptions.silentModeEnd) stringValue];
        
        timeCell.nameLabel.text = @"To";
        [timeCell.timeButton setTitle:silentEndTime forState:UIControlStateNormal];
        timeCell.timeButtonBlock = ^{
            [self changeDisturbDateAction];
        };
        return timeCell;
    }
    
    return UITableViewCell.new;
}




@end
