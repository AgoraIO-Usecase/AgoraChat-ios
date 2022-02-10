//
//  ACDMemberCollectionCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDMemberCollectionCell.h"
#import "AgoraUserModel.h"

#define kIconHeight 60.0f

@interface ACDMemberCollectionCell()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *deleteImageView;
@property (nonatomic, strong) UILabel *nickNameLabel;

@end

@implementation ACDMemberCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
        [self placeSubViews];
    }
    return self;
}

- (void)prepare {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.deleteImageView];
    [self.contentView addSubview:self.nickNameLabel];
}

- (void)placeSubViews {
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kAgroaPadding);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(kIconHeight);
    }];
    
    [self.deleteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView).offset(-kAgroaPadding * 0.5);
        make.right.equalTo(self.avatarImageView).offset(5.0);
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(kAgroaPadding * 0.5);
        make.centerX.equalTo(self.avatarImageView);
        make.left.right.equalTo(self.avatarImageView);

    }];

}



- (void)setModel:(AgoraUserModel *)model {

    _model = model;
    if (!_model) {
        _nickNameLabel.text = @"";
        _avatarImageView.image = [UIImage imageNamed:@"Button_Add Member.png"];
        return;
    }
    _nickNameLabel.text = _model.nickname;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [_avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    else {
        _avatarImageView.image = _model.defaultAvatarImage;
    }
}

+ (NSString *)reuseIdentifier {
    return  NSStringFromClass([self class]);
}

#pragma mark getter and setter
- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = kIconHeight * 0.5;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UIImageView *)deleteImageView {
    if (_deleteImageView == nil) {
        _deleteImageView = [[UIImageView alloc] init];
        _deleteImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_deleteImageView setImage:ImageWithName(@"member_delete")];
    }
    return _deleteImageView;
}

- (UILabel *)nickNameLabel {
    if (_nickNameLabel == nil) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont fontWithName:@"PingFang SC" size:12.0f];
        _nickNameLabel.textColor = COLOR_HEX(0x0D0D0D);
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _nickNameLabel;
}


@end

#undef kIconHeight
