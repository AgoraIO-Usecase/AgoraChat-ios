//
//  ACDSearchResultView.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDSearchResultView : ACDCustomBaseView
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UIButton *addButton;
@property (nonatomic, copy) void (^addGroupBlock)();

@end

NS_ASSUME_NONNULL_END
