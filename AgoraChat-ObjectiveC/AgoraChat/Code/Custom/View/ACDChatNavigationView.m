//
//  ACDChatNavigationView.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDChatNavigationView.h"

#define kRedPointViewHeight 8.0f
#define kChatImageViewHeight  34.0f

@interface ACDChatNavigationView () {
    BOOL _isNormal;
}
@property (nonatomic, strong) UIImageView* backImageView;
@property (nonatomic, strong) UIView* redPointView;
@property (nonatomic, strong) UIButton* leftButton;
@property (nonatomic, strong) UIButton* rightButton;
@property (nonatomic, strong) UIButton* rightButton2;
@property (nonatomic, strong) UIButton* rightButton3;
@end

@implementation ACDChatNavigationView

- (void)prepare {
    [self addSubview:self.leftButton];
    [self addSubview:self.redPointView];
    [self addSubview:self.chatButton];
    [self addSubview:self.leftLabel];
    [self addSubview:self.rightButton];
    [self addSubview:self.rightButton2];
    [self addSubview:self.rightButton3];
    [self addSubview:self.presenceLabel];
}


- (void)placeSubViews {
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kAgroaPadding * 2.0);
        make.left.equalTo(self).offset(kAgroaPadding);
        make.width.equalTo(@40.0);
        make.bottom.equalTo(self).offset(-5.0);

    }];
    
    [self.redPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftButton).offset(-kAgroaPadding);
        make.centerX.equalTo(self.leftButton.mas_right).offset(-kAgroaPadding);
        make.size.equalTo(@kRedPointViewHeight);
    }];

    [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftButton);
        make.left.equalTo(self.leftButton.mas_right).offset(kAgroaPadding*0.5);
        make.width.equalTo(@30.0);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftButton);
        make.left.equalTo(self.chatButton.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.rightButton3.mas_left);
    }];
    
    [self.presenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftLabel.mas_bottom);
        make.left.equalTo(self.leftLabel);
        make.width.lessThanOrEqualTo(@85);
    }];
        
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.lessThanOrEqualTo(@50);
        make.centerY.equalTo(self.leftButton);
        make.right.equalTo(self).offset(-kAgroaPadding);
    }];
    
    [self.rightButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.lessThanOrEqualTo(@50);
        make.centerY.equalTo(self.leftButton);
        make.right.equalTo(self.rightButton.mas_left).offset(-5);
    }];
    
    [self.rightButton3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.lessThanOrEqualTo(@50);
        make.centerY.equalTo(self.leftButton);
        make.right.equalTo(self.rightButton2.mas_left).offset(-5);
    }];
}

#pragma mark action
- (void)rightButtonAction {
    if (self.rightButtonBlock) {
        self.rightButtonBlock();
    }
}

- (void)rightButtonAction2 {
    if (self.rightButtonBlock2) {
        self.rightButtonBlock2();
    }
}

- (void)rightButtonAction3 {
    if (self.rightButtonBlock3) {
        self.rightButtonBlock3();
    }
}

- (void)leftButtonAction {
    if (self.leftButtonBlock) {
        self.leftButtonBlock();
    }
}

- (void)chatButtonAction {
    if (self.chatButtonBlock) {
        self.chatButtonBlock();
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

- (UIView *)redPointView {
    if (_redPointView == nil) {
        _redPointView = UIView.new;
        _redPointView.backgroundColor = TextLabelPinkColor;
        _redPointView.layer.cornerRadius = kRedPointViewHeight * 0.5;
        _redPointView.hidden = YES;
    }
    return _redPointView;
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

- (UILabel *)presenceLabel {
    if (_presenceLabel == nil) {
        _presenceLabel = UILabel.new;
        _presenceLabel.textColor = [UIColor grayColor];
        _presenceLabel.textAlignment = NSTextAlignmentLeft;
        _presenceLabel.font = BFont(10.0f);

    }
    return _presenceLabel;
}

- (UIButton *)chatButton {
    if (_chatButton == nil) {
        _chatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
        _chatButton.contentMode = UIViewContentModeScaleAspectFill;
        [_chatButton addTarget:self action:@selector(chatButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_chatButton addSubview:self.chatImageView];
        [self.chatImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_chatButton);
            make.centerY.equalTo(_chatButton);
            make.size.equalTo(@kChatImageViewHeight);
        }];
    }
    return _chatButton;
}

- (UIButton *)rightButton {
    if (_rightButton == nil) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _rightButton.contentMode = UIViewContentModeScaleAspectFill;
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.hidden = YES;
    }
    return _rightButton;
}

- (UIButton *)rightButton2 {
    if (_rightButton2 == nil) {
        _rightButton2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _rightButton2.contentMode = UIViewContentModeScaleAspectFill;
        [_rightButton2 addTarget:self action:@selector(rightButtonAction2) forControlEvents:UIControlEventTouchUpInside];
        _rightButton2.hidden = YES;
    }
    return _rightButton2;
}

- (UIButton *)rightButton3 {
    if (_rightButton3 == nil) {
        _rightButton3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        _rightButton3.contentMode = UIViewContentModeScaleAspectFill;
        [_rightButton3 addTarget:self action:@selector(rightButtonAction3) forControlEvents:UIControlEventTouchUpInside];
        _rightButton3.hidden = YES;
    }
    return _rightButton3;
}

- (AgoraChatAvatarView *)chatImageView {
    if (_chatImageView == nil) {
        _chatImageView = AgoraChatAvatarView.new;
        _chatImageView.layer.cornerRadius = kChatImageViewHeight *0.5;
        _chatImageView.clipsToBounds = YES;
        
        UIImage *image = [UIImage imageWithColor:COLOR_HEX(0xFAA69B) size:CGSizeMake(kChatImageViewHeight, kChatImageViewHeight)];
        [_chatImageView setImage:image];
    }
    return _chatImageView;
}

- (void)rightItemImageWithType:(AgoraChatConversationType)type {
    if (type == AgoraChatConversationTypeGroupChat) {
        _rightButton.hidden = NO;
        [_rightButton setImage:ImageWithName(@"groupThread") forState:UIControlStateNormal];
    } else {
        [_rightButton setImage:ImageWithName(@"nav_chat_right_bar") forState:UIControlStateNormal];
    }
}

@end

#undef kRedPointViewHeight
#undef kChatImageViewHeight
