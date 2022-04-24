//
//  AgoraChatCallKitManager.m
//  AgoraChat
//
//  Created by 冯钊 on 2022/4/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraChatCallKitManager.h"

#import "EaseCallConfig.h"
#import "EaseCallManager.h"
#import "UserInfoStore.h"
#import "ConfInviteUsersViewController.h"
#import "AgoraMemberSelectViewController.h"

@import PushKit;
@import CallKit;
@import AVFAudio;
@import AgoraChat;

@interface AgoraChatCallKitManager() <EaseCallDelegate, PKPushRegistryDelegate, CXProviderDelegate>

@end

@implementation AgoraChatCallKitManager

+ (instancetype)shareManager
{
    static AgoraChatCallKitManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (instancetype)init
{
    if (self = [super init]) {
        PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
        voipRegistry.delegate = self;
        voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
        
        EaseCallConfig* config = [[EaseCallConfig alloc] init];
        config.agoraAppId = @"15cb0d28b87b425ea613fc46f7c9f974";
        config.enableRTCTokenValidate = YES;

        [EaseCallManager.sharedManager initWithConfig:config delegate:self];
    }
    return self;
}

- (void)audioCallToUser:(NSString *)userId
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    if (permissionStatus == AVAudioSessionRecordPermissionDenied) {
//        [EaseAlertController showErrorAlert:NSLocalizedString(@"needMicRight", nil)];
        return;
    }
    AgoraChatConversation *conversation = [AgoraChatClient.sharedClient.chatManager getConversationWithConvId:userId];
    NSString *msgId = conversation.latestMessage.messageId;
    AgoraChatUserInfo *info = [UserInfoStore.sharedInstance getUserInfoById:userId];
    if (info && (info.avatarUrl.length > 0 || info.nickname > 0)) {
        EaseCallUser *user = [EaseCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
        [[EaseCallManager.sharedManager getEaseCallConfig] setUser:userId info:user];
    }
    [EaseCallManager.sharedManager startSingleCallWithUId:userId type:EaseCallType1v1Audio ext:nil completion:^(NSString * callId, EaseCallError * aError) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000), dispatch_get_main_queue(), ^{
            [conversation loadMessagesStartFromId:msgId count:50 searchDirection:msgId ? AgoraChatMessageSearchDirectionDown : AgoraChatMessageSearchDirectionUp completion:^(NSArray *aMessages, AgoraChatError *aError) {
                if (aMessages.count) {
//                    [self insertLocationCallRecord:aMessages];
                }
            }];
        });
    }];
}

- (void)videoCallToUser:(NSString *)userId
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    if (permissionStatus == AVAudioSessionRecordPermissionDenied) {
//        [EaseAlertController showErrorAlert:NSLocalizedString(@"needMicRight", nil)];
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
//        [EMAlertController showErrorAlert:NSLocalizedString(@"needCameraRight", nil)];
        return;
    }
    
    AgoraChatConversation *conversation = [AgoraChatClient.sharedClient.chatManager getConversationWithConvId:userId];
    NSString *msgId = conversation.latestMessage.messageId;
    AgoraChatUserInfo *info = [UserInfoStore.sharedInstance getUserInfoById:userId];
    if (info && (info.avatarUrl.length > 0 || info.nickname > 0)) {
        EaseCallUser* user = [EaseCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
        [[EaseCallManager.sharedManager getEaseCallConfig] setUser:userId info:user];
    }
    [EaseCallManager.sharedManager startSingleCallWithUId:userId type:EaseCallType1v1Video ext:nil completion:^(NSString * callId, EaseCallError * aError) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000), dispatch_get_main_queue(), ^{
            [conversation loadMessagesStartFromId:msgId count:50 searchDirection:msgId ? AgoraChatMessageSearchDirectionDown : AgoraChatMessageSearchDirectionUp completion:^(NSArray *aMessages, AgoraChatError *aError) {
                if (aMessages.count) {
//                    [self insertLocationCallRecord:aMessages];
                }
            }];
        });
    }];
}

