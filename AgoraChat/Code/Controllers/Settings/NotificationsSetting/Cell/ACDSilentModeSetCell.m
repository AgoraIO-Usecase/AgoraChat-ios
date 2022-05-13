//
//  ACDSilentModeSetCell.m
//  AgoraChat
//
//  Created by hxq on 2022/3/23.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDSilentModeSetCell.h"

@implementation ACDSilentModeSetCell

- (void)prepare {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectImageView];
}

- (void)placeSubViews {
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kAgroaPadding * 1.6);
        make.right.equalTo(self.selectImageView.mas_left);
    }];
    
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
    }];
    
}


#pragma mark getter and setter
- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        _selectImageView = [[UIImageView alloc] init];
        _selectImageView.userInteractionEnabled = YES;
        [_selectImageView setImage:ImageWithName(@"mute_unselect")];
        _selectImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _selectImageView;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.selectImageView setImage:ImageWithName(@"mute_select")];
    }else{
        [self.selectImageView setImage:ImageWithName(@"mute_unselect")];
    }
    if (selected && self.selectBlock) {
        self.selectBlock(self.tag);
    }
    
}




@end
