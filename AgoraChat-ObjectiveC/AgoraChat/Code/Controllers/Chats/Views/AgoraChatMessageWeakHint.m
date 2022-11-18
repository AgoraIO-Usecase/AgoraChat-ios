//
//  AgoraChatMessageWeakHint.m
//  AgoraChat
//
//  Created by zhangchong on 2022/06/08.
//  Copyright © 2022 zhangchong. All rights reserved.
//

#import "AgoraChatMessageWeakHint.h"
#import <Masonry/Masonry.h>

@implementation AgoraChatMessageWeakHint

- (instancetype)initWithMessageModel:(EaseMessageModel *)model
{
    NSString *identifier = @"AgoraChatMessageWeakHint";
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.textColor = [UIColor colorWithHexString:@"#999999"];;
        _hintLabel.backgroundColor = [UIColor clearColor];
        _hintLabel.font = [UIFont fontWithName:@"Regular" size:12];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.numberOfLines = 0;
        _hintLabel.attributedText = [self cellAttributeText:model.message];
        [self.contentView addSubview:_hintLabel];
        [_hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).offset(5);
            make.bottom.right.equalTo(self.contentView).offset(-5);
        }];
    }
    
    return self;
}

- (NSAttributedString *)cellAttributeText:(AgoraChatMessage *)message {
    AgoraChatTextMessageBody *body = (AgoraChatTextMessageBody *)message.body;
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:body.text];
    [attribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"]} range:NSMakeRange(0, body.text.length)];
    
    
    if (message.ext && message.ext.count > 0) {
        NSString *IDStr = [message.ext objectForKey:kNOTI_EXT_USERID];
        if (IDStr && IDStr.length > 0) {
            [attribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"]} range:[body.text rangeOfString:IDStr]];
        }
    }
    
    return attribute;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
