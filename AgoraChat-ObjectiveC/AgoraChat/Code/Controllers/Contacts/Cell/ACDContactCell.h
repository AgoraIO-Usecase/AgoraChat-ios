//
//  ACDContactCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"
@class AgoraUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface ACDContactCell : ACDCustomCell
@property (nonatomic, strong) AgoraUserModel *model;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *sender;

@end

NS_ASSUME_NONNULL_END
