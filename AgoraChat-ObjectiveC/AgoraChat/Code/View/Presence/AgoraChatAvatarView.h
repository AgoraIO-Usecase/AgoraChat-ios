//
//  AgoraChatAvatarView.h
//  EaseIM
//
//  Created by lixiaoming on 2022/2/7.
//  Copyright © 2022 lixiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraChatAvatarView : UIImageView
@property (nonatomic,strong) UIImageView* presenceView;
- (void)setPresenceImage:(UIImage* )presenceImage;
@end

NS_ASSUME_NONNULL_END
