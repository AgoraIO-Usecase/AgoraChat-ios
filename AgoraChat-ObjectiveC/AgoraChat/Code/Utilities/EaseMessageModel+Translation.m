//
//  EaseMessageModel+Translation.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/7/24.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "EaseMessageModel+Translation.h"
#import <objc/runtime.h>

static char kShowTranslations;
static char kTranslateStatus;

@implementation EaseMessageModel (Translation)

- (BOOL)showTranslation
{
    NSNumber* number = objc_getAssociatedObject(self, &kShowTranslations);
    return [number boolValue];
}

- (void)setShowTranslation:(BOOL)showTranslation
{
    NSNumber* number = [NSNumber numberWithBool:showTranslation];
    objc_setAssociatedObject(self, &kShowTranslations, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
