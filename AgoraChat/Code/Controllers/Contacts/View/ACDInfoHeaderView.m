//
//  AgoraInfoBaseHeaderView.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDInfoHeaderView.h"
#import "ACDImageTextButtonView.h"

#define kMeHeaderImageViewHeight  140.0f
#define kBackIconSize 40.0f


@interface ACDInfoHeaderView ()
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) ACDImageTextButtonView *chatView;
@property (nonatomic, assign) ACDHeaderInfoType infoType;

@end


@implementation ACDInfoHeaderView
#pragma mark life cycle
- (instancetype)initWithFrame:(CGRect)frame
                     withType:(ACDHeaderInfoType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.infoType = type;
        [self placeAndLayoutSubviews];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderViewAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (instancetype)initWithType:(ACDHeaderInfoType)type
{
    self = [super init];
    if (self) {
        self.infoType = type;
        [self placeAndLayoutSubviews];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderViewAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)placeAndLayoutSubviews {
    if (self.infoType == ACDHeaderInfoTypeContact) {
        [self placeAndLayoutForContactInfo];
    }

    if (self.infoType == ACDHeaderInfoTypeGroup) {
        [self placeAndLayoutForGroupInfo];
    }
    
    if (self.infoType == ACDHeaderInfoTypeMe) {
        [self placeAndLayoutForMeInfo];
    }
    
}

- (void)placeAndLayoutForContactInfo {
    self.avatarImageView.layer.cornerRadius = kMeHeaderImageViewHeight * 0.5;
    self.avatarImageView.layer.masksToBounds = YES;
    
    [self addSubview:self.backButton];
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.userIdLabel];
    [self addSubview:self.chatView];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kAgroaPadding * 4.4);
        make.left.equalTo(self).offset(kAgroaPadding);
        make.size.mas_equalTo(kBackIconSize);
    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(kAgroaPadding);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(kMeHeaderImageViewHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(kAgroaPadding);
        make.left.equalTo(self).offset(kAgroaPadding * 5);
        make.right.equalTo(self).offset(-kAgroaPadding * 5);
        make.height.equalTo(@28.0);
    }];
    
    [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.left.equalTo(self).offset(kAgroaPadding * 5);
        make.right.equalTo(self).offset(-kAgroaPadding * 5);
        make.height.mas_equalTo(20.0);
    }];
    
    [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userIdLabel.mas_bottom).offset(kAgroaPadding);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(120.0);
        make.bottom.equalTo(self);
    }];
}

- (void)placeAndLayoutForGroupInfo {
    self.avatarImageView.image = ImageWithName(@"group_default_avatar");

//    [self addSubview:self.backButton];
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.userIdLabel];
    [self addSubview:self.describeLabel];
    [self addSubview:self.chatView];
    
//    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).offset(kAgroaPadding * 4.4);
//        make.left.equalTo(self).offset(kAgroaPadding);
//        make.size.mas_equalTo(kBackIconSize);
//    }];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kAgroaPadding *6.0);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(kMeHeaderImageViewHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(kAgroaPadding);
        make.left.equalTo(self).offset(kAgroaPadding * 5);
        make.right.equalTo(self).offset(-kAgroaPadding * 5);
        make.height.equalTo(@28.0);
    }];
    
    [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.left.equalTo(self).offset(kAgroaPadding * 5);
        make.right.equalTo(self).offset(-kAgroaPadding * 5);
        make.height.equalTo(@20.0);
    }];
    
    [self.describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userIdLabel.mas_bottom);
        make.left.equalTo(self).offset(kAgroaPadding * 5);
        make.right.equalTo(self).offset(-kAgroaPadding * 5);
        make.height.equalTo(@20.0);
    }];
    
    
    [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.describeLabel.mas_bottom).offset(kAgroaPadding);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(120.0);
        make.bottom.equalTo(self);
    }];
}

- (void)placeAndLayoutForMeInfo {

    self.avatarImageView.layer.cornerRadius = kMeHeaderImageViewHeight * 0.5;
    self.avatarImageView.layer.masksToBounds = YES;
    
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.userIdLabel];
        
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kAgroaPadding *9.2);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(kMeHeaderImageViewHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(kAgroaPadding);
        make.left.equalTo(self).offset(kAgroaPadding * 5);
        make.right.equalTo(self).offset(-kAgroaPadding * 5);
        make.height.equalTo(@28.0);
    }];
    
    [self.userIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.left.equalTo(self).offset(kAgroaPadding * 5);
        make.right.equalTo(self).offset(-kAgroaPadding * 5);
        make.height.mas_equalTo(20.0);
    }];
    
}


#pragma mark action
- (void)backAction {
    if (self.goBackBlock) {
        self.goBackBlock();
    }
}

- (void)goChatPageAction {
    if (self.goChatPageBlock) {
        self.goChatPageBlock();
    }
}

- (void)tapHeaderViewAction {
    if (self.tapHeaderBlock) {
        self.tapHeaderBlock();
    }
}


#pragma mark getter and setter
- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
        _backButton.contentMode = UIViewContentModeScaleAspectFill;
        [_backButton setImage:ImageWithName(@"black_goBack") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIImageView *)backImageView {
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backImageView.image = ImageWithName(@"black_goBack");
    }
    return _backImageView;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}


- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:20.0f];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textColor = COLOR_HEX(0x0D0D0D);
        _nameLabel.text = @"agoraChat";
//        _nameLabel.backgroundColor = UIColor.blueColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)userIdLabel {
    if (_userIdLabel == nil) {
        _userIdLabel = [[UILabel alloc] init];
        _userIdLabel.font = [UIFont systemFontOfSize:12.0f];
        _userIdLabel.numberOfLines = 1;
        _userIdLabel.textColor = COLOR_HEX(0x999999);
        _userIdLabel.text = @"";
        _userIdLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _userIdLabel;
}

- (UILabel *)describeLabel {
    if (_describeLabel == nil) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.font = [UIFont systemFontOfSize:14.0f];
        _describeLabel.textColor = COLOR_HEX(0x000000);
        _describeLabel.text = @"xxxxxxxxxxxx";
//        _describeLabel.backgroundColor = UIColor.blueColor;
        _describeLabel.textAlignment = NSTextAlignmentCenter;
        _describeLabel.preferredMaxLayoutWidth = KScreenWidth - 200.0f;
    }
    return _describeLabel;
}

- (ACDImageTextButtonView *)chatView {
    if (_chatView == nil) {
        _chatView = [[ACDImageTextButtonView alloc] init];
        [_chatView.iconImageView setImage:ImageWithName(@"start_chat")];
        _chatView.titleLabel.text = @"Chat";
        [_chatView.tapBtn addTarget:self action:@selector(goChatPageAction) forControlEvents:UIControlEventTouchUpInside];
//        _chatView.backgroundColor = UIColor.yellowColor;
        
    }
    return _chatView;
}

- (void)setIsHideChatButton:(BOOL)isHideChatButton {
    _isHideChatButton = isHideChatButton;
    if (_isHideChatButton) {
        self.chatView.hidden = YES;
    }
}

- (void)setIsHideBackButton:(BOOL)isHideBackButton
{
    if (isHideBackButton) {
        self.backButton.hidden = YES;
    } else {
        self.backButton.hidden = NO;
    }
}

@end

#undef kMeHeaderImageViewHeight
#undef kBackIconSize


