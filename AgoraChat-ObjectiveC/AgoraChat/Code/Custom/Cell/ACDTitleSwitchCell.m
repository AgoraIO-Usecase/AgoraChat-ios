//
//  ACDTitleSwitchCell.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/9.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDTitleSwitchCell.h"

@implementation ACDTitleSwitchCell

- (void)prepare {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.aSwitch];
}

- (void)placeSubViews {
    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding);
        make.width.equalTo(@50);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.equalTo(self.contentView).offset(kAgroaPadding);
        make.right.lessThanOrEqualTo(self.aSwitch.mas_left).offset(-kAgroaPadding);
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
