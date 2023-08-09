//
//  ACDGroupNewCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/25.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupCell.h"
#import "AgoraGroupModel.h"

#define KJOINBUTTON_IMAGE   [UIImage imageNamed:@"Button_Join.png"]
#define KJOINBUTTON_TITLE   NSLocalizedString(@"group.requested", @"Requested")

@interface ACDGroupCell()

@property (nonatomic, strong)  UILabel *numberCountLabel;

@end

@implementation ACDGroupCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
//    [self.contentView addSubview:self.numberCountLabel];
    [self.contentView addSubview:self.sender];
    
}

- (void)placeSubViews {
    self.iconImageView.clipsToBounds = NO;
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kContactAvatarHeight);
    }];
    

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding * 1.0);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6-66);
        
    }];
    
    
    [self.sender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-16);
        make.size.mas_equalTo(CGSizeMake(66, 28));
    }];
    _sender.layer.cornerRadius = 14;
    _sender.clipsToBounds = YES;
//    [self.numberCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.iconImageView);
//        make.width.lessThanOrEqualTo(@30.0);
//        make.right.lessThanOrEqualTo(self.contentView).offset(16.0);
//    }];
    
}


- (void)setModel:(AgoraGroupModel *)model {
    if (_model != model) {
        _model = model;
    }
    self.nameLabel.text = _model.subject;
    self.numberCountLabel.text = [NSString stringWithFormat:@"(%lu)",(unsigned long)_model.group.occupants.count];
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [self.iconImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    else {
        self.iconImageView.image = _model.defaultAvatarImage;
    }
}


#pragma mark getter and setter
- (UILabel *)numberCountLabel {
    if (_numberCountLabel == nil) {
        _numberCountLabel = [[UILabel alloc] init];
        _numberCountLabel.font = [UIFont systemFontOfSize:14.0f];
        _numberCountLabel.numberOfLines = 1;
        _numberCountLabel.textColor = COLOR_HEX(0x999999);
        _numberCountLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _numberCountLabel;
}

- (UIButton *)sender {
    if (_sender == nil) {
        _sender = [[UIButton alloc] init];
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
