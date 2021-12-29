//
//  ACDContactCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContactCell.h"
#import "AgoraUserModel.h"

#define kIconHeight 40.0f

@implementation ACDContactCell

- (void)prepare {
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
}

- (void)placeSubViews {
    self.iconImageView.layer.cornerRadius = kIconHeight * 0.5;
   

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kIconHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.5);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];

}

#pragma mark setter
- (void)setModel:(AgoraUserModel *)model {
    if (_model != model) {
        _model = model;
    }
    self.nameLabel.text = _model.nickname;
    self.iconImageView.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_model.avatarURLPath] placeholderImage:_model.defaultAvatarImage];
    }
    else {
        self.iconImageView.image = _model.defaultAvatarImage;
    }
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = NFont(16.0f);
        _detailLabel.textColor = TextLabelGrayColor;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}

@end
#undef kIconHeight

