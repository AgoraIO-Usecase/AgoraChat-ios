//
//  ACDGroupMemberSelectViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupMemberSelectViewController.h"
#import "AgoraUserModel.h"
#import "ACDMemberCollectionCell.h"
#import "AgoraRealtimeSearchUtils.h"
#import "NSArray+AgoraSortContacts.h"
#import "AgoraGroupMemberCell.h"


#define NEXT_TITLE   NSLocalizedString(@"common.next", @"Next")

#define DONE_TITLE   @"Done"

#define kCollectionViewHeight 90.0f

@interface ACDGroupMemberSelectViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AgoraGroupUIProtocol>

@property (strong, nonatomic) NSMutableArray<AgoraUserModel *> *selectContacts;

@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *unselectedContacts;
@property (nonatomic) NSInteger maxInviteCount;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) NSMutableArray *hasInvitees;

@end


@implementation ACDGroupMemberSelectViewController
//{
//    UIButton *_doneBtn;
//    NSMutableArray *_hasInvitees;
//    NSMutableArray *self.sectionTitles;
//    NSMutableArray *self.searchSource;
//    NSMutableArray *_searchResults;
//    BOOL self.isSearchState;
//}

- (instancetype)initWithInvitees:(NSArray *)aHasInvitees
                  maxInviteCount:(NSInteger)aCount
{
    self = [super init];
    if (self) {
        _selectContacts = [NSMutableArray array];
        _unselectedContacts = [NSMutableArray array];
        self.hasInvitees = [NSMutableArray arrayWithArray:aHasInvitees];
        _maxInviteCount = aCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupNavBar];
    [self loadUnSelectContacts];
}

- (void)prepare {
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.table];
}

- (void)placeSubViews {
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(12.0);
        make.right.equalTo(self.view).offset(-12.0);
        make.height.equalTo(@44.0);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).offset(15.0);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(0);
    }];

    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)setupNavBar {
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"gray_goBack"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneBtn.frame = CGRectMake(0, 0, 44, 44);
    [self updateDoneButtonStateEnabled:NO];
    NSString *title = @"Create";
    if (_style == AgoraContactSelectStyle_Invite) {
        title = DONE_TITLE;
    }

    [_doneBtn setTitle:title forState:UIControlStateNormal];
    [_doneBtn setTitle:title forState:UIControlStateHighlighted];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_doneBtn setTitleColor:TextLabelBlueColor forState:UIControlStateNormal];
    
    [_doneBtn addTarget:self action:@selector(selectDoneAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:_doneBtn];
    [self.navigationItem setRightBarButtonItem:rightBar];
}

- (void)updateHeaderView:(BOOL)isAdd {
//    if (_selectContacts.count > 0 && self.collectionView.hidden) {
//        CGFloat height = self.collectionView.frame.size.height;
//        CGRect frame = self.headerView.frame;
//        frame.size.height += height;
//        self.headerView.frame = frame;
//
//        frame = self.table.frame;
//        frame.origin.y += height;
//        frame.size.height -= height;
//        self.table.frame = frame;
//        [_collectionView reloadData];
//        self.collectionView.hidden = NO;
//
//        return;
//    }
//
//    if (_selectContacts.count == 0 && !self.collectionView.hidden) {
//        self.collectionView.hidden = YES;
//        CGFloat height = self.collectionView.frame.size.height;
//        CGRect frame = self.headerView.frame;
//        frame.size.height -= height;
//        self.headerView.frame = frame;
//
//        frame = self.table.frame;
//        frame.origin.y -= height;
//        frame.size.height += height;
//        self.table.frame = frame;
//        [_collectionView reloadData];
//        return;
//    }
    
    if (self.selectContacts.count > 0) {
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kCollectionViewHeight);
        }];
    }else {
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
//    if (isAdd) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectContacts.count - 1 inSection:0];
//        [_collectionView insertItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
//    }
    
}

- (void)updateDoneButtonStateEnabled:(BOOL)enabled {
    _doneBtn.userInteractionEnabled = enabled;
    if (enabled) {
        [_doneBtn setTitleColor:TextLabelBlueColor forState:UIControlStateNormal];
        [_doneBtn setTitleColor:TextLabelBlueColor forState:UIControlStateHighlighted];
    }
    else {
        [_doneBtn setTitleColor:CoolGrayColor forState:UIControlStateNormal];
        [_doneBtn setTitleColor:CoolGrayColor forState:UIControlStateHighlighted];
    }
}

