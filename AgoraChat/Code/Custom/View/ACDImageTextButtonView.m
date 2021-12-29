//
//  ACDImageTextButtonView.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDImageTextButtonView.h"

@interface ACDImageTextButtonView ()

@end

@implementation ACDImageTextButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _iconImageView = UIImageView.new;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.userInteractionEnabled = NO;
        
        _titleLabel = UILabel.new;
        _titleLabel.textColor = TextLabelBlackColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = NFont(12.0f);

        _tapBtn  = UIButton.new;
        
        [self addSubview:_tapBtn];
        [_tapBtn addSubview:_iconImageView];
        [_tapBtn addSubview:_titleLabel];

        [_tapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_tapBtn.mas_top).offset(5.0);
            make.centerX.equalTo(_tapBtn);
            make.size.mas_equalTo(40.0);
        }];

        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImageView.mas_bottom).offset(5.0);
            make.centerX.equalTo(_tapBtn);
            make.height.equalTo(@12.0f);
            make.bottom.equalTo(_tapBtn.mas_bottom).offset(-5.0);
        }];
    }
    return self;
}

@end
