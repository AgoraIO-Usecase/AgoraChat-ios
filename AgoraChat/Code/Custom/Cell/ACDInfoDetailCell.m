//
//  ACDGroupInfoMembersCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/28.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDInfoDetailCell.h"

@implementation ACDInfoDetailCell

- (void)prepare {
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];

}

- (void)placeSubViews {
    [self generateRandomAvatar];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kAvatarHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.detailLabel.mas_left);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];
    
}

- (void)generateRandomAvatar {
    self.iconImageView.layer.cornerRadius = kAvatarHeight * 0.5;
    UIColor *avatarColor = [UIColor avatarRandomColor];
    UIImage *image = [UIImage imageWithColor:avatarColor size:CGSizeMake(kAvatarHeight, kAvatarHeight)];
    [self.iconImageView setImage:image];
}

#pragma mark getter and setter
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
