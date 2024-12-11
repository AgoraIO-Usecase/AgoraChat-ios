//
//  ACDPinMessageCell.h
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2024/3/12.
//  Copyright © 2024 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACDPinMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ACDPinMessageCellDelegate <NSObject>

- (void)unpinMessage:(ACDPinMessageModel*)model;

@end

@interface ACDPinMessageCell : UITableViewCell
@property (nonatomic,strong) UILabel* titleLabel;
@property (nonatomic,strong) UILabel* dateLabel;
@property (nonatomic,strong) UILabel* messageLabel;
@property (nonatomic,strong) UIButton* unpinButton;
@property (nonatomic,strong) UIImageView* image;
@property (nonatomic,strong) ACDPinMessageModel* model;
@property (nonatomic,weak) id<ACDPinMessageCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
