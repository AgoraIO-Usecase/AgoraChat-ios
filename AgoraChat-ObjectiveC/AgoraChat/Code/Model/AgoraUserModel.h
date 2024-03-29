/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "IAgoraUserModel.h"
#import "IAgoraRealtimeSearch.h"
@interface AgoraUserModel : NSObject<IAgoraUserModel, IAgoraRealtimeSearch>

@property (nonatomic, strong, readonly) NSString *hyphenateId;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatarURLPath;
@property (nonatomic, strong) UIImage *defaultAvatarImage;
@property (nonatomic, assign) BOOL  selected;

- (instancetype)initWithHyphenateId:(NSString *)hyphenateId;
- (instancetype)initWithHyphenateId:(NSString *)hyphenateId nickname:(NSString*)nickname;

@end
