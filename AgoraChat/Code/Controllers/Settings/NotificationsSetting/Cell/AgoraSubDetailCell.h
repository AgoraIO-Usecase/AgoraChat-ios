//
//  AgoraSubDetailCell.h
//  AgoraChat
//
//  Created by hxq on 2022/3/22.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDTitleDetailCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraSubDetailCell : ACDTitleDetailCell
@property (nonatomic, strong) UILabel* subDetailLabel;
@property (nonatomic, assign) BOOL showSubDetailLabel;
@end

NS_ASSUME_NONNULL_END
