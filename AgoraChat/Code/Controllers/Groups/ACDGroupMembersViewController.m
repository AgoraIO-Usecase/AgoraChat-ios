//
//  ACDGroupMembersViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/28.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMembersViewController.h"
#import "MISScrollPage.h"
#import "ACDGroupMemberAllViewController.h"
#import "ACDGroupMemberAdminListViewController.h"
#import "ACDGroupMemberMutedListViewController.h"
#import "ACDGroupMemberBlockListViewController.h"

#import "ACDGroupMembersViewController.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraApplyManager.h"
#import "ACDGroupMemberNavView.h"
#import "AgoraMemberSelectViewController.h"
#import "AgoraUserModel.h"

@interface ACDGroupMembersViewController ()<MISScrollPageControllerDataSource,
MISScrollPageControllerDelegate,AgoraGroupUIProtocol>
@property (nonatomic, strong) MISScrollPageController *pageController;
@property (nonatomic, strong) MISScrollPageSegmentView *segView;
@property (nonatomic, strong) MISScrollPageContentView *contentView;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic,strong) ACDGroupMemberAllViewController *allVC;
@property (nonatomic,strong) ACDGroupMemberAdminListViewController *adminListVC;
@property (nonatomic,strong) ACDGroupMemberMutedListViewController *mutedListVC;
@property (nonatomic,strong) ACDGroupMemberBlockListViewController *blockListVC;


@property (nonatomic,strong) ACDGroupMemberNavView *navView;
@property (nonatomic, strong) AgoraChatGroup *group;

@property (nonatomic, strong) NSMutableArray *navTitleArray;
@property (nonatomic, strong) NSMutableArray *contentVCArray;
@property (nonatomic, strong) NSMutableArray *inviteArray;


@end

@implementation ACDGroupMembersViewController
- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup {
    self = [self init];
    if (self) {
        self.group = aGroup;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithNotification:) name:KAgora_REFRESH_GROUP_INFO object:nil];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self placeAndLayoutSubviews];
    
    [self updateNavTitle];

    [self.pageController reloadData];
    
}

- (void)placeAndLayoutSubviewsForMember {
    UIView *container = UIView.new;
    container.backgroundColor = UIColor.whiteColor;
    container.clipsToBounds = YES;
    
    [self.view addSubview:container];
    [self.view addSubview:self.navView];
    [container addSubview:self.allVC.view];
    
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
    }];
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(5);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)placeAndLayoutSubviewsForAdmin {
    UIView *container = UIView.new;
    container.backgroundColor = UIColor.whiteColor;
    container.clipsToBounds = YES;
    
    [self.view addSubview:container];
    [self.view addSubview:self.navView];
    [container addSubview:self.segView];
    [container addSubview:self.contentView];
    
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
    }];
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(5);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-bottom);
    }];
}


- (void)placeAndLayoutSubviews {
    [self placeAndLayoutSubviewsForAdmin];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark Notification
- (void)updateUIWithNotification:(NSNotification *)aNotification
{
    id obj = aNotification.object;
    if (obj && [obj isKindOfClass:[AgoraChatGroup class]]) {
        AgoraChatGroup *group = (AgoraChatGroup *)obj;
        if ([group.groupId isEqualToString:self.group.groupId]) {
            self.group = group;
            [self updateNavTitle];
        }
    }
}

- (void)updateNavTitle {
    _navView.leftLabel.text = @"Members";
    _navView.leftSubLabel.text = [NSString stringWithFormat:@"(%@)",@(self.group.occupantsCount)];
}

- (void)updateWithGroup:(AgoraChatGroup *)agoraGroup {
    self.group = agoraGroup;
    [self updateNavTitle];
    [self.allVC updateUI];
}

#pragma mark action
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addGroupMember {
    AgoraMemberSelectViewController *selectVC = [[AgoraMemberSelectViewController alloc] initWithInvitees:@[] maxInviteCount:0];
    selectVC.style = AgoraContactSelectStyle_Invite;
    selectVC.title = @"Add Members";
    selectVC.delegate = self;
    [self.navigationController pushViewController:selectVC animated:YES];

}

#pragma mark - AgoraGroupUIProtocol
- (void)addSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray {
        
    for (AgoraUserModel *model in modelArray) {
        [self.inviteArray addObject:model.hyphenateId];
    }
    
    ACD_WS
    [[AgoraChatClient sharedClient].groupManager addMembers:self.inviteArray toGroup:weakSelf.group.groupId message:@"" completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        [weakSelf hideHud];
        if (aError) {
            [self showHint:aError.description];
        } else {
                
        }
    }];
    
}

