//
//  ACDNameSwitchCell.h
//  AgoraChat
//
//  Created by hxq on 2022/3/25.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDNameSwitchCell : ACDCustomCell
@property (nonatomic, strong) UISwitch *aSwitch;
@property (nonatomic, copy) void (^switchActionBlock)(BOOL isOn);
@end

NS_ASSUME_NONNULL_END
