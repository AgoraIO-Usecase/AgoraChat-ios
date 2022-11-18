//
//  AgoraGroupEnterCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDGroupEnterCell.h"
@implementation ACDGroupEnterCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
}

- (void)placeSubViews {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kAgroaPadding * 0.5);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.width.equalTo(@40.0f);
        make.bottom.equalTo(self.contentView).offset(-kAgroaPadding * 0.5);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kAgroaPadding * 1.5);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.5);
    }];
}

@end