#pragma mark ACDGroupInfoViewControllerDelegate
- (void)checkGroupMemberListWithGroup:(AgoraChatGroup *)group {
    ACDGroupMembersViewController *vc = ACDGroupMembersViewController.new;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)enterGroupChatWithGroup:(AgoraChatGroup *)group {
    NSLog(@"%s",__func__);
}

#pragma mark - scrool pager data source and delegate
- (NSUInteger)numberOfChildViewControllers {
    return self.navTitleArray.count;
}

- (NSArray*)titlesOfSegmentView {
    return self.navTitleArray;
}


- (NSArray*)childViewControllersOfContentView {
    return self.contentVCArray;
}

#pragma mark -
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController didAppearForIndex:(NSUInteger)index {
    self.currentPageIndex = index;
}


#pragma mark - setter or getter
- (MISScrollPageController*)pageController{
    if(!_pageController){
        MISScrollPageStyle* style = [[MISScrollPageStyle alloc] init];
        style.showCover = YES;
        style.coverBackgroundColor = COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = COLOR_HEX(0x999999);
        style.selectedTitleColor = COLOR_HEX(0x000000);
        style.scrollLineColor = COLOR_HEXA(0x000000, 0.5);

        style.scaleTitle = YES;
        style.titleBigScale = 1.05;
        style.titleFont = NFont(13);
        style.autoAdjustTitlesWidth = YES;
        style.showSegmentViewShadow = YES;
        _pageController = [MISScrollPageController scrollPageControllerWithStyle:style dataSource:self delegate:self];
    }
    return _pageController;
}

- (MISScrollPageSegmentView*)segView{
    if(!_segView){
        _segView = [self.pageController segmentViewWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    }
    return _segView;
}

- (MISScrollPageContentView*)contentView {
    if(!_contentView){
        _contentView = [self.pageController contentViewWithFrame:CGRectMake(0, 50, KScreenWidth, KScreenHeight-64-50-5)];
    }
    return _contentView;
}


- (ACDGroupMemberAllViewController *)allVC {
    if (_allVC == nil) {
        _allVC = [[ACDGroupMemberAllViewController alloc] initWithGroup:self.group];
    }
    return _allVC;
}

- (ACDGroupMemberAdminListViewController *)adminListVC {
    if (_adminListVC == nil) {
        _adminListVC = [[ACDGroupMemberAdminListViewController alloc] initWithGroup:self.group];
    }
    return _adminListVC;
}

- (ACDGroupMemberMutedListViewController *)mutedListVC {
    if (_mutedListVC == nil) {
        _mutedListVC = [[ACDGroupMemberMutedListViewController alloc] initWithGroup:self.group];
    }
    return _mutedListVC;
}

- (ACDGroupMemberBlockListViewController *)blockListVC {
    if (_blockListVC == nil) {
        _blockListVC = [[ACDGroupMemberBlockListViewController alloc] initWithGroup:self.group];
    }
    return _blockListVC;
}

- (ACDGroupMemberNavView *)navView {
    if (_navView == nil) {
        _navView = [[ACDGroupMemberNavView alloc] init];
       
        if (_group.permissionType == AgoraChatGroupPermissionTypeMember) {
            if (_group.setting.style == AgoraChatGroupStylePrivateMemberCanInvite) {
                _navView.rightButton.hidden = NO;
            }else {
                _navView.rightButton.hidden = YES;
            }
        }
        ACD_WS
        _navView.leftButtonBlock = ^{
            [weakSelf backAction];
        };
        
        _navView.rightButtonBlock = ^{
            [weakSelf addGroupMember];
        };
    }
    return _navView;
}

- (NSMutableArray *)navTitleArray {
    if (_navTitleArray == nil) {
        _navTitleArray = NSMutableArray.new;
    }
    return _navTitleArray;
}

- (NSMutableArray *)contentVCArray {
    if (_contentVCArray == nil) {
        _contentVCArray = NSMutableArray.new;
    }
    return _contentVCArray;
}

- (void)setGroup:(AgoraChatGroup *)group {
    _group = group;

    self.navTitleArray = [@[@"All",@"Admin",@"Mute",@"Block"] mutableCopy];

    self.contentVCArray = [@[self.allVC,self.adminListVC,self.mutedListVC,self.blockListVC] mutableCopy];

}

- (NSMutableArray *)inviteArray {
    if (_inviteArray == nil) {
        _inviteArray = NSMutableArray.new;
    }
    return _inviteArray;
}
@end
