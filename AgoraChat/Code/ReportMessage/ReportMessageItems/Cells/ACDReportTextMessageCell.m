//
//  ACDReportTextMessageCell.m
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/13.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDReportTextMessageCell.h"

@interface ACDReportTextMessageCell()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end

@implementation ACDReportTextMessageCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(EaseMessageModel *)model {
    [super setModel: model];
    AgoraChatTextMessageBody *body = (AgoraChatTextMessageBody *)model.message.body;
    self.messageLabel.text = body.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
