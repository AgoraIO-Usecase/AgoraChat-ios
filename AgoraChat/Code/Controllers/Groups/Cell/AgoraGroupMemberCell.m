//
//  AgoraGroupMemberNewCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/25.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraGroupMemberCell.h"
#import "AgoraUserModel.h"

@interface AgoraGroupMemberCell()
@property (nonatomic, strong)  UILabel *identityLabel;
@property (nonatomic, strong)  UIImageView *selectImageView;

@end

@implementation AgoraGroupMemberCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.accessoryType = UITableViewCellAccessoryNone;
    
    _isEditing = NO;
    _isSelected = NO;
    _isGroupOwner = NO;
}

- (void)prepare {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectImageView];
}


- (void)placeSubViews {
    self.iconImageView.layer.cornerRadius = kContactAvatarHeight * 0.5;
    
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.selectImageView.mas_right).offset(10.0f);
        make.size.mas_equalTo(kContactAvatarHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(16.0f);
    }];
}



#pragma mark getter and setter
- (void)setIsGroupOwner:(BOOL)isGroupOwner {
    _isGroupOwner = isGroupOwner;
    if (_isGroupOwner) {
        _identityLabel.hidden = NO;
    }
    else {
        _identityLabel.hidden = YES;
    }
}

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    if (_isGroupOwner) {
//        _selectButton.hidden = YES;
        return;
    }
//    _selectButton.hidden = !_isEditing;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        [self.selectImageView setImage:ImageWithName(@"member_selected")];
    }else {
        [self.selectImageView setImage:ImageWithName(@"member_normal")];
    }

}

- (void)setModel:(AgoraUserModel *)model {
    _model = model;
    self.nameLabel.text = _model.nickname;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [self.iconImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    else {
        self.iconImageView.image = _model.defaultAvatarImage;
    }
    
//    if (_model.selected) {
//        [self.selectImageView setImage:ImageWithName(@"member_selected")];
//    }else {
//        [self.selectImageView setImage:ImageWithName(@"member_normal")];
//    }
        
}

#pragma mark gettter and setter
- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        _selectImageView = UIImageView.new;
        [self.selectImageView setImage:ImageWithName(@"member_normal")];
    }
    return _selectImageView;
}

@end
