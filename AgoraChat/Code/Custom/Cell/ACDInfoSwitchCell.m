//
//  ACDGroupInfoSwitchCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/28.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDInfoSwitchCell.h"

@implementation ACDInfoSwitchCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.aSwitch];

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
        make.right.equalTo(self.aSwitch.mas_left).offset(-kAgroaPadding);
    }];
    
    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];

}

- (void)switchAction {
    BOOL isOn = self.aSwitch.isOn;
    if (self.switchActionBlock) {
        self.switchActionBlock(isOn);
    }
}

#pragma mark getter and setter
- (UISwitch *)aSwitch {
    if (_aSwitch == nil) {
        _aSwitch = [[UISwitch alloc] init];
        [_aSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
        _aSwitch.onTintColor = ButtonEnableBlueColor;
    }
    return _aSwitch;
}

@end
