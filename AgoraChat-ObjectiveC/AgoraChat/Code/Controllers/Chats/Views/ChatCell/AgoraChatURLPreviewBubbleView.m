//
//  EMMsgURLPreviewBubbleView.m
//  EaseIMKit
//
//  Created by 冯钊 on 2023/5/24.
//

#import "AgoraChatURLPreviewBubbleView.h"
#import "UIImageView+WebCache.h"
#import <Masonry.h>
#import <chat-uikit/EaseEmojiHelper.h>
#import <chat-uikit/EaseEmojiHelper.h>
#import "AgoraURLPreviewManager.h"
#import <chat-uikit/EMMsgThreadPreviewBubble.h>
#define kHorizontalPadding 12
#define kVerticalPadding 8
#define KEMThreadBubbleWidth (EMScreenWidth*(3/5.0))

@interface AgoraChatURLPreviewBubbleView ()
{
    EaseChatViewModel *_viewModel;
}

@property (nonatomic, strong) CAGradientLayer *textBgLayer;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) EMMsgThreadPreviewBubble *threadBubble;
@property (nonatomic) BOOL previewed;

@end

@implementation AgoraChatURLPreviewBubbleView

- (instancetype)initWithDirection:(AgoraChatMessageDirection)aDirection
                             type:(AgoraChatMessageType)aType
                        viewModel:(EaseChatViewModel *)viewModel
{
    self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
    if (self) {
        _viewModel = viewModel;
        [self _setupSubviews];
        self.threadBubble = [[EMMsgThreadPreviewBubble alloc] initWithDirection:aDirection type:aType viewModel:viewModel];
        self.threadBubble.tag = 777;
        [self addSubview:self.threadBubble];
        self.threadBubble.layer.cornerRadius = 8;
        self.threadBubble.clipsToBounds = YES;
        self.threadBubble.hidden = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textBgLayer.frame = CGRectMake(0, 0, self.bounds.size.width, _contentView.isHidden ? self.bounds.size.height : _imageView.frame.origin.y);
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    maskPath.lineWidth = 1.0;
    maskPath.lineCapStyle = kCGLineCapRound;
    maskPath.lineJoinStyle = kCGLineJoinRound;
    [maskPath moveToPoint:CGPointMake(16, h)];
    if (self.direction == AgoraChatMessageDirectionSend) {
        [maskPath addLineToPoint:CGPointMake(w - 4, h)];
        [maskPath addQuadCurveToPoint:CGPointMake(w, h - 4) controlPoint:CGPointMake(w, h)];
    } else {
        [maskPath addLineToPoint:CGPointMake(w - 16, h)];
        [maskPath addQuadCurveToPoint:CGPointMake(w, h - 16) controlPoint:CGPointMake(w, h)];
    }
    [maskPath addLineToPoint:CGPointMake(w, 16)];
    [maskPath addQuadCurveToPoint:CGPointMake(w - 16, 0) controlPoint:CGPointMake(w, 0)];
    [maskPath addLineToPoint:CGPointMake(16, 0)];
    [maskPath addQuadCurveToPoint:CGPointMake(0, 16) controlPoint:CGPointMake(0, 0)];
    if (self.direction == AgoraChatMessageDirectionSend) {
        [maskPath addLineToPoint:CGPointMake(0, h - 16)];
        [maskPath addQuadCurveToPoint:CGPointMake(16, h) controlPoint:CGPointMake(0, h)];
    } else {
        [maskPath addLineToPoint:CGPointMake(0, h - 4)];
        [maskPath addQuadCurveToPoint:CGPointMake(4, h) controlPoint:CGPointMake(0, h)];
    }
    _shapeLayer.path = maskPath.CGPath;
}

#pragma mark - Subviews
- (void)_setupSubviews
{
    self.backgroundColor = [UIColor colorWithRed:0.92 green:0.951 blue:1 alpha:1];
    
    _textBgLayer = [CAGradientLayer layer];
    _textBgLayer.startPoint = CGPointZero;
    _textBgLayer.endPoint = CGPointMake(1, 1);
    _textBgLayer.locations = @[@0, @1];
    if (self.direction == AgoraChatMessageDirectionSend) {
        _textBgLayer.colors = @[
            (id)[UIColor colorWithRed:0.18 green:0.282 blue:0.98 alpha:1].CGColor,
            (id)[UIColor colorWithRed:0.573 green:0.188 blue:0.894 alpha:1].CGColor
        ];
    } else {
        _textBgLayer.colors = @[
            (id)[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1].CGColor,
            (id)[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1].CGColor
        ];
    }
    [self.layer addSublayer:_textBgLayer];

    _textView = [[UITextView alloc] init];
    _textView.font = _viewModel.textMessaegFont;
    _textView.backgroundColor = UIColor.clearColor;
    _textView.scrollEnabled = NO;
    _textView.contentInset = UIEdgeInsetsZero;
    _textView.editable = NO;
    if (self.direction == AgoraChatMessageDirectionSend) {
        _textView.textColor = _viewModel.sentFontColor;
    } else {
        _textView.textColor = _viewModel.reveivedFontColor;
    }
    if (self.direction == AgoraChatMessageDirectionSend) {
        _textView.linkTextAttributes = @{
            NSForegroundColorAttributeName: _textView.textColor
        };
    }
    [self addSubview:_textView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.937 blue:1 alpha:1];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.937 blue:1 alpha:1];
    [self addSubview:_contentView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = UIColor.blackColor;
    _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _titleLabel.numberOfLines = 1;
    [_contentView addSubview:_titleLabel];
    
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@(UIEdgeInsetsMake(8, 12, 8, 12)));
    }];
    
    _descLabel = [[UILabel alloc] init];
    _descLabel.numberOfLines = 0;
    _descLabel.textColor = UIColor.blackColor;
    _descLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [_contentView addSubview:_descLabel];
    
    _shapeLayer = [CAShapeLayer layer];
    self.layer.mask = _shapeLayer;
}


