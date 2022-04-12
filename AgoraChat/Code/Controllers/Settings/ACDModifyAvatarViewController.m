//
//  ACDModifyAvatarViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/5.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDModifyAvatarViewController.h"
#import "ACDAvatarCollectionCell.h"

@interface ACDModifyAvatarViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation ACDModifyAvatarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
    
    [self placeAndLayoutSubviews];
    [self loadItems];
}


- (void)placeAndLayoutSubviews {
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)loadItems {
    for (NSInteger i = 1; i < 8; ++i) {
        NSString *imageName = [NSString stringWithFormat:@"defatult_avatar_%@",@(i)];
        [self.itemArray addObject:imageName];
    }
    
    [self.collectionView reloadData];
}

- (void)doneAction {
    if (self.selectedIndexPath && self.selectedBlock) {
        NSString *imageName = self.itemArray[self.selectedIndexPath.row];
        self.selectedBlock(imageName);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ACDAvatarCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ACDAvatarCollectionCell reuseIdentifier] forIndexPath:indexPath];
    
    NSString *imageName = self.itemArray[indexPath.row];
    [cell.iconImageView setImage:ImageWithName(imageName)];
    
    if (self.selectedIndexPath.row == indexPath.row) {
        cell.selected = YES;
    }else {
        cell.selected = NO;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    self.selectedIndexPath = indexPath;
    [self.collectionView reloadData];
}


#pragma mark getter and setter
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) collectionViewLayout:self.collectionViewLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[ACDAvatarCollectionCell class] forCellWithReuseIdentifier:[ACDAvatarCollectionCell reuseIdentifier]];
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

@end
