//
//  ACDNormalNavigationView.m
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/7.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDNormalNavigationView.h"

@implementation ACDNormalNavigationView


- (void)prepare {
    [self addSubview:self.leftLabel];
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
}

- (void)placeSubViews {
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kAgroaPadding * 2.0);
        make.left.equalTo(self).offset(kAgroaPadding);
        make.width.equalTo(@40.0);
        make.bottom.equalTo(self).offset(-5.0);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftButton);
        make.left.equalTo(self.leftButton.mas_right).offset(kAgroaPadding);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kAgroaPadding * 2.0);
        make.right.equalTo(self.mas_right).offset(-kNavigationRightPadding);
        make.bottom.equalTo(self).offset(-5.0);
    }];
}

#pragma mark action


- (void)leftButtonAction {
    if (self.leftButtonBlock) {
        self.leftButtonBlock();
    }
}

- (void)rightButtonAction {
    if (self.rightButtonBlock) {
        self.rightButtonBlock();
    }
}

#pragma mark getter and setter
- (UIButton *)leftButton {
    if (_leftButton == nil) {
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
        _leftButton.contentMode = UIViewContentModeScaleAspectFill;
        [_leftButton setImage:ImageWithName(@"black_goBack") forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}


- (UILabel *)leftLabel {
    if (_leftLabel == nil) {
        _leftLabel = UILabel.new;
        _leftLabel.textColor = TextLabelBlackColor;
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.font = BFont(14.0f);
        _leftLabel.text = @"leftLabel";

    }
    return _leftLabel;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
        _rightButton.contentMode = UIViewContentModeScaleAspectFill;
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

@end
