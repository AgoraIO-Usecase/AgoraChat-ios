//
//  ACDGroupInfoSwitchCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/28.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDInfoSwitchCell : ACDCustomCell
@property (nonatomic, strong) UISwitch *aSwitch;
@property (nonatomic, copy) void (^switchActionBlock)(BOOL isOn);


@end

NS_ASSUME_NONNULL_END
