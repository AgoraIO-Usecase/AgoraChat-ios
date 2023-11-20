//
//  AgoraChatURLPreviewCell.m
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/7/18.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "AgoraChatURLPreviewCell.h"
#import "EaseMessageCell+Category.h"
#import "AgoraChatURLPreviewBubbleView.h"

@interface AgoraChatURLPreviewCell ()<AgoraChatURLPreviewBubbleViewDelegate>

@end

@implementation AgoraChatURLPreviewCell

+ (NSString *)cellIdentifierWithDirection:(AgoraChatMessageDirection)aDirection type:(AgoraChatMessageType)aType
{
    return @"AgoraChatURLPreviewCell";
}

- (EaseChatMessageBubbleView *)getBubbleViewWithType:(AgoraChatMessageType)aType
{
    EaseChatMessageBubbleView *bubbleView = [super getBubbleViewWithType:aType];
    if (!self.bubbleView || ![self.bubbleView isKindOfClass:[AgoraChatURLPreviewBubbleView class]]) {
        AgoraChatURLPreviewBubbleView *URLPreviewBubbleView = [[AgoraChatURLPreviewBubbleView alloc] initWithDirection:self.direction type:AgoraChatMessageTypeExtURLPreview viewModel:self.viewModel];
        URLPreviewBubbleView.delegate = self;
        bubbleView = URLPreviewBubbleView;
    }
    
    
    return bubbleView;
}

- (void)setModel:(EaseMessageModel *)model {
    [super setModel:model];
//    [super updateLayout];
}

- (void)URLPreviewBubbleViewNeedLayout:(AgoraChatURLPreviewBubbleView *)view {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellNeedReload:)]) {
        [self.delegate messageCellNeedReload:self];
    }
}


@end
