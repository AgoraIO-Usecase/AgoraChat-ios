//
//  ACDGroupInfoCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/28.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDInfoCell : ACDCustomCell

@property (nonatomic, strong) UIButton *customBtn;

@property (nonatomic, copy) void (^customBtnSelect)();

@end

NS_ASSUME_NONNULL_END
