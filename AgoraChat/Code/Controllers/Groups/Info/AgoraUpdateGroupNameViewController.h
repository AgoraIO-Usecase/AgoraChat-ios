/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

#import <AgoraChat/AgoraChatGroup.h>

@interface AgoraUpdateGroupNameViewController : UIViewController
@property (nonatomic,copy) void (^updateGroupNameBlock)(NSString *groupName);

- (instancetype)initWithGroupId:(NSString *)aGroupId
                        subject:(NSString *)aSubject;

@end
