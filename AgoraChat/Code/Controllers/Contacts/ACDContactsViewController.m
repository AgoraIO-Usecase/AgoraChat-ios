//
//  AgoraChatNewContactsViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContactsViewController.h"
#import "MISScrollPage.h"
#import "ACDContactListController.h"
#import "ACDGroupListViewController.h"
#import "ACDRequestListViewController.h"
#import "ACDNaviCustomView.h"
#import "ACDGroupMembersViewController.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraApplyManager.h"

#import "ACDGroupEnterController.h"

#import "ACDGroupInfoViewController.h"
#import "ACDContactInfoViewController.h"
#import "AgoraUserModel.h"

@interface ACDContactsViewController ()<MISScrollPageControllerDataSource,
MISScrollPageControllerDelegate,ACDGroupInfoViewControllerDelegate>
@property (nonatomic, strong) MISScrollPageController *pageController;
@property (nonatomic, strong) MISScrollPageSegmentView *segView;
@property (nonatomic, strong) MISScrollPageContentView *contentView;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic,strong) ACDContactListController *contactListVC;
@property (nonatomic,strong) ACDGroupListViewController *groupListVC;
@property (nonatomic,strong) ACDRequestListViewController *requestListVC;
@property (nonatomic,strong) ACDNaviCustomView *navView;

@property (nonatomic, strong) NSMutableArray *contactRequests;
@property (nonatomic, strong) NSMutableArray *groupNotifications;

@end

@implementation ACDContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self placeAndLayoutSubviews];
    
    [self.pageController reloadData];
    
    [self reloadContactRequests];
    
}


- (void)placeAndLayoutSubviews {
    UIView *container = UIView.new;
    container.backgroundColor = UIColor.whiteColor;
    container.clipsToBounds = YES;
    
//    [self.view addSubview:self.navView];
//    [self.view addSubview:self.segView];
//    [self.view addSubview:self.contentView];
  
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

- (void)goAddPage {

    ACDGroupEnterController *groupEnterVC = ACDGroupEnterController.new;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:groupEnterVC];
    nav.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (void)goGroupInfoPageWithGroupId:(NSString *)groupId withAccessType:(ACDGroupInfoAccessType)accessType {
    ACDGroupInfoViewController *vc = [[ACDGroupInfoViewController alloc] initWithGroupId:groupId];
    vc.delegate = self;
    vc.accessType = accessType;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goContactInfoWithContactId:(NSString *)contactId {
    AgoraUserModel * model = [[AgoraUserModel alloc] initWithHyphenateId:contactId];
    ACDContactInfoViewController *vc = [[ACDContactInfoViewController alloc] initWithUserModel:model];

    ACD_WS
    vc.addBlackListBlock = ^{
        [weakSelf.contactListVC reloadContacts];
    };
    vc.deleteContactBlock = ^{
        [weakSelf.contactListVC reloadContacts];
    };
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)reloadContacts {
    [self.contactListVC reloadContacts];
}

- (void)reloadContactRequests {
    ACD_WS
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSArray *contactApplys = [[AgoraApplyManager defaultManager] contactApplys];
        weakSelf.contactRequests = [NSMutableArray arrayWithArray:contactApplys];
        [[AgoraChatDemoHelper shareHelper] setupUntreatedApplyCount];
    });
}


- (void)reloadGroupNotifications {
    ACD_WS
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSArray *groupApplys = [[AgoraApplyManager defaultManager] groupApplys];
        weakSelf.groupNotifications = [NSMutableArray arrayWithArray:groupApplys];
        [[AgoraChatDemoHelper shareHelper] setupUntreatedApplyCount];
    });
}

- (void)navBarUnreadRequestIsShow:(BOOL)isShow {
    if (self.segView.titles.count == 0) {
        return;
    }
    [self.segView reloadTitleRedPointWithISShow:isShow withTitleIndex:2];
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
    return 3;
}

- (NSArray*)titlesOfSegmentView {
    return @[@"Friends",@"Groups",@"Requests"];
}


- (NSArray*)childViewControllersOfContentView{
    return @[self.contactListVC,self.groupListVC,self.requestListVC];
}

#pragma mark -
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController didAppearForIndex:(NSUInteger)index {
    self.currentPageIndex = index;
}


- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController willDisappearForIndex:(NSUInteger)index {
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
//        style.segmentViewShadowColor = COLOR_RGB(248,248,248);
        _pageController = [MISScrollPageController scrollPageControllerWithStyle:style dataSource:self delegate:self];
    }
    return _pageController;
}

- (MISScrollPageSegmentView*)segView {
    if(!_segView){
        _segView = [self.pageController segmentViewWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    }
    return _segView;
}

- (MISScrollPageContentView*)contentView {
    if(!_contentView){
        _contentView = [self.pageController contentViewWithFrame:CGRectMake(0, 50, KScreenWidth, KScreenHeight-64-50-5-44.0)];
    }
    return _contentView;
}


- (ACDContactListController *)contactListVC {
    if (_contactListVC == nil) {
        _contactListVC = ACDContactListController.new;
        ACD_WS
        _contactListVC.selectedBlock = ^(NSString * _Nonnull contactId) {
            [weakSelf goContactInfoWithContactId:contactId];
        };
    }
    return _contactListVC;
}

- (ACDGroupListViewController *)groupListVC {
    if (_groupListVC == nil) {
        _groupListVC = ACDGroupListViewController.new;
        _groupListVC.hidesBottomBarWhenPushed = YES;

        ACD_WS
        _groupListVC.selectedBlock = ^(NSString * _Nonnull groupId) {
            [weakSelf goGroupInfoPageWithGroupId:groupId withAccessType:ACDGroupInfoAccessTypeContact];
        };
    }
    return _groupListVC;
}

- (ACDRequestListViewController *)requestListVC {
    if (_requestListVC == nil) {
        _requestListVC = ACDRequestListViewController.new;
    }
    return _requestListVC;
}

- (ACDNaviCustomView *)navView {
    if (_navView == nil) {
        _navView = [[ACDNaviCustomView alloc] init];
        ACD_WS
        _navView.addActionBlock = ^{
            [weakSelf goAddPage];
        };
    }
    return _navView;
}


@end
