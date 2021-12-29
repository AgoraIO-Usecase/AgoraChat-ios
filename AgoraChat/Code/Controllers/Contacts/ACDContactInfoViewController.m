//
//  AgoraContactInfoNewViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContactInfoViewController.h"
#import "AgoraContactInfoViewController.h"
#import "UIImage+ImageEffect.h"
#import "AgoraUserModel.h"
#import "AgoraContactInfoCell.h"
#import "AgoraChatDemoHelper.h"
#import "ACDChatViewController.h"
#import "ACDInfoHeaderView.h"
#import "ACDInfoCell.h"

#define kContactInfoHeaderViewHeight 360.0

typedef enum : NSUInteger {
    AgoraContactInfoActionNone,
    AgoraContactInfoActionDelete,
    AgoraContactInfoActionBlackList,
} AgoraContactInfoAction;

@interface ACDContactInfoViewController ()<UIActionSheetDelegate, AgoraContactsUIProtocol>

@property (nonatomic, strong) AgoraUserModel *model;
@property (nonatomic, strong) ACDInfoHeaderView *contactInfoHeaderView;

@end

@implementation ACDContactInfoViewController

- (instancetype)initWithUserModel:(AgoraUserModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadContactInfo];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)loadContactInfo {
    self.contactInfoHeaderView.nameLabel.text = _model.nickname;
    self.contactInfoHeaderView.avatarImageView.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [self.contactInfoHeaderView.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Action
- (void)headerViewTapAction {
   
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *copyAction = [UIAlertAction alertActionWithTitle:@"Copy AgoraID" iconImage:ImageWithName(@"action_icon_copy") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [UIPasteboard generalPasteboard].string = _model.hyphenateId;
    }];
   
    [alertController addAction:copyAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark scollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGPoint contentOffset = scrollView.contentOffset;
        contentOffset.y = 0;
        [scrollView setContentOffset:contentOffset];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDInfoCell*cell = [tableView dequeueReusableCellWithIdentifier:[ACDInfoCell reuseIdentifier]];
    if (!cell) {
        cell = [[ACDInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDInfoCell reuseIdentifier]];
    }
    
    ACD_WS
    if (indexPath.row == 0) {
        [cell.iconImageView setImage:ImageWithName(@"blocked")];
        cell.nameLabel.text = @"Block Contact";
        
        cell.tapCellBlock = ^{
            [weakSelf blockAction];
        };

    }
    
    if (indexPath.row == 1) {
        [cell.iconImageView setImage:ImageWithName(@"delete")];
        cell.nameLabel.text = @"Delete Contact";
        cell.tapCellBlock = ^{
            [weakSelf deleteAction];
        };

    }

    
    return cell;
}

- (void)blockAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Block this contact now?" message:@"When you block this contact, you will not receive any messages from them." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *blackAction = [UIAlertAction actionWithTitle:@"Block" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addBlackList];
    }];
    [blackAction setValue:TextLabelPinkColor forKey:@"titleTextColor"];
    [alertController addAction:blackAction];
    
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)deleteAction  {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete this contact now?" message:@"Delete this contact and associated Chats." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteContact];
    }];
    [deleteAction setValue:TextLabelPinkColor forKey:@"titleTextColor"];

    [alertController addAction:deleteAction];
    
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        
    }
    
    if (indexPath.row == 1) {
       

    }
    
}



#pragma mark - UIActionSheetDelegate
- (void)deleteContact {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AgoraChatClient sharedClient].contactManager deleteContact:_model.hyphenateId isDeleteConversation:YES completion:^(NSString *aUsername, AgoraChatError *aError) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (!aError) {
            if (self.deleteContactBlock) {
                self.deleteContactBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.deleteFailure", @"Delete contacts failed")];
        }
    }];
}

- (void)addBlackList {
    [[AgoraChatClient sharedClient].contactManager addUserToBlackList:_model.hyphenateId completion:^(NSString *aUsername, AgoraChatError *aError) {
        if ((!aError)) {
            if (self.addBlackListBlock) {
                self.addBlackListBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.blockFailure", @"Black failure")];
        }
    }];
    
}

#pragma mark - AgoraContactsUIProtocol
- (void)needRefreshContactsFromServer:(BOOL)isNeedRefresh {
    if (isNeedRefresh) {
        [[AgoraChatDemoHelper shareHelper].contactsVC loadContactsFromServer];
    }
    else {
        [[AgoraChatDemoHelper shareHelper].contactsVC reloadContacts];
    }
}

#pragma mark getter and setter
- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kContactInfoHeaderViewHeight)];
        [_headerView addSubview:self.contactInfoHeaderView];
        [self.contactInfoHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerView);
        }];
    }
    return _headerView;
}


- (ACDInfoHeaderView *)contactInfoHeaderView {
    if (_contactInfoHeaderView == nil) {
        _contactInfoHeaderView = [[ACDInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kContactInfoHeaderViewHeight) withType:ACDHeaderInfoTypeContact];
        _contactInfoHeaderView.isHideChatButton = self.isHideChatButton;
        
        ACD_WS
        _contactInfoHeaderView.tapHeaderBlock = ^{
            [weakSelf headerViewTapAction];
        };
        
        _contactInfoHeaderView.goChatPageBlock = ^{
            ACDChatViewController *chatViewController = [[ACDChatViewController alloc] initWithConversationId:weakSelf.model.hyphenateId conversationType:AgoraChatConversationTypeChat];
            chatViewController.navTitle = weakSelf.model.nickname;
            chatViewController.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:chatViewController animated:YES];
        };
        
        _contactInfoHeaderView.goBackBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _contactInfoHeaderView;
}

- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = COLOR_HEX(0xFFFFFF);
        _table.tableHeaderView = [self headerView];
        _table.rowHeight = 54.0f;
    }
    return _table;
}


@end

#undef kContactInfoHeaderViewHeight
    


