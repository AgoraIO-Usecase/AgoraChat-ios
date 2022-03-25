//
//  AgoraSilentModeSetCell.h
//  AgoraChat
//
//  Created by hxq on 2022/3/23.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraSilentModeSetCell : ACDCustomCell
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, copy) void (^selectBlock)(NSInteger tag);
@end

NS_ASSUME_NONNULL_END
