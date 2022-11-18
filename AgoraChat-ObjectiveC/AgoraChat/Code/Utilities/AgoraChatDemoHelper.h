/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "AgoraMainViewController.h"
#import "AgoraPushNotificationViewController.h"
#import "ACDContactsViewController.h"
#import "ACDChatsViewController.h"
#import "ACDSettingsViewController.h"

@interface AgoraChatDemoHelper : NSObject<AgoraChatClientDelegate, AgoraChatContactManagerDelegate, AgoraChatGroupManagerDelegate, AgoraChatManagerDelegate, AgoraChatroomManagerDelegate>

@property (nonatomic, weak) ACDContactsViewController *contactsVC;

@property (nonatomic, weak) AgoraMainViewController *mainVC;

@property (nonatomic, weak) ACDSettingsViewController *settingsVC;

@property (nonatomic, weak) AgoraPushNotificationViewController *pushVC;

@property (nonatomic, weak)  ACDChatsViewController  *chatsVC;

+ (instancetype)shareHelper;

- (void)setupUntreatedApplyCount;
- (void)hiddenApplyRedPoint;


@end
