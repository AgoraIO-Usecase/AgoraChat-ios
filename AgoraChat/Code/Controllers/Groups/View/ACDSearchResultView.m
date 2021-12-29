//
//  ACDSearchResultView.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSearchResultView.h"

@interface ACDSearchResultView ()
@property (nonatomic, strong) UIButton *addButton;

@end

@implementation ACDSearchResultView

- (void)prepare {
    [self addSubview:self.nameLabel];
    [self addSubview:self.addButton];
}

- (void)placeSubViews {
        
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.addButton);
        make.left.equalTo(self.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.addButton.mas_left).offset(-kAgroaPadding * 1.5);
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-kAgroaPadding * 1.6);
        make.width.equalTo(@20.0);
    }];
    
}

- (void)addButtonAction {
    self.addButton.selected = !self.addButton.selected;
    if (self.addGroupBlock) {
        self.addGroupBlock();
    }
}

#pragma mark getter and setter
- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
//        PingFangSC-Semibold
        _nameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
        _nameLabel.textColor = COLOR_HEX(0x0D0D0D);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    }
    return _nameLabel;
}


- (UIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [[UIButton alloc] init];
        _addButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_addButton setTitleColor:ButtonEnableBlueColor forState:UIControlStateNormal];
        [_addButton setTitleColor:ButtonDisableGrayColor forState:UIControlStateSelected];
        [_addButton setTitle:@"Apply" forState:UIControlStateNormal];
        [_addButton setTitle:@"Applied" forState:UIControlStateSelected];
        
        [_addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

@end

