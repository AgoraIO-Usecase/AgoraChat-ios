//
//  EaseMessageModel+Translation.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/7/24.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "EaseMessageModel+Translation.h"
#import <objc/runtime.h>

static char kShowOriginText;
static char kTranslateStatus;

@implementation EaseMessageModel (Translation)

- (BOOL)showOriginText
{
    NSNumber* number = objc_getAssociatedObject(self, &kShowOriginText);
    return [number boolValue];
}

- (void)setShowOriginText:(BOOL)showOriginText
{
    NSNumber* number = [NSNumber numberWithBool:showOriginText];
    objc_setAssociatedObject(self, &kShowOriginText, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TranslateStatus)translateStatus
{
    NSNumber* status = objc_getAssociatedObject(self, &kTranslateStatus);
    return [status integerValue];
}

- (void)setTranslateStatus:(TranslateStatus)translateStatus
{
    NSNumber* status = [NSNumber numberWithInteger:translateStatus];
    objc_setAssociatedObject(self, &kTranslateStatus, status, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isTranslation
{
    if (self.message.body.type == AgoraChatMessageTypeText)
    {
        AgoraChatTextMessageBody* textBody = (AgoraChatTextMessageBody*)self.message.body;
        if (textBody.targetLanguages.count > 0)
            return YES;
    }
    return NO;
}

@end
