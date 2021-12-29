//
//  SelectAvatarViewController.h
//  EaseIM
//
//  Created by lixiaoming on 2021/3/22.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraChatRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectAvatarViewController : AgoraChatRefreshViewController
- (instancetype)initWithCurrentAvatar:(NSString*)aAvatarUrl;
@end

NS_ASSUME_NONNULL_END
