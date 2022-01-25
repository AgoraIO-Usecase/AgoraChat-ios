/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#ifndef AgoraChatChatDemoUIDefine_h
#define AgoraChatChatDemoUIDefine_h

#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

#define AgoraChatVIEWTOPMARGIN (kIsBangsScreen ? 34.f : 0.f)

#define ChatDemo_DEBUG 1

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

// rgb颜色转换（16进制->10进制）
#define COLOR_HEXA(__RGB,__ALPHA) [UIColor colorWithRed:((float)((__RGB & 0xFF0000) >> 16))/255.0 green:((float)((__RGB & 0xFF00) >> 8))/255.0 blue:((float)(__RGB & 0xFF))/255.0 alpha:__ALPHA]

#define COLOR_HEX(__RGB) COLOR_HEXA(__RGB,1.0f)


#define WEAK_SELF typeof(self) __weak weakSelf = self;

//weak & strong self
#define ACD_WS                  __weak __typeof(&*self)weakSelf = self;
#define ACD_SS(WKSELF)          __strong __typeof(&*self)strongSelf = WKSELF;

#define ACD_ONE_PX  (1.0f / [UIScreen mainScreen].scale)

#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define KScreenWidth  [[UIScreen mainScreen] bounds].size.width

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define KNOTIFICATION_UPDATEUNREADCOUNT @"setupUnreadMessageCount"
#define KNOTIFICATIONNAME_DELETEALLMESSAGE @"RemoveAllMessages"
#define KNOTIFICATION_CALL @"callOutWithChatter"

#define  AGORACHATDEMO_POSTNOTIFY(name,object)  [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];

#define  AGORACHATDEMO_LISTENNOTIFY(name,SEL)  [[NSNotificationCenter defaultCenter] addObserver:self selector:SEL name:name object:nil];
  

#define ImageWithName(imageName) [UIImage imageNamed:imageName]

#define kAgroaPadding 10.0f
#define kAvatarHeight 32.0f
#define kContactAvatarHeight 40.0f

//user
#define USER_NAME @"user_name"
#define USER_NICKNAME @"nick_name"

//fonts
#define NFont(__SIZE) [UIFont systemFontOfSize:__SIZE] //system font with size
#define IFont(__SIZE) [UIFont italicSystemFontOfSize:__SIZE] //system font with size
#define BFont(__SIZE) [UIFont boldSystemFontOfSize:__SIZE]//system bold font with size
#define Font(__NAME, __SIZE) [UIFont fontWithName:__NAME size:__SIZE] //font with name and size

//message recall
#define MSG_EXT_RECALL @"agora_recall"

#define GROUP_LIST_FETCHFINISHED @"AgoraChatGroupListFetchFinished"
#define CHAT_BACKOFF @"AgoraChatChatBackOff"
#define USERINFO_UPDATE @"userinfo_update"
#define USERINFO_LIST @"userinfo_list"


#define kACDGroupMemberListType @"kACDGroupMemberListType"
#define kACDGroupId @"kACDGroupId"

#define KACDGroupCreateMemberLimit @"Member quantity: 3 to 2000"

#endif /* AgoraChatChatDemoUIDefine_h */
