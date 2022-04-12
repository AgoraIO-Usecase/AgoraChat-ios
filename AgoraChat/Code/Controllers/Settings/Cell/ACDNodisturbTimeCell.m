//
//  ACDNodisturbTimeCell.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDNodisturbTimeCell.h"

@implementation ACDNodisturbTimeCell

- (void)prepare {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.hintLabel];
    [self.contentView addSubview:self.timeButton];

}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kAgroaPadding * 1.6);
    }];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.equalTo(self.timeButton.mas_left).offset(-kAgroaPadding);
    }];
    
    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.width.equalTo(@60.0);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];

}

- (void)timeButtonAction {
    if (self.timeButtonBlock) {
        self.timeButtonBlock();
    }
}


#pragma mark getter and setter
- (UILabel *)hintLabel {
    if (_hintLabel == nil) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.font = Font(@"PingFang SC", 16.0);
        _hintLabel.textColor = TextLabelGrayColor;
        _hintLabel.textAlignment = NSTextAlignmentRight;
        _hintLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _hintLabel.text = @"Set Hour Only";
    }
    return _hintLabel;
}


- (UIButton *)timeButton
{
    if (!_timeButton) {
        _timeButton = [[UIButton alloc]init];
        [_timeButton setTitle:@"00:00" forState:UIControlStateNormal];
        [_timeButton setTitleColor:[UIColor colorWithHexString:@"#154DFE"] forState:UIControlStateNormal];
        _timeButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
        [_timeButton addTarget:self action:@selector(timeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _timeButton.backgroundColor = COLOR_HEX(0xD8D8D8);
        _timeButton.layer.cornerRadius = 8.0;
    }
    return _timeButton;
}

@end
