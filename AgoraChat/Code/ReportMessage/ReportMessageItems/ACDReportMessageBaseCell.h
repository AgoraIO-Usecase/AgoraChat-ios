//
//  ACDReportMessageBaseCell.h
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/14.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDReportMessageBaseCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) EaseMessageModel *model;
@end

NS_ASSUME_NONNULL_END
