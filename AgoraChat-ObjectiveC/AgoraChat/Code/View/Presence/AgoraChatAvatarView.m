//
//  AgoraChatAvatarView.m
//  EaseIM
//
//  Created by lixiaoming on 2022/2/7.
//  Copyright © 2022 lixiaoming. All rights reserved.
//

#import "AgoraChatAvatarView.h"

@interface AgoraChatAvatarView ()

@end

@implementation AgoraChatAvatarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setPresenceImage:(UIImage* )presenceImage
{
    if(self.presenceView.superview)
        [self.presenceView removeFromSuperview];
    if(!self.presenceView.superview && self.superview) {
        [self.superview addSubview:self.presenceView];
        [self.presenceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(self).multipliedBy(0.4);
            make.bottom.right.equalTo(self);
        }];
    }
    self.presenceView.image = presenceImage;
}

- (UIImageView*)presenceView
{
    if(!_presenceView) {
        _presenceView = [[UIImageView alloc] init];
    }
    return _presenceView;
}

@end
