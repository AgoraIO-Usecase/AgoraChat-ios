//
//  ACDPinMessageCell.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2024/3/12.
//  Copyright © 2024 easemob. All rights reserved.
//

#import "ACDPinMessageCell.h"
#import <chat-uikit/EaseEmojiHelper.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ACDPinMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(5, 10, 5, 30));
}

- (void)setupSubviews
{
    self.contentView.backgroundColor = [[UIColor alloc] initWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];;
    self.contentView.layer.cornerRadius = 8;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.image];
    [self.contentView addSubview:self.unpinButton];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(8);
        make.top.equalTo(self.contentView).offset(5);
        make.height.equalTo(@18);
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.right.equalTo(self.contentView).offset(-8);
    }];
    [self.unpinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-5);
        make.right.equalTo(self.contentView).offset(-8);
        make.width.height.equalTo(@20);
    }];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-5);
        make.left.equalTo(self.contentView).offset(8);
        make.right.equalTo(self.unpinButton.mas_left).offset(-10);
    }];
    [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(8);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.width.equalTo(@80);
        make.height.equalTo(@100);
    }];
    
    
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"SFPro-Medium" size:10];
        _titleLabel.textColor = [UIColor colorWithRed:0.092 green:0.102 blue:0.108 alpha:1.0];
    }
    return _titleLabel;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont fontWithName:@"SFPro-Regular" size:10];
        _dateLabel.textColor = [UIColor colorWithRed:0.676 green:0.706 blue:0.724 alpha:1.0];
    }
    return _dateLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 1;
        _messageLabel.font = [UIFont fontWithName:@"SFPro-Regular" size:12];
        _messageLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    }
    return _messageLabel;
}

- (UIImageView *)image
{
    if (!_image) {
        _image = [[UIImageView alloc] init];
    }
    return _image;
}

- (UIButton *)unpinButton
{
    if (!_unpinButton) {
        _unpinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_unpinButton setImage:[UIImage imageNamed:@"unpin"] forState:UIControlStateNormal];
        [_unpinButton addTarget:self action:@selector(unpinAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unpinButton;
}

-(void)unpinAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(unpinMessage:)]) {
        [self.delegate unpinMessage:self.model];
    }
}

- (void)updateModelType:(BOOL)isText 
{
    [self.messageLabel removeFromSuperview];
    [self.image removeFromSuperview];
    if (isText) {
        [self.contentView addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-5);
            make.left.equalTo(self.contentView).offset(8);
            make.right.equalTo(self.unpinButton.mas_left).offset(-10);
        }];
    } else {
        [self.contentView addSubview:self.image];
        [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(8);
            make.bottom.equalTo(self.contentView).offset(-5);
            make.width.equalTo(@80);
            make.height.equalTo(@100);
        }];
    }
}

- (void)setModel:(ACDPinMessageModel *)model
{
    _model = model;
    self.titleLabel.text = model.title;
    self.dateLabel.text = model.dateString;
    switch (model.message.body.type) {
        case AgoraChatMessageBodyTypeText:
        {
            AgoraChatTextMessageBody* textBody = (AgoraChatTextMessageBody*)model.message.body;
            self.messageLabel.text = [EaseEmojiHelper convertEmoji:textBody.text];
            [self updateModelType:YES];
        }
            break;
        case AgoraChatMessageBodyTypeFile:
        {
            AgoraChatFileMessageBody* fileBody = (AgoraChatFileMessageBody*)model.message.body;
            self.messageLabel.text = [NSString stringWithFormat:@"[File] %@",fileBody.displayName];
            [self updateModelType:YES];
        }
            break;
        case AgoraChatMessageBodyTypeVoice:
        {
            AgoraChatVoiceMessageBody* voiceBody = (AgoraChatVoiceMessageBody*)model.message.body;
            self.messageLabel.text = [NSString stringWithFormat:@"[Voice] %d",voiceBody.duration];
            [self updateModelType:YES];
        }
            break;
        case AgoraChatMessageBodyTypeCombine:
        {
            AgoraChatCombineMessageBody* combineBody = (AgoraChatCombineMessageBody*)model.message.body;
            self.messageLabel.text = [NSString stringWithFormat:@"[Chat History] %@",combineBody.summary];
            [self updateModelType:YES];
        }
            break;
        case AgoraChatMessageBodyTypeLocation:
        {
            AgoraChatLocationMessageBody* locationBody = (AgoraChatLocationMessageBody*)model.message.body;
            self.messageLabel.text = [NSString stringWithFormat:@"[Location] %@",locationBody.address];
            [self updateModelType:YES];
        }
            break;
        case AgoraChatMessageBodyTypeImage:
        {
            AgoraChatImageMessageBody* imageBody = (AgoraChatImageMessageBody*)model.message.body;
            UIImage * image = [UIImage imageWithContentsOfFile:(imageBody.thumbnailLocalPath.length > 0 ? imageBody.thumbnailLocalPath : imageBody.localPath)];
            if (image)
                self.image.image = image;
            else {
                image = [UIImage imageNamed:@"default"];
                self.image.image = image;
                NSURL* url = [NSURL URLWithString:imageBody.thumbnailRemotePath];
                if (url)
                    [self.image sd_setImageWithURL:url];
            }
            [self updateModelType:NO];
            
        }
            break;
        case AgoraChatMessageBodyTypeVideo:
        {
            AgoraChatVideoMessageBody* videoBody = (AgoraChatVideoMessageBody*)model.message.body;
            UIImage* image = [UIImage imageWithContentsOfFile:videoBody.thumbnailLocalPath];
            if (image) {
                self.image.image = image;
            } else {
                image = [UIImage imageNamed:@"default"];
                self.image.image = image;
                NSURL* url = [NSURL URLWithString:videoBody.thumbnailRemotePath];
                if (url)
                    [self.image sd_setImageWithURL:url];
            }
            self.image.image = image;
            [self updateModelType:NO];
        }
            break;
            
        default:
            break;
    }
}

@end
