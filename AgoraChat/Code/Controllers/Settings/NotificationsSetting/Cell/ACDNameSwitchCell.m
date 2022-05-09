//
//  ACDNameSwitchCell.m
//  AgoraChat
//
//  Created by hxq on 2022/3/25.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDNameSwitchCell.h"

@implementation ACDNameSwitchCell

- (void)prepare {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.aSwitch];

}

- (void)placeSubViews {

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kAgroaPadding * 1.6);
        make.right.equalTo(self.aSwitch.mas_left);
    }];
    
    [self.aSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
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
