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
@property (nonatomic, strong)  UIButton *selectButton;

@end

@implementation AgoraGroupMemberCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _isEditing = NO;
    _isSelected = NO;
    _isGroupOwner = NO;
}

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectButton];
}


- (void)placeSubViews {
    self.iconImageView.layer.cornerRadius = kContactAvatarHeight * 0.5;
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.selectButton.mas_right).offset(10.0f);
        make.size.mas_equalTo(kContactAvatarHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.mas_right).offset(16.0f);
    }];
}



#pragma mark action

- (void)selectMemberAction:(UIButton *)sender {
    
    _selectButton.selected = !sender.isSelected;
    
    if (_delegate) {
        if (_selectButton.selected && [_delegate respondsToSelector:@selector(addSelectOccupants:)]) {
            [_delegate addSelectOccupants:@[_model]];
        }
        else if ([_delegate respondsToSelector:@selector(removeSelectOccupants:)]) {
            [_delegate removeSelectOccupants:@[_model]];
        }
    }
}

#pragma mark getter and setter
- (UIButton *)selectButton {
    if (_selectButton == nil) {
        _selectButton = [[UIButton alloc] init];
        [_selectButton addTarget:self action:@selector(selectMemberAction:) forControlEvents:UIControlEventTouchUpInside];
        [_selectButton setImage:ImageWithName(@"member_normal") forState:UIControlStateNormal];
        [_selectButton setImage:ImageWithName(@"member_selected") forState:UIControlStateSelected];

    }
    return _selectButton;
}

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
        _selectButton.hidden = YES;
        return;
    }
    _selectButton.hidden = !_isEditing;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    _selectButton.selected = _isSelected;
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
        
}

@end
