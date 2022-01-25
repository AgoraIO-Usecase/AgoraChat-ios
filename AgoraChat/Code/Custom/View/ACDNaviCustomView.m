//
//  ACDNaviCustomView.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDNaviCustomView.h"
@interface ACDNaviCustomView ()

@end

@implementation ACDNaviCustomView
- (void)prepare {
    [self addSubview:self.titleImageView];
    [self addSubview:self.addButton];
}


- (void)placeSubViews {
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kAgroaPadding * 4.4);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-kAgroaPadding);
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleImageView);
        make.right.equalTo(self).offset(-kAgroaPadding);
        make.size.equalTo(@40.0);
    }];
}

#pragma mark action
- (void)addAction {
    if (self.addActionBlock) {
        self.addActionBlock();
    }
}

#pragma mark getter and setter
- (UIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
        _addButton.contentMode = UIViewContentModeScaleAspectFill;
        [_addButton setImage:ImageWithName(@"contact_add_contacts") forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (UIImageView *)titleImageView {
    if (_titleImageView == nil) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _titleImageView.image = ImageWithName(@"nav_title_contacts");
    }
    return _titleImageView;
}


@end
