//
//  ACDReportDocumentMessageCell.m
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/14.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDReportDocumentMessageCell.h"

@interface ACDReportDocumentMessageCell ()
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;

@end

@implementation ACDReportDocumentMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(EaseMessageModel *)model {
    [super setModel: model];
    AgoraChatFileMessageBody *body = (AgoraChatFileMessageBody *)model.message.body;
    self.fileNameLabel.text = body.displayName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
