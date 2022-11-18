//
//  AgoraChatMessageWeakHint.h
//  AgoraChat
//
//  Created by zhangchong on 2022/06/08.
//  Copyright © 2022 zhangchong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraChatMessageWeakHint : UITableViewCell

@property (nonatomic, strong) UILabel *hintLabel;

- (instancetype)initWithMessageModel:(EaseMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
