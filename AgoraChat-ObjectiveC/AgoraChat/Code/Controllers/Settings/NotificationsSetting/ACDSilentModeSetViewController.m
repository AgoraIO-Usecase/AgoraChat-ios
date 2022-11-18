//
//  ACDSilentModeSetViewController.m
//  AgoraChat
//
//  Created by hxq on 2022/3/22.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDSilentModeSetViewController.h"
#import "ACDDateHelper.h"
#import "ACDSilentModeSetCell.h"

@interface ACDSilentModeSetViewController ()
@property (nonatomic ,copy) NSString *navTitle;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger selecIndex;
@end

@implementation ACDSilentModeSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
    [self loadData];
}

- (void)loadData {
    self.selecIndex = -1;
    self.dataArray = @[@"For 15 Minutes",@"For 1 Hour",@"For 8 Hours",@"For 24 Hours",@"Until 8:00 AM Tomorow"];
    [self.table reloadData];
}
- (void)setupNavBar {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"black_goBack"] forState:UIControlStateNormal];
    [backButton setTitle:self.navTitle forState:UIControlStateNormal];
    [backButton setTitleColor:TextLabelBlackColor forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneBtn.frame = CGRectMake(0, 0, 44, 44);
    [_doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_doneBtn setTitleColor:TextLabelBlueColor forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(selectDoneAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_doneBtn];
   
}

#pragma mark - action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)selectDoneAction
{
    if (self.selecIndex == -1) {
        [self showHint:@"You haven't made a choice yet!"];
        return;
    }
    
    int durationMinutes = 0;
    switch (self.selecIndex) {
        case 0:
            durationMinutes = 15;
            break;
        case 1:
            durationMinutes = 60;
            break;
        case 2:
            durationMinutes = 8*60;
            break;
        case 3:
            durationMinutes = 24*60;
            break;
        case 4:
        {//计算到明天八点的时间差值
            durationMinutes = [self distanceToTomorowEightAM];
        }
            break;
            
        default:
            break;
    }
    
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Loading..")];
    ACD_WS
    AgoraChatSilentModeParam *param = [[AgoraChatSilentModeParam alloc] initWithParamType:AgoraChatSilentModeParamTypeDuration];
    param.silentModeDuration = durationMinutes;
    if (self.notificationType == AgoraNotificationSettingTypeSelf) {
        [[AgoraChatClient sharedClient].pushManager setSilentModeForAll:param completion:^(AgoraChatSilentModeResult * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            [weakSelf hideHud];
            if (!aError) {
                if(weakSelf.doneBlock)
                    weakSelf.doneBlock(aResult);
                [weakSelf backAction];
            }else{
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"Fail")];
            }
        }];
    }else{
        AgoraChatConversationType type = AgoraChatConversationTypeGroupChat;
        if (self.notificationType == AgoraNotificationSettingTypeSingleChat) {
            type = AgoraChatConversationTypeChat;
        }
        [[AgoraChatClient sharedClient].pushManager setSilentModeForConversation:self.conversationID conversationType:type params:param completion:^(AgoraChatSilentModeResult * _Nonnull aResult, AgoraChatError * _Nonnull aError) {
            [weakSelf hideHud];
            if (!aError) {
                if(weakSelf.doneBlock)
                    weakSelf.doneBlock(aResult);
                [weakSelf backAction];
            }else{
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"Fail")];
            }
        }];
    }
    
}

- (int)distanceToTomorowEightAM
{
    int distance = 0;
    //目前距离24:00点的时间分钟加上8小时
    NSString *currentTime = [ACDDateHelper  getCurrentDataWithHHmmFormatter];
    NSArray  *timeArray = [currentTime componentsSeparatedByString:@":"];
    if (timeArray.count == 2) {
        int hours = [[timeArray objectAtIndex:0] intValue];
        int minute = [[timeArray objectAtIndex:1] intValue];
        int distanceHour = 23 - hours;
        int distanceMinute = 60 - minute;
        distance = (distanceHour + 8)*60 + distanceMinute;
    }
    
    return distance;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ACDSilentModeSetCell *cell = [tableView dequeueReusableCellWithIdentifier:[ACDSilentModeSetCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ACDSilentModeSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDSilentModeSetCell reuseIdentifier]];
    }
    cell.tag = indexPath.row +100;
    cell.nameLabel.text = self.dataArray[indexPath.row];
    ACD_WS
    cell.selectBlock = ^(NSInteger tag) {
        weakSelf.selecIndex = tag - 100;
    };
    return cell;
}


#pragma mark getter and setter

- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = COLOR_HEX(0xFFFFFF);
        _table.rowHeight = 54.0f;
    }
    return _table;
}

-(NSString *)navTitle
{
    if (_navTitle == nil) {
        switch (self.notificationType) {
            case AgoraNotificationSettingTypeSelf:
                _navTitle = @"Notifications";
               
                break;
            case AgoraNotificationSettingTypeSingleChat:
                _navTitle = @"Contact Notifications";
              
                break;
            case AgoraNotificationSettingTypeGroup:
                _navTitle = @"Group Notifications";
                
                break;
            case AgoraNotificationSettingTypeThread:
                _navTitle = @"Thead Notifications";
                break;
            default:
                break;
        }
    }
    return _navTitle;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
