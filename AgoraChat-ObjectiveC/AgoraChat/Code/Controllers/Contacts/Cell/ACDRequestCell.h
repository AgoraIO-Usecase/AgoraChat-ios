//
//  ACDRequestCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/27.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN
@class AgoraApplyModel;

@interface ACDRequestCell : ACDCustomCell
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, copy) void (^acceptBlock)(AgoraApplyModel *model);
@property (nonatomic, copy) void (^rejectBlock)(AgoraApplyModel *model);

@end

NS_ASSUME_NONNULL_END
