//
//  ACDTextTranslationCell.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/7/19.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "ACDTextTranslationCell.h"
#import "ACDTextTranslationBubbleView.h"
#import "EaseMessageModel+Translation.h"

@interface ACDTextTranslationCell ()
@end

@implementation ACDTextTranslationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithDirection:(AgoraChatMessageDirection)aDirection chatType:(AgoraChatType)aChatType messageType:(AgoraChatMessageType)aMessageType viewModel:(EaseChatViewModel *)viewModel
{
    self = [super initWithDirection:aDirection chatType:aChatType messageType:aMessageType viewModel:viewModel];
    if (self) {
        self.model.showTranslation = NO;
        [self setupTranslationsView];
    }
    return self;
}

+ (NSString *)cellIdentifierWithDirection:(AgoraChatMessageDirection)aDirection type:(AgoraChatMessageType)aType
{
    NSString *identifier = @"EMMsgCellDirectionSend";
    if (aDirection == AgoraChatMessageDirectionReceive) {
        identifier = @"EMMsgCellDirectionRecv";
    }
    identifier = [NSString stringWithFormat:@"%@Translation", identifier];
    return identifier;
}

- (EaseChatMessageBubbleView *)getBubbleViewWithType:(AgoraChatMessageType)aType
{
    return [[ACDTextTranslationBubbleView alloc] initWithDirection:self.direction type:50 viewModel:[self translationsViewModel]];
}

- (void)setModel:(EaseMessageModel *)model
{
    [super setModel:model];
    if(self.model.message.body.type == AgoraChatMessageTypeText) {
        AgoraChatTextMessageBody* textBody = (AgoraChatTextMessageBody*)self.model.message.body;
        if (textBody.translations.count > 0) {
            self.model.translateStatus = TranslateStatusSuccess;
        } else {
            self.model.translateStatus = TranslateStatusTranslating;
        }
    }
    [self updateTranslateInfo];
}

- (void)setupTranslationsView
{
    [self addSubview:self.translationsLabel];
    [self.translationsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.direction == AgoraChatMessageDirectionSend) {
            make.right.equalTo(self.bubbleView);
        } else {
            make.left.equalTo(self.bubbleView);
        }
        make.height.equalTo(@24);
        make.bottom.equalTo(self.contentView);
    }];
    [self.bubbleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.contentView).offset(self.direction == AgoraChatMessageDirectionSend ? 6 : 25);
    }];
}

- (EaseChatViewModel*)translationsViewModel
{
    id vm = [super performSelector:@selector(viewModel)];
    if ([vm isKindOfClass:[EaseChatViewModel class]])
        return (EaseChatViewModel*)vm;
    return [[EaseChatViewModel alloc] init];
}

- (UILabel *)translationsLabel
{
    if (!_translationsLabel) {
        _translationsLabel = [[UILabel alloc] init];
        _translationsLabel.font = [self translationsViewModel].textMessaegFont;
        _translationsLabel.numberOfLines = 0;
        _translationsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _translationsLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(translationsLabelTaped:)];
        [_translationsLabel addGestureRecognizer:tapGes];
    }
    return _translationsLabel;
}

- (void)translationsLabelTaped:(UITapGestureRecognizer*)gesture{
    switch(self.model.translateStatus) {
        case TranslateStatusSuccess:
        {
            self.model.showTranslation = !self.model.showTranslation;
            [self updateTranslateInfo];
            //self.model = self.model;
            UITableView* tableView = (UITableView*)self.superview;
            NSIndexPath* indexPath = [tableView indexPathForCell:self];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
        }
            break;
        case TranslateStatusFailed:
            if (self.translateDelegate && [self.translateDelegate respondsToSelector:@selector(cellDidRetryTranslate:)]) {
                [self.translateDelegate cellDidRetryTranslate:self];
            }
            break;
        default:
            break;
    }
}

- (void)updateTranslateInfo
{
    NSMutableAttributedString *translations = [[NSMutableAttributedString alloc] init];
    UIColor* grayColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    UIColor* blueColor = [UIColor colorWithRed:0 green:95.0/255.0 blue:1.0 alpha:1];
    switch(self.model.translateStatus) {
        case TranslateStatusSuccess:
        {
            [translations appendAttributedString:[[NSAttributedString alloc] initWithString:@"Translated by Agora Chat " attributes:@{
                NSForegroundColorAttributeName: grayColor,
                NSFontAttributeName: [UIFont systemFontOfSize:10]
            }]];
            NSMutableAttributedString *action = [[NSMutableAttributedString alloc] initWithString:(self.model.showTranslation ? @"View Origin Text" : @"View Translations") attributes:@{
                NSForegroundColorAttributeName: blueColor,
                NSFontAttributeName: [UIFont systemFontOfSize:10]
            }];
            [translations appendAttributedString:action];
        }
            break;
        case TranslateStatusFailed:
        {
            [translations appendAttributedString:[[NSAttributedString alloc] initWithString:@"Translate failed" attributes:@{
                NSForegroundColorAttributeName: grayColor,
                NSFontAttributeName: [UIFont systemFontOfSize:10]
            }]];
            NSMutableAttributedString *action = [[NSMutableAttributedString alloc] initWithString:@"Retry" attributes:@{
                NSForegroundColorAttributeName: blueColor,
                NSFontAttributeName: [UIFont systemFontOfSize:10]
            }];
            [translations appendAttributedString:action];
        }
            break;
        case TranslateStatusTranslating:
            [translations appendAttributedString:[[NSAttributedString alloc] initWithString:@"Translating..." attributes:@{
                NSForegroundColorAttributeName: grayColor,
                NSFontAttributeName: [UIFont systemFontOfSize:10]
            }]];
            break;
        default:
            break;
    }
    self.translationsLabel.attributedText = translations;
}

@end
