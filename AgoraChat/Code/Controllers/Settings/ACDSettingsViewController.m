//
//  ACDSettingsViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSettingsViewController.h"
#import "UIImage+ImageEffect.h"
#import "AgoraUserModel.h"
#import "AgoraContactInfoCell.h"
#import "AgoraChatDemoHelper.h"
#import "ACDInfoHeaderView.h"
#import "ACDInfoCell.h"
#import "ACDInfoDetailCell.h"
#import "ACDSettingLogoutCell.h"
#import "AgoraAboutViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ACDModifyAvatarViewController.h"
#import "UserInfoStore.h"

#define kInfoHeaderViewHeight 320.0
#define kHeaderInSection  30.0


typedef enum : NSUInteger {
    AgoraContactInfoActionNone,
    AgoraContactInfoActionDelete,
    AgoraContactInfoActionBlackList,
} AgoraContactInfoAction;

@interface ACDSettingsViewController ()<UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) ACDInfoHeaderView *userInfoHeaderView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) ACDInfoDetailCell *aboutCell;
@property (nonatomic, strong) ACDSettingLogoutCell *logoutCell;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, copy)   NSString *myNickName;
@property (nonatomic, strong) AgoraChatUserInfo *userInfo;

@end

@implementation ACDSettingsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self fetchUserInfo];
}

- (void)fetchUserInfo {
    
    [self preloadHeaderView];

    [AgoraChatUserInfoManagerHelper fetchOwnUserInfoCompletion:^(AgoraChatUserInfo * _Nonnull ownUserInfo) {
            self.userInfo = ownUserInfo;
            self.myNickName = self.userInfo.nickName ?:self.userInfo.userId;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateHeaderView];
            });
    }];
}

- (void)preloadHeaderView {
    self.myNickName = AgoraChatClient.sharedClient.currentUsername;
    self.userInfo.userId = self.myNickName;
    [self updateHeaderView];
}

- (void)updateHeaderView {
    self.userInfoHeaderView.nameLabel.text = self.myNickName;
    NSString *userId = self.userInfo.userId ?:self.myNickName;
    self.userInfoHeaderView.userIdLabel.text = [NSString stringWithFormat:@"AgoraID: %@",userId];

    if (self.userInfo.avatarUrl) {
        [self.userInfoHeaderView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:ImageWithName(@"defatult_avatar_1")];
    }else {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        NSString *imageName = [userDefault valueForKey:[NSString stringWithFormat:@"%@_avatar",self.userInfo.userId]];
                 
        if (imageName == nil) {
            imageName = @"defatult_avatar_1";
        }
        [self.userInfoHeaderView.avatarImageView sd_setImageWithURL:nil placeholderImage:ImageWithName(imageName)];
    }
    [self.table reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self fetchUserInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark public method
- (void)networkChanged:(AgoraChatConnectionState)connectionState {
    if (connectionState == AgoraChatConnectionConnected) {
        [self fetchUserInfo];
    }else {
        [self preloadHeaderView];
    }
}


#pragma mark - Action
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        [scrollView setContentOffset:contentOffset];
    }
}

- (void)logoutAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sure to Quit?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    [cancelAction setValue:TextLabelBlueColor forKey:@"titleTextColor"];

    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self logout];
    }];
        
    [confirmAction setValue:TextLabelBlueColor forKey:@"titleTextColor"];

    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)logout
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WEAK_SELF
    [[AgoraChatClient sharedClient] logout:YES completion:^(AgoraChatError *aError) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!aError) {
            NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
            [shareDefault setObject:@"" forKey:USER_NAME];
            [shareDefault setObject:@"" forKey:USER_NICKNAME];
            [shareDefault synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO userInfo:@{@"userName":@"",@"nickName":@""}];
        } else {
            [weakSelf showHint:[NSString stringWithFormat:@"%@:%u",NSLocalizedString(@"logout.failed", @"Logout failed"), aError.code]];
        }
    }];
}

- (void)goAboutPage {
    AgoraAboutViewController *about = [[AgoraAboutViewController alloc] init];
    about.title = NSLocalizedString(@"title.setting.about", @"About");
    about.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:about animated:YES];
}

- (void)headerViewTapAction {
   
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *changeAvatarAction = [UIAlertAction alertActionWithTitle:@"Change Avatar" iconImage:ImageWithName(@"action_icon_change_avatar") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self changeAvatar];
    }];
    
    
    UIAlertAction *changeNicknameAction = [UIAlertAction alertActionWithTitle:@"Change Nickname" iconImage:ImageWithName(@"action_icon_edit") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self changeNickName];
    }];

    UIAlertAction *copyAction = [UIAlertAction alertActionWithTitle:@"Copy AgoraID" iconImage:ImageWithName(@"action_icon_copy") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [UIPasteboard generalPasteboard].string = self.userInfo.userId;
    }];
   
    
    [alertController addAction:changeAvatarAction];
    [alertController addAction:changeNicknameAction];
    [alertController addAction:copyAction];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changeAvatar {
    ACDModifyAvatarViewController *vc = ACDModifyAvatarViewController.new;
    vc.selectedBlock = ^(NSString * _Nonnull imageName) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:imageName forKey:[NSString stringWithFormat:@"%@_avatar",self.userInfo.userId]];
        [userDefault synchronize];
        
        UIImage *selectedImage = [UIImage imageWithColor:[UIColor blueColor] size:CGSizeMake(140.0, 140.0)];
        [self.userInfoHeaderView.avatarImageView setImage:ImageWithName(imageName)];
    };
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
//    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
//    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}


