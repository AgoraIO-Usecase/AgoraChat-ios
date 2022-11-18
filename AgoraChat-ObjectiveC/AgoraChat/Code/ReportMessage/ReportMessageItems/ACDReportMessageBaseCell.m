//
//  ACDReportMessageBaseCell.m
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/14.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDReportMessageBaseCell.h"
#import "ACDDateHelper.h"

@implementation ACDReportMessageBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.avatarImageView.clipsToBounds = YES;
}

- (void)setModel:(EaseMessageModel *)model {
    NSURL *url = [NSURL URLWithString:model.userDataProfile.avatarURL];
    [self.avatarImageView sd_setImageWithURL:url placeholderImage:model.userDataProfile.defaultAvatar];
    self.nameLabel.text = model.userDataProfile.showName;
    self.timeLabel.text = [ACDDateHelper formattedTimeFromTimeInterval:model.message.timestamp];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
