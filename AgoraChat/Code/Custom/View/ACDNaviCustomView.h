//
//  ACDNaviCustomView.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACDCustomBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDNaviCustomView : ACDCustomBaseView
@property (nonatomic, strong ) UIImageView* titleImageView;
@property (nonatomic, strong ) UIButton* addButton;
@property (nonatomic, copy ) void (^addActionBlock)(void);
@end

NS_ASSUME_NONNULL_END
