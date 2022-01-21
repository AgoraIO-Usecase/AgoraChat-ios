//
//  ACDGroupNewCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/25.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupNewCell.h"
#import "AgoraGroupCell.h"
#import "AgoraGroupModel.h"

#define KJOINBUTTON_IMAGE   [UIImage imageNamed:@"Button_Join.png"]
#define KJOINBUTTON_TITLE   NSLocalizedString(@"group.requested", @"Requested")

@interface ACDGroupNewCell()

@property (nonatomic, strong)  UILabel *numberCountLabel;

@end

@implementation ACDGroupNewCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
//    [self.contentView addSubview:self.numberCountLabel];
    
}

- (void)placeSubViews {
    self.iconImageView.clipsToBounds = NO;
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kContactAvatarHeight);
    }];
    

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding * 1.0);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
        
    }];
    
//    [self.numberCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.iconImageView);
//        make.width.lessThanOrEqualTo(@30.0);
//        make.right.lessThanOrEqualTo(self.contentView).offset(16.0);
//    }];
    
}


- (void)setModel:(AgoraGroupModel *)model {
    if (_model != model) {
        _model = model;
    }
    self.nameLabel.text = _model.subject;
    self.numberCountLabel.text = [NSString stringWithFormat:@"(%lu)",(unsigned long)_model.group.occupants.count];
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [self.iconImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    else {
        self.iconImageView.image = _model.defaultAvatarImage;
    }
}


#pragma mark getter and setter
- (UILabel *)numberCountLabel {
    if (_numberCountLabel == nil) {
        _numberCountLabel = [[UILabel alloc] init];
        _numberCountLabel.font = [UIFont systemFontOfSize:14.0f];
        _numberCountLabel.numberOfLines = 1;
        _numberCountLabel.textColor = COLOR_HEX(0x999999);
        _numberCountLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _numberCountLabel;
}


@end
