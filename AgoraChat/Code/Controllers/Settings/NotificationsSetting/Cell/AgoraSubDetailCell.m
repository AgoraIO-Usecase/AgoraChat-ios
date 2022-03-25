//
//  AgoraSubDetailCell.m
//  AgoraChat
//
//  Created by hxq on 2022/3/22.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraSubDetailCell.h"

@implementation AgoraSubDetailCell

- (CGFloat)height {
    if (self.showSubDetailLabel) {
        return 70.0f;
    }else{
        return 54.0f;
    }
}

- (void)prepare {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.subDetailLabel];
    
}


- (void)placeSubViews {
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView).offset(self.showSubDetailLabel?-16:0);
        make.left.equalTo(self.contentView).offset(kAgroaPadding * 1.6);
        make.right.equalTo(self.detailLabel.mas_left);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView).offset(self.showSubDetailLabel?-16:0);;
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];
    
    [self.subDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(16);
    }];
    
   
}

#pragma mark getter and setter
- (UILabel *)subDetailLabel {
    if (_subDetailLabel == nil) {
        _subDetailLabel = [[UILabel alloc] init];
        _subDetailLabel.font = Font(@"PingFang SC", 12.0);
        _subDetailLabel.textColor = TextLabelGrayColor;
        _subDetailLabel.textAlignment = NSTextAlignmentLeft;
        _subDetailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _subDetailLabel;
}

- (void)setShowSubDetailLabel:(BOOL)showSubDetailLabel
{
    _showSubDetailLabel = showSubDetailLabel;
    [self height];
}
@end
