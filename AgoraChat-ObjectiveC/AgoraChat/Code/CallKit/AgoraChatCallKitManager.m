//
//  AgoraChatCallKitManager.m
//  AgoraChat
//
//  Created by 冯钊 on 2022/4/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraChatCallKitManager.h"

#import "AgoraChatCallConfig.h"
#import "AgoraChatCallManager.h"
#import "UserInfoStore.h"
#import "ConfInviteUsersViewController.h"
#import "AgoraMemberSelectViewController.h"

@import AVFAudio;
@import AgoraChat;

@interface AgoraChatCallKitManager() <AgoraChatCallDelegate>

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
        AgoraChatCallConfig *config = [[AgoraChatCallConfig alloc] init];
        config.agoraAppId = @"15cb0d28b87b425ea613fc46f7c9f974";
        config.enableRTCTokenValidate = YES;
        config.enableIosCallKit = YES;

        [AgoraChatCallManager.sharedManager initWithConfig:config delegate:self];
    }
    return self;
}

- (void)updateAgoraUid:(NSInteger)agoraUid
{
    [AgoraChatCallManager.sharedManager getAgoraChatCallConfig].agoraUid = agoraUid;
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
        AgoraChatCallUser *user = [AgoraChatCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
        [[AgoraChatCallManager.sharedManager getAgoraChatCallConfig] setUser:userId info:user];
    }
    [AgoraChatCallManager.sharedManager startSingleCallWithUId:userId type:AgoraChatCallType1v1Audio ext:nil completion:^(NSString * callId, AgoraChatCallError * aError) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000), dispatch_get_main_queue(), ^{
            [conversation loadMessagesStartFromId:msgId count:50 searchDirection:msgId ? AgoraChatMessageSearchDirectionDown : AgoraChatMessageSearchDirectionUp completion:^(NSArray *aMessages, AgoraChatError *aError) {
                if (aMessages.count) {
                    [self insertLocationCallRecord:aMessages];
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
        AgoraChatCallUser* user = [AgoraChatCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
        [[AgoraChatCallManager.sharedManager getAgoraChatCallConfig] setUser:userId info:user];
    }
    [AgoraChatCallManager.sharedManager startSingleCallWithUId:userId type:AgoraChatCallType1v1Video ext:nil completion:^(NSString * callId, AgoraChatCallError * aError) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000), dispatch_get_main_queue(), ^{
            [conversation loadMessagesStartFromId:msgId count:50 searchDirection:msgId ? AgoraChatMessageSearchDirectionDown : AgoraChatMessageSearchDirectionUp completion:^(NSArray *aMessages, AgoraChatError *aError) {
                if (aMessages.count) {
                    [self insertLocationCallRecord:aMessages];
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
                AgoraChatCallUser *user = [AgoraChatCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                [[AgoraChatCallManager.sharedManager getAgoraChatCallConfig] setUser:strId info:user];
            }
        }
        [AgoraChatCallManager.sharedManager startInviteUsers:aInviteUsers groupId:groupId callType:AgoraChatCallTypeMultiAudio ext:@{
            @"groupId":groupId
        } completion:^(NSString * callId, AgoraChatCallError * aError) {
            
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
                AgoraChatCallUser *user = [AgoraChatCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                [[AgoraChatCallManager.sharedManager getAgoraChatCallConfig] setUser:strId info:user];
            }
        }
        [AgoraChatCallManager.sharedManager startInviteUsers:aInviteUsers groupId:groupId callType:AgoraChatCallTypeMultiVideo ext:@{
            @"groupId": groupId
        } completion:^(NSString *callId, AgoraChatCallError *aError) {
            
        }];
    };
    
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    [viewController presentViewController:controller animated:YES completion:nil];
}

- (void)callDidEnd:(NSString*_Nonnull)aChannelName reason:(AgoraChatCallEndReason)aReason time:(int)aTm type:(AgoraChatCallType)aType
{
    NSString *msg = @"";
    switch (aReason) {
        case AgoraChatCallEndReasonAnswerOtherDevice:
            msg = NSLocalizedString(@"call.otherDeviceAnswer", nil);
            break;
        case AgoraChatCallEndReasonRefuseOtherDevice:
            msg = NSLocalizedString(@"call.otherDeviceRefuse", nil);
            break;
        case AgoraChatCallEndReasonBusy:
            msg = NSLocalizedString(@"call.busy", nil);
            break;
        case AgoraChatCallEndReasonRemoteRefuse:
            msg = NSLocalizedString(@"call.refuse", nil);
            break;
        case AgoraChatCallEndReasonNoResponse:
            msg = NSLocalizedString(@"call.noanswer", nil);
            break;
        case AgoraChatCallEndReasonHangup:
            break;
        default:
            break;
    }
    if (msg.length > 0) {
        [self showHint:msg];
    }
}

- (void)multiCallDidInvitingWithCurVC:(UIViewController *)vc callType:(AgoraChatCallType)callType excludeUsers:(NSArray<NSString *> *)users ext:(NSDictionary *)aExt
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
                AgoraChatCallUser *user = [AgoraChatCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                [[AgoraChatCallManager.sharedManager getAgoraChatCallConfig] setUser:strId info:user];
            }
        }
        [AgoraChatCallManager.sharedManager startInviteUsers:aInviteUsers groupId:groupId callType:AgoraChatCallTypeMultiAudio ext:aExt completion:nil];
    };
    confVC.modalPresentationStyle = UIModalPresentationPopover;
    [vc presentViewController:confVC animated:YES completion:nil];
}

- (void)callDidReceive:(AgoraChatCallType)aType inviter:(NSString*_Nonnull)username ext:(NSDictionary*_Nullable)aExt
{
    AgoraChatUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
    if (info && (info.avatarUrl.length > 0 || info.nickname.length > 0)) {
        AgoraChatCallUser *user = [AgoraChatCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
        [[AgoraChatCallManager.sharedManager getAgoraChatCallConfig] setUser:username info:user];
    }
}

- (void)callDidOccurError:(AgoraChatCallError *_Nonnull)aError
{
    
}

- (void)callDidRequestRTCTokenForAppId:(NSString*_Nonnull)aAppId channelName:(NSString*_Nonnull)aChannelName account:(NSString*_Nonnull)aUserAccount uid:(NSInteger)aAgoraUid
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *strUrl = [NSString stringWithFormat:@"https://a41.chat.agora.io/token/rtc/channel/%@/agorauid/%@?userAccount=%@", aChannelName, @(aAgoraUid), aUserAccount];
    NSString *utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest *urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[AgoraChatClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            return;
        }
        NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",body);
        if (!body) {
            return;
        }
        NSString *resCode = [body objectForKey:@"code"];
        if ([resCode isEqualToString:@"RES_OK"]) {
            NSString* rtcToken = [body objectForKey:@"accessToken"];
            [AgoraChatCallManager.sharedManager setRTCToken:rtcToken channelName:aChannelName uid:aAgoraUid];
        }
    }];

    [task resume];
}

- (void)remoteUserDidJoinChannel:( NSString*_Nonnull)aChannelName uid:(NSInteger)aUid username:(NSString*_Nullable)aUserName
{
    if (aUserName.length > 0) {
        AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUserName];
        if (userInfo && (userInfo.avatarUrl.length > 0 || userInfo.nickname.length > 0)) {
            AgoraChatCallUser* user = [AgoraChatCallUser userWithNickName:userInfo.nickname image:[NSURL URLWithString:userInfo.avatarUrl]];
            [[AgoraChatCallManager.sharedManager getAgoraChatCallConfig] setUser:aUserName info:user];
        }
    } else {
        [self _fetchUserMapsFromServer:aChannelName];
    }
}

- (void)callDidJoinChannel:(NSString*_Nonnull)aChannelName uid:(NSUInteger)aUid
{
    [self _fetchUserMapsFromServer:aChannelName];
}

- (void)insertLocationCallRecord:(NSArray *)messages
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AGORA_CHAT_CALL_KIT_COMMMUNICATE_RECORD object:@{@"msg":messages}];//刷新页面
}