- (void)audioCallToGroup:(NSString *)groupId viewController:(UIViewController *)viewController
{
    ConfInviteUsersViewController *controller = [[ConfInviteUsersViewController alloc] initWithGroupId:groupId excludeUsers:@[AgoraChatClient.sharedClient.currentUsername]];
    controller.didSelectedUserList = ^(NSArray * _Nonnull aInviteUsers) {
        for (NSString *strId in aInviteUsers) {
            AgoraChatUserInfo *info = [UserInfoStore.sharedInstance getUserInfoById:strId];
            if (info && (info.avatarUrl.length > 0 || info.nickname > 0)) {
                EaseCallUser *user = [EaseCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                [[EaseCallManager.sharedManager getEaseCallConfig] setUser:strId info:user];
            }
        }
        [EaseCallManager.sharedManager startInviteUsers:aInviteUsers callType:EaseCallTypeMultiAudio ext:@{
            @"groupId":groupId
        } completion:^(NSString * callId, EaseCallError * aError) {
            
        }];
    };
    
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    [viewController presentViewController:controller animated:YES completion:nil];
}

- (void)videoCallToGroup:(NSString *)groupId viewController:(UIViewController *)viewController
{
    ConfInviteUsersViewController *controller = [[ConfInviteUsersViewController alloc] initWithGroupId:groupId excludeUsers:@[AgoraChatClient.sharedClient.currentUsername]];
    controller.didSelectedUserList = ^(NSArray * _Nonnull aInviteUsers) {
        for (NSString* strId in aInviteUsers) {
            AgoraChatUserInfo *info = [UserInfoStore.sharedInstance getUserInfoById:strId];
            if (info && (info.avatarUrl.length > 0 || info.nickname > 0)) {
                EaseCallUser *user = [EaseCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                [[EaseCallManager.sharedManager getEaseCallConfig] setUser:strId info:user];
            }
        }
        [EaseCallManager.sharedManager startInviteUsers:aInviteUsers callType:EaseCallTypeMulti ext:@{
            @"groupId":groupId
        } completion:^(NSString *callId, EaseCallError *aError) {
            
        }];
    };
    
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    [viewController presentViewController:controller animated:YES completion:nil];
}

- (void)callDidEnd:(NSString*_Nonnull)aChannelName reason:(EaseCallEndReason)aReason time:(int)aTm type:(EaseCallType)aType
{
    NSString *msg = @"";
    switch (aReason) {
        case EaseCallEndReasonHandleOnOtherDevice:
            msg = NSLocalizedString(@"otherDevice", nil);
            break;
        case EaseCallEndReasonBusy:
            msg = NSLocalizedString(@"remoteBusy", nil);
            break;
        case EaseCallEndReasonRefuse:
            msg = NSLocalizedString(@"refuseCall", nil);
            break;
        case EaseCallEndReasonCancel:
            msg = NSLocalizedString(@"cancelCall", nil);
            break;
        case EaseCallEndReasonRemoteCancel:
            msg = NSLocalizedString(@"callCancel", nil);
            break;
        case EaseCallEndReasonRemoteNoResponse:
            msg = NSLocalizedString(@"remoteNoResponse", nil);
            break;
        case EaseCallEndReasonNoResponse:
            msg = NSLocalizedString(@"noResponse", nil);
            break;
        case EaseCallEndReasonHangup:
            msg = [NSString stringWithFormat:NSLocalizedString(@"callendPrompt", nil),aTm];
            break;
        default:
            break;
    }
    if (msg.length > 0) {
        [self showHint:msg];
    }
}

- (void)multiCallDidInvitingWithCurVC:(UIViewController *)vc callType:(EaseCallType)callType excludeUsers:(NSArray<NSString *> *)users ext:(NSDictionary *)aExt
{
    NSString *groupId = nil;
    if (aExt) {
        groupId = [aExt objectForKey:@"groupId"];
    }
    if (!groupId || groupId.length <= 0) {
        return;
    }
    
    ConfInviteUsersViewController *confVC = [[ConfInviteUsersViewController alloc] initWithGroupId:groupId excludeUsers:users];
    confVC.didSelectedUserList = ^(NSArray * _Nonnull aInviteUsers) {
        for (NSString* strId in aInviteUsers) {
            AgoraChatUserInfo *info = [[UserInfoStore sharedInstance] getUserInfoById:strId];
            if (info && (info.avatarUrl.length > 0 || info.nickname.length > 0)) {
                EaseCallUser* user = [EaseCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                [[EaseCallManager.sharedManager getEaseCallConfig] setUser:strId info:user];
            }
        }
        [EaseCallManager.sharedManager startInviteUsers:aInviteUsers callType:EaseCallTypeMultiAudio ext:aExt completion:nil];
    };
    confVC.modalPresentationStyle = UIModalPresentationPopover;
    [vc presentViewController:confVC animated:YES completion:nil];
}

- (void)callDidReceive:(EaseCallType)aType inviter:(NSString*_Nonnull)username ext:(NSDictionary*_Nullable)aExt
{
    AgoraChatUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
    if (info && (info.avatarUrl.length > 0 || info.nickname.length > 0)) {
        EaseCallUser *user = [EaseCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
        [[EaseCallManager.sharedManager getEaseCallConfig] setUser:username info:user];
    }
}

- (void)callDidOccurError:(EaseCallError*_Nonnull)aError
{
    
}

- (void)callDidRequestRTCTokenForAppId:(NSString*_Nonnull)aAppId channelName:(NSString*_Nonnull)aChannelName account:(NSString*_Nonnull)aUserAccount uid:(NSInteger)aAgoraUid
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSString *strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/token/rtcToken/v1?userAccount=%@&channelName=%@&appkey=%@",[AgoraChatClient sharedClient].currentUsername, aChannelName, AgoraChatClient.sharedClient.options.appkey];
    NSString *utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest *urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[AgoraChatClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",body);
            if(body) {
                NSString* resCode = [body objectForKey:@"code"];
                if([resCode isEqualToString:@"RES_0K"]) {
                    NSString* rtcToken = [body objectForKey:@"accessToken"];
                    NSNumber* uid = [body objectForKey:@"agoraUserId"];
                    [EaseCallManager.sharedManager setRTCToken:rtcToken channelName:aChannelName uid:[uid unsignedIntegerValue]];
                }
            }
        }
    }];

    [task resume];
}

- (void)remoteUserDidJoinChannel:( NSString*_Nonnull)aChannelName uid:(NSInteger)aUid username:(NSString*_Nullable)aUserName
{
    if (aUserName.length > 0) {
        AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUserName];
        if (userInfo && (userInfo.avatarUrl.length > 0 || userInfo.nickname.length > 0)) {
            EaseCallUser* user = [EaseCallUser userWithNickName:userInfo.nickname image:[NSURL URLWithString:userInfo.avatarUrl]];
            [[EaseCallManager.sharedManager getEaseCallConfig] setUser:aUserName info:user];
        }
    } else {
        [self _fetchUserMapsFromServer:aChannelName];
    }
}

