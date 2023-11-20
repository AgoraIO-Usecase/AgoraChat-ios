//
//  ACDGroupNewCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/25.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"
#import "AgoraGroupUIProtocol.h"
@class AgoraGroupModel;

NS_ASSUME_NONNULL_BEGIN

@interface ACDGroupCell : ACDCustomCell
@property (nonatomic, strong) AgoraGroupModel *model;
@property (nonatomic, assign) id<AgoraGroupUIProtocol> delegate;
@property (nonatomic, strong) UIButton *sender;

@end

NS_ASSUME_NONNULL_END
