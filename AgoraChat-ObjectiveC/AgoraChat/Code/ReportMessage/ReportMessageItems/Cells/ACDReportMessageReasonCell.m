//
//  ACDReportMessageReasonCell.m
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/13.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDReportMessageReasonCell.h"

@interface ACDReportMessageReasonCell ()<UITextViewDelegate>

@end

@implementation ACDReportMessageReasonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.textView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length + text.length > 500) {
        return NO;
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.numLabel.text = [NSString stringWithFormat:@"%lu/500", (unsigned long)textView.text.length];
}

@end
