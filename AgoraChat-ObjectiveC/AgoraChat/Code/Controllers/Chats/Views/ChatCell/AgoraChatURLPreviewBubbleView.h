//
//  EMMsgURLPreviewBubbleView.h
//  EaseIMKit
//
//  Created by 冯钊 on 2023/5/24.
//

#import "AgoraChatURLPreviewBubbleView.h"

NS_ASSUME_NONNULL_BEGIN

@class AgoraChatURLPreviewBubbleView;
@protocol AgoraChatURLPreviewBubbleViewDelegate <NSObject>

- (void)URLPreviewBubbleViewNeedLayout:(AgoraChatURLPreviewBubbleView *)view;

@end

@interface AgoraChatURLPreviewBubbleView : EaseChatMessageBubbleView

@property (nonatomic, weak) id<AgoraChatURLPreviewBubbleViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
