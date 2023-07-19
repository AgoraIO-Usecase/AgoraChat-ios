//
//  ACDChatDetailViewController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDChatDetailViewController.h"
#import "ACDTitleDetailCell.h"
#import "AgoraGroupPermissionCell.h"
#import "ACDNoDisturbViewController.h"
#import "ACDInfoSwitchCell.h"
#import "ACDInfoDetailCell.h"
#import "ACDChatRecordViewController.h"


@interface ACDChatDetailViewController ()
@property (nonatomic,strong) NSString *noDisturbState;
@property (nonatomic,strong) ACDInfoDetailCell *searchHistoryCell;
@property (nonatomic,strong) ACDInfoSwitchCell *silentModeCell;
@property (nonatomic,strong) ACDInfoSwitchCell *pinTopCell;
@property (nonatomic, strong) AgoraChatConversation *conversation;
@property (nonatomic, strong) EaseConversationModel *conversationModel;

@end

@implementation ACDChatDetailViewController
- (instancetype)initWithCoversation:(AgoraChatConversation *)aConversation
{
    self = [super init];
    if (self) {
        _conversation = aConversation;
        _conversationModel = [[EaseConversationModel alloc]initWithConversation:_conversation];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"Back" action:@selector(back) actionTarget:self];

    self.noDisturbState = AgoraChatClient.sharedClient.pushManager.pushOptions.silentModeEnabled ?@"ON":@"Off";
    [self.table reloadData];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark private method
- (void)goNodisturbPage {
    ACDNoDisturbViewController *vc = [[ACDNoDisturbViewController alloc] init];
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
    switch (indexPath.row) {
        case 0:
            return self.searchHistoryCell;
        case 1:
            return self.silentModeCell;
        case 2:
            return self.pinTopCell;
        default:
            break;
    }
    
    return UITableViewCell.new;
}

#pragma mark getter and setter
- (ACDInfoDetailCell *)searchHistoryCell {
    if (_searchHistoryCell == nil) {
        _searchHistoryCell = [[ACDInfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        _searchHistoryCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [_searchHistoryCell.iconImageView setImage:ImageWithName(@"chat_setting_search")];
        _searchHistoryCell.nameLabel.text = @"Search Message History";
        _searchHistoryCell.detailLabel.text = @"";
        ACD_WS
        _searchHistoryCell.tapCellBlock = ^{
            ACDChatRecordViewController *chatRrcordController = [[ACDChatRecordViewController alloc]initWithConversationModel:weakSelf.conversation];
            [weakSelf.navigationController pushViewController:chatRrcordController animated:YES];
        };
        
    }
    return _searchHistoryCell;
}


- (ACDInfoSwitchCell *)silentModeCell {
    if (_silentModeCell == nil) {
        _silentModeCell = [[ACDInfoSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoSwitchCell reuseIdentifier]];
        [_silentModeCell.iconImageView setImage:ImageWithName(@"chat_setting_mute")];
        _silentModeCell.nameLabel.text = @"Mute Notification";
        NSArray *ignoredUidList = [[AgoraChatClient sharedClient].pushManager noPushUIds];
        if ([ignoredUidList containsObject:self.conversation.conversationId]) {
            [_silentModeCell.aSwitch setOn:(YES) animated:YES];
        } else {
            [_silentModeCell.aSwitch setOn:(NO) animated:YES];
        }
        
        ACD_WS
        _silentModeCell.switchActionBlock = ^(BOOL isOn) {
//            [[EaseIMKitManager shared] updateUndisturbMapsKey:self.conversation.conversationId value:aSwitch.isOn];
            [[AgoraChatClient sharedClient].pushManager updatePushServiceForUsers:@[weakSelf.conversation.conversationId] disablePush:isOn completion:^(AgoraChatError * _Nonnull aError) {
                if (aError) {
                    [weakSelf showHint:[NSString stringWithFormat:NSLocalizedString(@"setDistrbute", nil),aError.errorDescription]];
//                    [weakSelf.silentModeCell.aSwitch setOn:NO];
                }
            }];
        };
    }
    return _silentModeCell;
}

- (ACDInfoSwitchCell *)pinTopCell {
    if (_pinTopCell == nil) {
        _pinTopCell = [[ACDInfoSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoSwitchCell reuseIdentifier]];
        [_pinTopCell.iconImageView setImage:ImageWithName(@"chat_setting_top")];
        _pinTopCell.nameLabel.text = @"Sticky on Top";
        [_pinTopCell.aSwitch setOn:([self.conversationModel isTop]) animated:YES];

        ACD_WS
        _pinTopCell.switchActionBlock = ^(BOOL isOn) {
            //置顶
            if (isOn) {
                [weakSelf.conversationModel setIsTop:YES];
            } else {
                [weakSelf.conversationModel setIsTop:NO];
            }

        };
    }
    return _pinTopCell;
}

@end

