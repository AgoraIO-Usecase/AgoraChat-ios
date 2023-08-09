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
//    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.sender];
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
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.5-66);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.nameLabel);
    }];
    
    [self.sender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-16);
        make.size.mas_equalTo(CGSizeMake(66, 28));
    }];
    _sender.layer.cornerRadius = 14;
    _sender.clipsToBounds = YES;

}

#pragma mark setter
- (void)setModel:(AgoraUserModel *)model {
    if (_model != model) {
        _model = model;
    }

    self.nameLabel.text = _model.nickname.length ? model.nickname:model.hyphenateId;
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
        _detailLabel.font = NFont(12.0f);
        _detailLabel.textColor = TextLabelGrayColor;
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}

- (UIButton *)sender {
    if (_sender == nil) {
        _sender = [[UIButton alloc] init];
        _sender.hidden = YES;
        _sender.backgroundColor = COLOR_HEX(0xF2F2F2);
        [_sender setTitleColor:COLOR_HEX(0x1A1A1A) forState:UIControlStateNormal];
        [_sender setTitleColor:COLOR_HEX(0x999999) forState:UIControlStateDisabled];
        [_sender setTitle:@"Send" forState:UIControlStateNormal];
        [_sender setTitle:@"Sent" forState:UIControlStateDisabled];
        [_sender addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sender;
}

- (void)sendAction {
    self.sender.enabled = NO;
    if (self.tapCellBlock) {
        self.tapCellBlock();
    }
}

@end
#undef kIconHeight

