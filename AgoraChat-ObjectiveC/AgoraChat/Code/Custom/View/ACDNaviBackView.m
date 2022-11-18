//
//  ACDNaviBackView.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/12.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDNaviBackView.h"

@interface ACDNaviBackView ()
@property (nonatomic, strong) UIImageView* leftImageView;
@property (nonatomic, strong) UIButton* leftButton;

@end

@implementation ACDNaviBackView


- (void)prepare {
    self.backgroundColor = UIColor.whiteColor;
    [self.leftButton addSubview:self.leftImageView];
    [self.leftButton addSubview:self.leftLabel];
    [self addSubview:self.leftButton];
}


- (void)placeSubViews {
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kAgroaPadding * 4.4);
        make.left.equalTo(self).offset(kAgroaPadding);
        make.width.equalTo(@100.0);
        make.bottom.equalTo(self).offset(-5.0);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftButton);
        make.left.equalTo(self.leftButton);
        make.bottom.equalTo(self.leftButton);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftImageView);
        make.left.equalTo(self.leftImageView.mas_right).offset(kAgroaPadding);
        make.bottom.equalTo(self).offset(-kAgroaPadding);
    }];
    
    
}

#pragma mark action
- (void)leftButtonAction {
    if (self.leftButtonBlock) {
        self.leftButtonBlock();
    }
}

#pragma mark getter and setter
- (UIButton *)leftButton {
    if (_leftButton == nil) {
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
        [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}


- (UIImageView *)leftImageView {
    if (_leftImageView == nil) {
        _leftImageView = [[UIImageView alloc] init];
        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
        _leftImageView.image = ImageWithName(@"black_goBack");
    }
    return _leftImageView;
}

- (UILabel *)leftLabel {
    if (_leftLabel == nil) {
        _leftLabel = UILabel.new;
        _leftLabel.textColor = TextLabelBlackColor;
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.font = BFont(18.0f);
        _leftLabel.text = @"leftLabel";
    }
    return _leftLabel;
}

@end

