//
//  ACDTextTranslationCell.h
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/7/19.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "EaseMessageCell.h"

@class ACDTextTranslationCell;
@protocol TranslationCellDelegate <NSObject>

- (void)cellDidRetryTranslate:(ACDTextTranslationCell*_Nonnull)cell;

@end

NS_ASSUME_NONNULL_BEGIN
@interface ACDTextTranslationCell : EaseMessageCell
@property (nonatomic,strong) UILabel* translationsLabel;
@property (nonatomic,weak) id<TranslationCellDelegate> translateDelegate;
@end

NS_ASSUME_NONNULL_END