#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    [super setModel:model];
    if (model.isHeader == NO) {
        if (model.message.chatThread) {
            self.threadBubble.model = model;
            self.threadBubble.hidden = !model.message.chatThread;
        }else {
            self.threadBubble.hidden = YES;
        }
    } else {
        self.threadBubble.hidden = YES;
    }
    
    self.image = nil;
    self.contentView.hidden = YES;
    AgoraChatTextMessageBody *body = (AgoraChatTextMessageBody *)model.message.body;
    NSString *text = [EaseEmojiHelper convertEmoji:body.text];
    NSMutableAttributedString *attaStr = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *checkArr = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    if (checkArr.count > 0) {
        NSTextCheckingResult *result = checkArr.firstObject;
        NSString *urlStr = result.URL.absoluteString;
        NSRange range = result.range;
        if (range.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [attaStr setAttributes:@{
                NSLinkAttributeName : url,
                NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                NSUnderlineColorAttributeName: self.direction == AgoraChatMessageDirectionSend ? _viewModel.sentFontColor : [UIColor colorWithHexString:@"005fff"]
            } range:range];
            AgoraURLPreviewResult *result = [AgoraURLPreviewManager.shared resultWithURL:url];
            if (result.state == AgoraURLPreviewStateSuccess) {
                [self updateLayoutWithURLPreview: result];
            } else {
                [AgoraURLPreviewManager.shared preview:url successHandle:^(AgoraURLPreviewResult * _Nonnull result) {
                    [self updateLayoutWithURLPreview: result];
                } faieldHandle:^{
                    [self updateLayoutWithoutURLPreview];
                }];
            }
        }
    } else {
        [self updateLayoutWithoutURLPreview];
    }
    
    [attaStr addAttributes:@{
        NSForegroundColorAttributeName: self.direction == AgoraChatMessageDirectionSend ? _viewModel.sentFontColor : _viewModel.reveivedFontColor,
        NSFontAttributeName: _viewModel.textMessaegFont,
    } range:NSMakeRange(0, attaStr.length)];
    
    _textView.attributedText = attaStr;
}

- (void)updateLayoutWithURLPreview:(AgoraURLPreviewResult *)result
{
    BOOL hasThread = (self.model.message.chatThread != nil && self.model.isHeader == NO);
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(@8);
        make.right.equalTo(@-12);
    }];
    if (result.state == AgoraURLPreviewStateSuccess) {
        _imageView.hidden = NO;
        _titleLabel.hidden = NO;
        _contentView.hidden = NO;
        _descLabel.hidden = result.desc.length <= 0;
        
        [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_textView.mas_bottom).offset(8);
            make.left.right.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@130);
        }];
        [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imageView.mas_bottom);
            make.left.right.equalTo(_imageView);
            make.bottom.equalTo(self).offset(hasThread ? (-KEMThreadBubbleWidth*0.4-8):0);
        }];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@8);
            make.left.equalTo(@12);
            make.right.equalTo(@-12);
            if (result.desc.length <= 0) {
                make.bottom.equalTo(@-8);
            }
        }];
        if (result.desc.length > 0) {
            [_descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_titleLabel.mas_bottom).offset(4);
                make.left.equalTo(@12);
                make.bottom.equalTo(@-8);
                make.right.equalTo(@-12);
            }];
        } else {
            [_descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {}];
        }
        __weak typeof(self) weakself = self;
        BOOL previewed = self.previewed;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:result.imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(URLPreviewBubbleViewNeedLayout:)] && !previewed) {
                [weakself.delegate URLPreviewBubbleViewNeedLayout:weakself];
            }
        }];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.text = result.title;
        _descLabel.text = result.desc;
        self.previewed = YES;
    } else {
        _imageView.hidden = YES;
        _contentView.hidden = NO;
        _titleLabel.hidden = NO;
        _descLabel.hidden = YES;
        
        [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
        [_descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {}];
        
        [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_textView.mas_bottom).offset(8);
            make.left.right.equalTo(_imageView);
            make.bottom.equalTo(self).offset(hasThread ? (-KEMThreadBubbleWidth*0.4-8):0);
        }];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_textView.mas_bottom).offset(8);
            make.left.equalTo(@12);
            make.right.equalTo(@-12);
            make.bottom.equalTo(@-8);
        }];
        
        _titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _titleLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        _titleLabel.text = NSLocalizedString(@"common.parsing", nil);
    }
    if (hasThread) {
        [self.threadBubble mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kHorizontalPadding);
            make.right.mas_equalTo(-kHorizontalPadding);
            make.width.mas_equalTo(KEMThreadBubbleWidth);
            make.height.mas_equalTo(KEMThreadBubbleWidth*0.4);
            make.bottom.equalTo(self).offset(-kHorizontalPadding);
        }];
    } else {
        self.threadBubble.hidden = YES;
        [self.threadBubble mas_remakeConstraints:^(MASConstraintMaker *make) {
            
        }];
    }
}

- (void)updateLayoutWithoutURLPreview
{
    _imageView.hidden = YES;
    _contentView.hidden = YES;
    _titleLabel.hidden = YES;
    _descLabel.hidden = YES;
    
    [_textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@(UIEdgeInsetsMake(8, 12, 8, 12)));
    }];
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {}];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {}];
    [_descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {}];
}

@end