- (void)callDidJoinChannel:(NSString*_Nonnull)aChannelName uid:(NSUInteger)aUid
{
    [self _fetchUserMapsFromServer:aChannelName];
}

- (void)_fetchUserMapsFromServer:(NSString*)aChannelName
{
    // 这里设置映射表，设置头像，昵称
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/channel/mapper?userAccount=%@&channelName=%@&appkey=%@",[AgoraChatClient sharedClient].currentUsername,aChannelName,[AgoraChatClient sharedClient].options.appkey];
    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[AgoraChatClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"mapperBody:%@",body);
            if (body) {
                NSString* resCode = [body objectForKey:@"code"];
                if([resCode isEqualToString:@"RES_0K"]) {
                    NSString* channelName = [body objectForKey:@"channelName"];
                    NSDictionary* result = [body objectForKey:@"result"];
                    NSMutableDictionary<NSNumber*,NSString*>* users = [NSMutableDictionary dictionary];
                    for (NSString *strId in result) {
                        NSString *username = [result objectForKey:strId];
                        NSNumber *uId = @([strId integerValue]);
                        [users setObject:username forKey:uId];
                        AgoraChatUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
                        if (info && (info.avatarUrl.length > 0 || info.nickname.length > 0)) {
                            EaseCallUser *user = [EaseCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                            [[EaseCallManager.sharedManager getEaseCallConfig] setUser:username info:user];
                        }
                    }
                    [EaseCallManager.sharedManager setUsers:users channelName:channelName];
                }
            }
        }
    }];

    [task resume];
}


- (void)showHint:(NSString *)hint
{
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = 180;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

#pragma mark - PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    NSString *str = [NSString stringWithFormat:@"%@", pushCredentials.token];
    NSString * tokenStr = [[[str stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"TOKEN =     %@",tokenStr);
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    NSDictionary *dic = [payload.dictionaryPayload objectForKey:@"aps"];
    NSLog(@"%@", dic);
    CXProviderConfiguration *configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:@""];
    CXProvider *provider = [[CXProvider alloc] initWithConfiguration:configuration];
    [provider setDelegate:self queue:dispatch_get_main_queue()];
    
    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
    callUpdate.hasVideo = NO;
    
    [provider reportNewIncomingCallWithUUID:NSUUID.UUID update:callUpdate completion:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - CXProviderDelegate
- (void)providerDidReset:(CXProvider *)provider {
    
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(nonnull CXAnswerCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performEndCallAction:(nonnull CXEndCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(nonnull CXSetMutedCallAction *)action {
    
}

@end
