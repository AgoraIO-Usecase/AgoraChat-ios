//
//  ACDSearchJoinCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSearchJoinCell.h"

@interface ACDSearchJoinCell ()
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UILabel *addLabel;

@end

@implementation ACDSearchJoinCell

- (void)prepare {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.addButton];
}

- (void)placeSubViews {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kAgroaPadding * 1.6);
        make.right.equalTo(self.addButton.mas_left).offset(-kAgroaPadding * 1.6);
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding * 1.6);
//        make.width.equalTo(@100.0);
        make.height.equalTo(@30.0f);
    }];
}


- (void)addButtonAction {
    if (self.addGroupBlock && !self.addButton.selected) {
        self.addGroupBlock();
    }
    self.addButton.selected = YES;

}

- (void)updateSearchName:(NSString *)searchName {
    self.nameLabel.text = searchName;
    self.addButton.selected = NO;
}

#pragma mark getter and setter
- (UIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [[UIButton alloc] init];
        _addButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _addButton.titleLabel.textAlignment = NSTextAlignmentRight;
        
        [_addButton setTitleColor:ButtonEnableBlueColor forState:UIControlStateNormal];
        [_addButton setTitleColor:ButtonDisableGrayColor forState:UIControlStateSelected];
        
        [_addButton setTitle:@"Apply" forState:UIControlStateNormal];
        [_addButton setTitle:@"Applied" forState:UIControlStateSelected];
        
        [_addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (UILabel *)addLabel {
    if (_addLabel == nil) {
        _addLabel = [[UILabel alloc] init];
        _addLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
        _addLabel.textColor = ButtonEnableBlueColor;
        _addLabel.textAlignment = NSTextAlignmentRight;
        _addLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _addLabel.text = @"Apply";
    }
    return _addLabel;
}

- (void)setIsSearchGroup:(BOOL)isSearchGroup {
    if (isSearchGroup) {
        [_addButton setTitle:@"Apply" forState:UIControlStateNormal];
        [_addButton setTitle:@"Applied" forState:UIControlStateSelected];
    }else {
        [_addButton setTitle:@"Add" forState:UIControlStateNormal];
        [_addButton setTitle:@"Added" forState:UIControlStateSelected];
    }
}

@end

