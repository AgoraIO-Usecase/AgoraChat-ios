//
//  ACDJoinGroupCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDJoinGroupCell.h"

@interface ACDJoinGroupCell ()
@property (nonatomic, strong) UIButton *joinButton;

@end

@implementation ACDJoinGroupCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.joinButton];
}

- (void)placeSubViews {
    self.accessoryType = UITableViewCellAccessoryNone;
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kAgroaPadding * 0.5);
        make.left.equalTo(self.contentView).offset(kAgroaPadding * 1.6);
        make.width.equalTo(@32.0f);
        make.bottom.equalTo(self.contentView).offset(-kAgroaPadding * 0.5);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.5);
    }];
    
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconImageView);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];
    
}

- (void)joinButtonAction {
    self.joinButton.selected = !self.joinButton.selected;
    if (self.joinGroupBlock) {
        self.joinGroupBlock();
    }
}

#pragma mark getter and setter
- (UIButton *)joinButton {
    if (_joinButton == nil) {
        _joinButton = [[UIButton alloc] init];
        _joinButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_joinButton setTitleColor:ButtonEnableBlueColor forState:UIControlStateNormal];
        [_joinButton setTitleColor:ButtonDisableGrayColor forState:UIControlStateSelected];
        [_joinButton setTitle:@"Join" forState:UIControlStateNormal];
        [_joinButton setTitle:@"Joined" forState:UIControlStateSelected];
        
        [_joinButton addTarget:self action:@selector(joinButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _joinButton;
}

@end
