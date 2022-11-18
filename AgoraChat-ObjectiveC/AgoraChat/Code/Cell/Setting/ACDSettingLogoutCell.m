//
//  ACDSettingLogoutCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSettingLogoutCell.h"

@implementation ACDSettingLogoutCell

- (void)prepare {
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.nameLabel];
}


- (void)placeSubViews {
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0);
        make.right.equalTo(self.contentView).offset(-16.0);
    }];
}

@end
