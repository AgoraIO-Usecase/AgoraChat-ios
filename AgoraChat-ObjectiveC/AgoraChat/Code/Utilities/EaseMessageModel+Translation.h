//
//  EaseMessageModel+Translation.h
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/7/24.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "EaseMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TranslateStatus) {
    TranslateStatusSuccess,
    TranslateStatusFailed,
    TranslateStatusTranslating,
};
@interface EaseMessageModel (Translation)
@property (nonatomic,readonly) BOOL isTranslation;
@property (nonatomic) BOOL showTranslation;
@property (nonatomic) TranslateStatus translateStatus;
@end

NS_ASSUME_NONNULL_END
