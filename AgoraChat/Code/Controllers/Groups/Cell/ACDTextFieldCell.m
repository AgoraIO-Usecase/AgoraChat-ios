//
//  ACDTextFieldCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDTextFieldCell.h"

@interface ACDTextFieldCell()
@end

@implementation ACDTextFieldCell

- (CGFloat)height {
    return 30.0f;
}

- (void)prepare {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.bottomLine.backgroundColor = COLOR_HEX(0xE0E0E0);
    [self.contentView addSubview:self.titleTextField];
    [self.contentView addSubview:self.bottomLine];
}


- (void)placeSubViews {
    
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(ACD_ONE_PX));
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.titleTextField);
        make.right.equalTo(self.titleTextField);
    }];
}

#pragma mark getter and setter
- (UITextField *)titleTextField {
    if (!_titleTextField) {
        _titleTextField = UITextField.new;
        _titleTextField.font = NFont(18.0);
        _titleTextField.textColor = COLOR_HEX(0x000000);
        _titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _titleTextField.placeholder = @"Group Name";
    }
    return _titleTextField;
}
@end
