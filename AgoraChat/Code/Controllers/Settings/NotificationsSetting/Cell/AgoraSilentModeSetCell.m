//
//  AgoraSilentModeSetCell.m
//  AgoraChat
//
//  Created by hxq on 2022/3/23.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraSilentModeSetCell.h"

@implementation AgoraSilentModeSetCell

- (void)prepare {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectButton];
}

- (void)placeSubViews {
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kAgroaPadding * 1.6);
        make.right.equalTo(self.selectButton.mas_left);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];
    
}


#pragma mark getter and setter
- (UIButton *)selectButton {
    if (_selectButton == nil) {
        _selectButton = [[UIButton alloc] init];
        [_selectButton setImage:ImageWithName(@"mute_unselect") forState:UIControlStateNormal];
        [_selectButton setImage:ImageWithName(@"mute_select") forState:UIControlStateSelected];
        _selectButton.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _selectButton;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   
    [super setSelected:selected animated:animated];
    self.selectButton.selected = selected;
    if (selected && self.selectBlock) {
        self.selectBlock(self.tag);
    }
    
}



@end
