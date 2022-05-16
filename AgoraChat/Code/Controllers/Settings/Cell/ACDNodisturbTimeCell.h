//
//  ACDNodisturbTimeCell.h
//  AgoraChat
//
//  Created by liu001 on 2022/3/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDNodisturbTimeCell : ACDCustomCell
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *timeButton;
@property (nonatomic, copy) void (^timeButtonBlock)();

@end

NS_ASSUME_NONNULL_END