- (void)changeNickName {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change Nick Name" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {

    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.ok", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *messageTextField = alertController.textFields.firstObject;
        [self updateMyNickname:messageTextField.text];

    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateMyNickname:(NSString *)newName
{
    if (newName.length > 0 && ![_myNickName isEqualToString:newName])
    {
        self.myNickName = newName;
        self.userInfoHeaderView.nameLabel.text = self.myNickName;

        [AgoraChatUserInfoManagerHelper updateUserInfoWithUserId:newName withType:AgoraChatUserInfoTypeNickName completion:^(AgoraChatUserInfo * _Nonnull aUserInfo) {
            if (aUserInfo) {
                [UserInfoStore.sharedInstance setUserInfo:aUserInfo forId:AgoraChatClient.sharedClient.currentUsername];
                [[NSNotificationCenter defaultCenter] postNotificationName:USERINFO_UPDATE  object:nil userInfo:@{USERINFO_LIST:@[aUserInfo]}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.table reloadData];
            });
        }];
    }
}


#pragma mark NOti
- (void)reloadNotificationStatus {
    [self.table reloadData];
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.uploading", @"Uploading..")];
    WEAK_SELF
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (orgImage) {
//        [[AgoraUserProfileManager sharedInstance] uploadUserHeadImageProfileInBackground:orgImage completion:^(BOOL success, NSError *error) {
//            [weakSelf hideHud];
//            if (success) {
//
//                [weakSelf showHint:NSLocalizedString(@"setting.uploadSuccess", @"uploaded successfully")];
//                UserProfileEntity *user = [[AgoraUserProfileManager sharedInstance] getCurUserProfile];
//                [weakSelf.avatarView imageWithUsername:user.username placeholderImage:orgImage];
//            } else {
//                [weakSelf showHint:NSLocalizedString(@"setting.uploadFailed", @"Upload Failed")];
//            }
//        }];
        
//        [self.avatarView imageWithUsername:nil placeholderImage:orgImage];
    } else {
        [self hideHud];
        [self showHint:NSLocalizedString(@"setting.uploadFailed", @"Upload Failed")];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderInSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kHeaderInSection)];
    
    UILabel *label = [self sectionTitleLabel];
    if (section == 0) {
        label.text = @"Settings";
    }else {
        label.text = @"Logins";
    }
    [sectionView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sectionView);
        make.left.equalTo(sectionView).offset(16.0);
    }];
    
    return sectionView;
}

- (UILabel *)sectionTitleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = TextLabelGrayColor;
    label.text = @"setting";
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return self.aboutCell;
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        return self.logoutCell;
    }
    
    return UITableViewCell.new;
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
        _table.tableHeaderView = [self headerView];
        [_table registerClass:[ACDInfoDetailCell class] forCellReuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        _table.rowHeight = [ACDInfoDetailCell height];
    }
    return _table;
}


- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kInfoHeaderViewHeight)];
        [_headerView addSubview:self.userInfoHeaderView];
        [self.userInfoHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerView);
        }];
    }
    return _headerView;
}

- (ACDInfoHeaderView *)userInfoHeaderView {
    if (_userInfoHeaderView == nil) {
        _userInfoHeaderView = [[ACDInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kInfoHeaderViewHeight) withType:ACDHeaderInfoTypeMe];
        
        ACD_WS
        _userInfoHeaderView.tapHeaderBlock = ^{
            [weakSelf headerViewTapAction];
        };
        
    }
    return _userInfoHeaderView;
}


- (ACDInfoDetailCell *)aboutCell {
    if (_aboutCell == nil) {
        _aboutCell = [[ACDInfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoDetailCell reuseIdentifier]];
        _aboutCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [_aboutCell.iconImageView setImage:ImageWithName(@"About")];
        _aboutCell.nameLabel.text= @"About";
        _aboutCell.detailLabel.text = [NSString stringWithFormat:@"AgoraChat %@",[AgoraChatClient sharedClient].version];
        ACD_WS
        _aboutCell.tapCellBlock = ^{
            [weakSelf goAboutPage];
        };
    }
    return  _aboutCell;
}

- (ACDSettingLogoutCell *)logoutCell {
    if (_logoutCell == nil) {
        _logoutCell = [[ACDSettingLogoutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDSettingLogoutCell reuseIdentifier]];
        _logoutCell.nameLabel.textColor = TextLabelBlueColor;
        _logoutCell.nameLabel.text = @"Log Out";
        ACD_WS
        _logoutCell.tapCellBlock = ^{
            [weakSelf logoutAlert];
        };
    }
    return  _logoutCell;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}


@end
#undef kInfoHeaderViewHeight
#undef kHeaderInSection




