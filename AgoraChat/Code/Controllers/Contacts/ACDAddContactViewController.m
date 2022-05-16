//
//  ACDAddContactViewController.m
//  ChatDemo-UI3.0
//
//  Created by zhangchong on 2021/12/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDAddContactViewController.h"
#import "ACDInfoHeaderView.h"
#import "PresenceManager.h"


@interface ACDAddContactViewController ()
@property (nonatomic, strong) AgoraUserModel *model;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) ACDInfoHeaderView *contactInfoHeaderView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *displayBtn;

@end

@implementation ACDAddContactViewController

- (instancetype)initWithUserModel:(AgoraUserModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubviews];
    [self loadContactInfo];
    // Do any additional setup after loading the view.
}


- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:102/255.0];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [bgView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(bgView);
        make.height.equalTo(@84);
    }];
    
    [bgView addSubview:self.contactInfoHeaderView];
    [self.contactInfoHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bgView);
        make.bottom.equalTo(self.bottomView.mas_top);
        make.height.equalTo(@360);
    }];
    
    [self _updatePresenceStatus];
    [bgView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bgView);
        make.bottom.equalTo(self.contactInfoHeaderView.mas_top);
        make.height.equalTo(@25);
    }];
}

- (void)_updatePresenceStatus
{
    [[[AgoraChatClient sharedClient] presenceManager] fetchPresenceStatus:@[self.model.hyphenateId] completion:^(NSArray<AgoraChatPresence *> *presences, AgoraChatError *error) {
        if(!error && presences.count > 0) {
            AgoraChatPresence* presence = [presences objectAtIndex:0];
            if(presence) {
                NSInteger status = [PresenceManager fetchStatus:presence];
                NSString* imageName = [[PresenceManager whiteStrokePresenceImages] objectForKey:[NSNumber numberWithInteger:status]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.contactInfoHeaderView.avatarImageView setPresenceImage:[UIImage imageNamed:imageName]];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.contactInfoHeaderView.avatarImageView setPresenceImage:[UIImage imageNamed:kPresenceOfflineDescription]];
                });
                
            }
        }
    }];
}

- (void)loadContactInfo {
    self.contactInfoHeaderView.userIdLabel.text = [NSString stringWithFormat:@"AgoraID: %@",_model.hyphenateId];
    self.contactInfoHeaderView.nameLabel.text = _model.nickname;
    self.contactInfoHeaderView.avatarImageView.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [self.contactInfoHeaderView.avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    
}

- (void)applyContactAction
{
    [AgoraChatClient.sharedClient.contactManager addContact:_model.hyphenateId message:@"" completion:^(NSString *aUsername, AgoraChatError *aError) {
        if (!aError) {
            self.addButton.enabled = NO;
        } else {
            [self showAlertWithMessage:aError.errorDescription];
            self.addButton.enabled = YES;
        }
    }];
}

- (void)displayAction:(UITapGestureRecognizer *)aTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark getter and setter
- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        CGFloat radius = 16;
        CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, 25);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = rect;
        maskLayer.path = path.CGPath;
        _headerView.layer.mask = maskLayer;
        
        [_headerView addSubview:self.displayBtn];
        [self.displayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@50);
            make.height.equalTo(@8);
            make.center.equalTo(_headerView);
        }];
    }
    return _headerView;
}

- (UIButton *)displayBtn
{
    if (!_displayBtn) {
        _displayBtn = [[UIButton alloc]init];
        [_displayBtn setBackgroundColor:[UIColor systemGrayColor]];
        _displayBtn.layer.cornerRadius = 4;
        [_displayBtn addTarget:self action:@selector(displayAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _displayBtn;
}

- (ACDInfoHeaderView *)contactInfoHeaderView {
    if (_contactInfoHeaderView == nil) {
        _contactInfoHeaderView = [[ACDInfoHeaderView alloc] initWithType:ACDHeaderInfoTypeContact];
        _contactInfoHeaderView.backgroundColor = [UIColor whiteColor];
        _contactInfoHeaderView.isHideChatButton = YES;
        _contactInfoHeaderView.isHideBackButton = YES;
    }
    return _contactInfoHeaderView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add"]];
        [_bottomView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_bottomView).offset(16);
            make.top.equalTo(_bottomView).offset(11);
            make.width.height.equalTo(@32);
        }];
        
        [_bottomView addSubview:self.addButton];
        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bottomView).offset(16);
            make.right.equalTo(_bottomView).offset(-16);
            make.width.equalTo(@70);
            make.height.equalTo(@25);
        }];
        
        UILabel *funcLabel = [[UILabel alloc]init];
        funcLabel.text = @"Add Contact";
        funcLabel.textColor = [UIColor blackColor];
        funcLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0];
        [_bottomView addSubview:funcLabel];
        [funcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imgView.mas_right).offset(8);
            make.right.equalTo(self.addButton.mas_left).offset(-8);
            make.centerY.equalTo(imgView);
        }];
        
    }
    return _bottomView;
}

- (UIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [[UIButton alloc] init];
        _addButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0];
        _addButton.titleLabel.textAlignment = NSTextAlignmentRight;
        
        [_addButton setTitleColor:[UIColor colorWithHexString:@"#154DFE"] forState:UIControlStateNormal];
        [_addButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        [_addButton setTitle:@"Apply" forState:UIControlStateNormal];
        [_addButton setTitle:@"Applied" forState:UIControlStateDisabled];
        
        [_addButton addTarget:self action:@selector(applyContactAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

@end
