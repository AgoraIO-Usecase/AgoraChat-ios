/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "IAgoraApplyModel.h"
#import "IAgoraRealtimeSearch.h"

typedef NS_ENUM(NSInteger, ACDApplyStatus) {
    ACDApplyStatusDefault = 0,
    ACDApplyStatusAgreed,
    ACDApplyStatusDeclined,
    ACDApplyStatusExpired,
};


@interface AgoraApplyModel : NSObject<IAgoraApplyModel,IAgoraRealtimeSearch>

@property (nonatomic, strong, readonly) NSString *recordId;
@property (nonatomic, strong) NSString * applyHyphenateId;
@property (nonatomic, strong) NSString * applyNickName;
@property (nonatomic, strong) NSString * reason;
@property (nonatomic, strong) NSString * receiverHyphenateId;
@property (nonatomic, strong) NSString * receiverNickname;
@property (nonatomic, assign) AgoraApplyStyle style;
@property (nonatomic, strong) NSString * groupId;
@property (nonatomic, strong) NSString * groupSubject;
@property (nonatomic, assign) NSInteger groupMemberCount;
@property (nonatomic, assign) ACDApplyStatus applyStatus;

@end