- (void)_fetchUserMapsFromServer:(NSString*)aChannelName
{
    // 这里设置映射表，设置头像，昵称
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSString *strUrl = [NSString stringWithFormat:@"https://a41.chat.agora.io/agora/channel/mapper?channelName=%@&userAccount=%@", aChannelName, [AgoraChatClient sharedClient].currentUsername];
    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[AgoraChatClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            return;
        }
        NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"mapperBody:%@",body);
        if (!body) {
            return;
        }
        NSString *resCode = [body objectForKey:@"code"];
        if ([resCode isEqualToString:@"RES_OK"]) {
            NSString* channelName = [body objectForKey:@"channelName"];
            NSDictionary* result = [body objectForKey:@"result"];
            NSMutableDictionary<NSNumber*,NSString*>* users = [NSMutableDictionary dictionary];
            for (NSString *strId in result) {
                NSString *username = [result objectForKey:strId];
                NSNumber *uId = @([strId integerValue]);
                [users setObject:username forKey:uId];
                AgoraChatUserInfo* info = [[UserInfoStore sharedInstance] getUserInfoById:username];
                if (info && (info.avatarUrl.length > 0 || info.nickname.length > 0)) {
                    AgoraChatCallUser *user = [AgoraChatCallUser userWithNickName:info.nickname image:[NSURL URLWithString:info.avatarUrl]];
                    [[AgoraChatCallManager.sharedManager getAgoraChatCallConfig] setUser:username info:user];
                }
            }
            [AgoraChatCallManager.sharedManager setUsers:users channelName:channelName];
        }
    }];

    [task resume];
}

- (void)showHint:(NSString *)hint
{
    UIWindow *win = [self getKeyWindow];
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

- (UIWindow *)getKeyWindow
{
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* scene in UIApplication.sharedApplication.connectedScenes) {
            if (@available(iOS 15.0, *)) {
                return scene.keyWindow;
            } else {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            }
        }
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
    return nil;
}

@end
