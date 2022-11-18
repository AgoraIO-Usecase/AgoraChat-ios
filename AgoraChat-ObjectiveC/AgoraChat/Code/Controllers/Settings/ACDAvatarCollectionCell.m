//
//  ACDAvatarCollectionCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/7.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDAvatarCollectionCell.h"

@interface ACDAvatarCollectionCell ()

@property (nonatomic, strong) UIImageView *selectedImageView;
@end


@implementation ACDAvatarCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
        [self placeSubViews];
    }
    return self;
}

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.selectedImageView];
}

- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.iconImageView);
    }];
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass([ACDAvatarCollectionCell class]);
}

#pragma mark getter and setter
- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UIImageView *)selectedImageView {
    if (_selectedImageView == nil) {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_selectedImageView setImage:ImageWithName(@"default_avatar_setting")];
        _selectedImageView.hidden = YES;
    }
    return _selectedImageView;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.selectedImageView.hidden = NO;
    }else {
        self.selectedImageView.hidden = YES;
    }
}


@end
