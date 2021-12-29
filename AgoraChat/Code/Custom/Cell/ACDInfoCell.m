//
//  ACDGroupInfoCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/28.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDInfoCell.h"


@implementation ACDInfoCell

- (void)prepare {
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.customBtn];
}

- (void)placeSubViews {
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kAgroaPadding * 0.5);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kAvatarHeight);
        make.bottom.equalTo(self.contentView).offset(-kAgroaPadding * 0.5);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.5);
    }];
    
    [self.customBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.5);
        make.width.equalTo(@22);
        make.height.equalTo(@(kAgroaPadding * 3));
    }];
}


- (UIButton *)customBtn
{
    if (!_customBtn) {
        _customBtn = [[UIButton alloc]init];
        _customBtn.titleLabel.text = @"Add";
        _customBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
        [_customBtn.titleLabel setTextColor:[UIColor colorWithHexString:@"#154DFE"]];
        [_customBtn addTarget:self action:@selector(customAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customBtn;
}

- (void)customAction
{
    if (self.customBtnSelect) {
        self.customBtnSelect();
    }
}

@end
