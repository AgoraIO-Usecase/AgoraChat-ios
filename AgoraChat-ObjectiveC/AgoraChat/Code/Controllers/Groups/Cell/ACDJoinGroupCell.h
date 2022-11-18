//
//  ACDJoinGroupCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDJoinGroupCell : ACDCustomCell
@property (nonatomic, strong, readonly) UIButton *joinButton;
@property (nonatomic, copy) void (^joinGroupBlock)();

@end

NS_ASSUME_NONNULL_END
