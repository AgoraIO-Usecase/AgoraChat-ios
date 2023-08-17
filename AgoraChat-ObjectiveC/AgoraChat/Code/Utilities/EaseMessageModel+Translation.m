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

- (void)setMessage:(AgoraChatMessage *)message
{
    u_int count;
    Method *methods = class_copyMethodList([EaseMessageModel class], &count);
    NSInteger index = 0;

    for (int i = 0; i < count; i++) {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@"method:%@",strName);
        if ([strName isEqualToString:@"setMessage:"]) {
            index = i;  // 先获取原类方法在方法列表中的索引
        }
    }

    // 调用方法
    SEL sel = method_getName(methods[index]);
    IMP imp = method_getImplementation(methods[index]);
    ((void (*)(id, SEL,id))imp)(self,sel,message);
    self.showTranslation = message.direction == AgoraChatMessageDirectionReceive;
}


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