- (void)loadUnSelectContacts {
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:[[AgoraChatClient sharedClient].contactManager getContacts]];
    NSArray *blockList = [[AgoraChatClient sharedClient].contactManager getBlackList];
    [contacts removeObjectsInArray:blockList];
    [contacts removeObjectsInArray:_hasInvitees];
    [_hasInvitees removeAllObjects];
    
    NSMutableArray *sectionTitles = nil;
    NSMutableArray *searchSource = nil;
    NSArray *sortArray = [NSArray sortContacts:contacts
                                 sectionTitles:&sectionTitles
                                  searchSource:&searchSource];
    [self.unselectedContacts addObjectsFromArray:sortArray];
    self.sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    self.searchSource = [NSMutableArray arrayWithArray:searchSource];
}


- (void)removeOccupantsFromDataSource:(NSArray<AgoraUserModel *> *)modelArray {
    __block NSMutableArray *array = [NSMutableArray array];
        
    ACD_WS
    [modelArray enumerateObjectsUsingBlock:^(AgoraUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([weakSelf.selectContacts containsObject:obj]) {
            NSUInteger index = [weakSelf.selectContacts indexOfObject:obj];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [array addObject:indexPath];
            [weakSelf.selectContacts removeObjectsInArray:modelArray];
        }
        
        if (array.count > 0) {
            [weakSelf.collectionView deleteItemsAtIndexPaths:array];
        }
        
        if (weakSelf.selectContacts.count == 0) {
            [self updateDoneButtonStateEnabled:NO];
        }
        
        [weakSelf.table reloadData];
        [weakSelf.collectionView reloadData];
        [weakSelf updateHeaderView:NO];
        
    }];
}

#pragma mark - Action
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectDoneAction {
    if (_delegate && [_delegate respondsToSelector:@selector(addSelectOccupants:)]) {
        [_delegate addSelectOccupants:_selectContacts];
    }
    [self backAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearchState) {
        return 1;
    }
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchState) {
        return self.searchResults.count;
    }
    return [(NSArray *)_unselectedContacts[section] count];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.isSearchState) {
        return @[];
    }
    return self.sectionTitles;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgoraGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:[AgoraGroupMemberCell reuseIdentifier]];
    if (!cell) {
        cell = [[AgoraGroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[AgoraGroupMemberCell reuseIdentifier]];
    }
    
    AgoraUserModel *model = nil;
    if (self.isSearchState) {
        model = self.searchResults[indexPath.row];
    }
    else {
        NSMutableArray *array = _unselectedContacts[indexPath.section];
        model = array[indexPath.row];
    }
    cell.isSelected = [_hasInvitees containsObject:model.hyphenateId];
    cell.isEditing = YES;
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView && scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
    if (scrollView == self.collectionView && scrollView.contentOffset.x < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectContacts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ACDMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ACDMemberCollectionCell reuseIdentifier] forIndexPath:indexPath];
    cell.model = _selectContacts[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    AgoraUserModel *model = _selectContacts[indexPath.row];
    [self removeOccupantsFromDataSource:@[model]];
    [self.collectionView reloadData];
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 5, collectionView.frame.size.height);
}


#pragma mark - AgoraGroupUIProtocol
- (void)addSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray {
    [self.selectContacts addObjectsFromArray:modelArray];
    for (AgoraUserModel *model in modelArray) {
        [_hasInvitees addObject:model.hyphenateId];
    }
    [self updateDoneButtonStateEnabled:YES];
    [self updateHeaderView:YES];
}

- (void)removeSelectOccupants:(NSArray<AgoraUserModel *> *)modelArray {
    [self removeOccupantsFromDataSource:modelArray];
}

#pragma mark getter and setter
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kCollectionViewHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.yellowColor;
        
        [_collectionView registerClass:[ACDMemberCollectionCell class] forCellWithReuseIdentifier:[ACDMemberCollectionCell reuseIdentifier]];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat itemWidth = (KScreenWidth - 5.0 * 2)/2.0;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumLineSpacing = 5.0;
    flowLayout.minimumInteritemSpacing = 5.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0,
                                               0,
                                               0,
                                               0);
    return flowLayout;
}

- (NSMutableArray *)itemArray {
    if (_itemArray == nil) {
        _itemArray = NSMutableArray.new;
    }
    return _itemArray;
}

- (UITableView *)table {
    if (!_table) {
        _table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStylePlain];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = UIColor.whiteColor;
        
        [_table registerClass:[AgoraGroupMemberCell class] forCellReuseIdentifier:[AgoraGroupMemberCell reuseIdentifier]];
        
        _table.sectionIndexColor = SectionIndexTextColor;
        _table.sectionIndexBackgroundColor = [UIColor clearColor];
        
        _table.tableFooterView = [UIView new];
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
    }
    return _table;
}


@end
#undef kCollectionViewHeight

