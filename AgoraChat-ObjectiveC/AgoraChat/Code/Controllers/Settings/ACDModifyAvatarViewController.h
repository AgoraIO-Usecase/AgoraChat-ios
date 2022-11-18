//
//  ACDModifyAvatarViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/5.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDModifyAvatarViewController : UIViewController

@property (nonatomic, strong) void(^selectedBlock)(NSString *imageName);

@end

NS_ASSUME_NONNULL_END
