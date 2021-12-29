//
//  ACDAddContactViewController.h
//  ChatDemo-UI3.0
//
//  Created by zhangchong on 2021/12/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDAddContactViewController : UIViewController

- (instancetype)initWithUserModel:(AgoraUserModel *)model;

@end

NS_ASSUME_NONNULL_END
