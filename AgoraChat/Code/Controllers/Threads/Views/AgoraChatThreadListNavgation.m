//
//  AgoraChatThreadListNavgation.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraChatThreadListNavgation.h"
#import "EaseDefines.h"
@interface AgoraChatThreadListNavgation ()

@property (nonatomic, strong) UIButton *back;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic) UIButton *rightButton;

@end

@implementation AgoraChatThreadListNavgation

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self addSubview:self.back];
        [self addSubview:self.rightButton];
        [self addSubview:self.titleLabel];
        [self addSubview:self.detailLabel];
    }
    return self;
}

- (UIButton *)rightButton {
    if (_rightButton == nil) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(EMScreenWidth - 36, EaseVIEWBOTTOMMARGIN > 0 ? 49:29, 28, 28)];
        [_rightButton setImage:ImageWithName(@"thread_more") forState:UIControlStateNormal];
        _rightButton.contentMode = UIViewContentModeScaleAspectFill;
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.hidden = YES;
    }
    return _rightButton;
}

- (UIButton *)back {
    if (!_back) {
        _back = [[UIButton alloc] initWithFrame:CGRectMake(12, kIsBangsScreen ? 52:29, 28, 28)];
        _back.contentMode = UIViewContentModeScaleAspectFill;
        [_back setImage:ImageWithName(@"black_goBack") forState:UIControlStateNormal];
        [_back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _back;
}

- (void)backAction {
    if (self.backBlock) {
        self.backBlock();
    }
}

- (void)rightButtonAction {
    if (self.moreBlock) {
        self.moreBlock();
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.back.frame)+8, kIsBangsScreen ? 43:20, EMScreenWidth - 56 - CGRectGetMaxX(self.back.frame)-8, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#0D0D0D"];
        _titleLabel.text = @"All Threads";
    }
    return _titleLabel;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
    if (!self.detail) {
        self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.back.center.y);
    }
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.back.frame)+8, CGRectGetMaxY(self.titleLabel.frame)+3, EMScreenWidth - 56 - CGRectGetMaxX(self.back.frame)-8, 15)];
        _detailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        _detailLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    }
    return _detailLabel;
}

- (void)setDetail:(NSString *)detail {
    _detail = detail;
    self.detailLabel.text = detail;
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.back.frame)+8, kIsBangsScreen ? 43:20, EMScreenWidth - 56 - CGRectGetMaxX(self.back.frame)-8, 20);
}

- (void)hiddenMore:(BOOL)hidden {
    self.rightButton.hidden = hidden;
}

@end
