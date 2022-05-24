//
//  AgoraChatCallCell.m
//  AgoraChatCallKit
//
//  Created by 冯钊 on 2022/4/27.
//

#import "AgoraChatCallCell.h"

#import "EaseMessageModel.h"
#import "AgoraChatCallDefine.h"
#import "EaseMessageCell+Category.h"

@interface AgoraChatCallCell ()

@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation AgoraChatCallCell

+ (NSString *)cellIdentifierWithDirection:(AgoraChatMessageDirection)aDirection type:(AgoraChatMessageType)aType
{
    return @"AgoraChatCallCell";
}

- (EaseChatMessageBubbleView *)getBubbleViewWithType:(AgoraChatMessageType)aType
{
    EaseChatMessageBubbleView *bubbleView = [[EaseChatMessageBubbleView alloc] init];
    bubbleView.layer.cornerRadius = 16;
    
    _statusImageView = [[UIImageView alloc] init];
    [bubbleView addSubview:_statusImageView];
    
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.font = [UIFont systemFontOfSize:16];
    _statusLabel.textColor = UIColor.blackColor;
    [bubbleView addSubview:_statusLabel];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    _timeLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    [bubbleView addSubview:_timeLabel];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_statusLabel.mas_bottom).offset(6);
        make.left.equalTo(_statusLabel);
    }];
    
    bubbleView.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1];
    
    return bubbleView;
}

- (CGFloat)maxBubbleViewWidth
{
    return 230;
}

- (void)setModel:(EaseMessageModel *)model
{
    [super setModel:model];
    
    NSString *action = model.message.ext[@"action"];
    AgoraChatCallType callType = [model.message.ext[@"type"] intValue];
    if (model.direction == AgoraChatMessageDirectionSend) {
        [_statusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.top.equalTo(@10);
            make.bottom.equalTo(@-10);
            make.left.equalTo(@10);
            make.right.equalTo(@-170);
        }];
        [_statusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@68);
            make.top.equalTo(_statusImageView);
        }];
    } else {
        [_statusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.top.equalTo(@10);
            make.bottom.equalTo(@-10);
            make.right.equalTo(@-10);
            make.left.equalTo(@170);
        }];
        [_statusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
            make.top.equalTo(_statusImageView);
        }];
    }
    if ([action isEqualToString:@"invite"]) {
        if (callType == AgoraChatCallType1v1Audio || callType == AgoraChatCallTypeMultiAudio) {
            _statusImageView.image = [UIImage imageNamed:@"cell_audio_call_invite"];
            _statusLabel.text = @"Audio Call Invite";
            _timeLabel.text = @"Touch To Join";
        } else {
            _statusImageView.image = [UIImage imageNamed:@"cell_video_call_invite"];
            _statusLabel.text = @"Video Call Invite";
            _timeLabel.text = @"Touch To Join";
        }
    } else if ([action isEqualToString:@"cancelCall"]) {
        int timeLength = [self.model.message.ext[@"callDuration"] intValue];
        int m = timeLength / 60;
        int s = timeLength - m * 60;
        NSString *duration = [NSString stringWithFormat:@"%02d:%02d", m, s];
        
        if (callType == AgoraChatCallType1v1Audio || callType == AgoraChatCallTypeMultiAudio) {
            _statusImageView.image = [UIImage imageNamed:@"cell_audio_call"];
            _statusLabel.text = @"Audio Call Ended";
            _timeLabel.text = duration;
        } else {
            _statusImageView.image = [UIImage imageNamed:@"cell_video_call"];
            _statusLabel.text = @"Video Call Ended";
            _timeLabel.text = duration;
        }
    }
    
    [self setStatusHidden:YES];
    
    [self.bubbleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.lessThanOrEqualTo(@300);
    }];
}

@end
