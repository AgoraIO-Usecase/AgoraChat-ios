//
//  ACDImageTitleContentCell.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/17.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDImageTitleContentCell.h"

@implementation ACDImageTitleContentCell

- (void)prepare {
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
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
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(kAgroaPadding * 0.5);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
        make.bottom.equalTo(self.contentView).offset(-kAgroaPadding * 0.5);
    }];
    
}

- (void)generateRandomAvatar {
    self.iconImageView.layer.cornerRadius = kAvatarHeight * 0.5;
    UIColor *avatarColor = [UIColor avatarRandomColor];
    UIImage *image = [UIImage imageWithColor:avatarColor size:CGSizeMake(kAvatarHeight, kAvatarHeight)];
    [self.iconImageView setImage:image];
}

#pragma mark getter and setter
- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = NFont(16.0f);
        _contentLabel.textColor = TextLabelGrayColor;
        _contentLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.numberOfLines = 2;
    }
    return _contentLabel;
}

@end
