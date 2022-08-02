//
//  EMDemoOptions.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/17.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "ACDDemoOptions.h"

#import <AgoraChat/AgoraChatOptions+PrivateDeploy.h>

static ACDDemoOptions *sharedOptions = nil;
@implementation ACDDemoOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initServerOptions];
        
        self.isAutoAcceptGroupInvitation = YES;
        self.deleteMessagesOnLeaveGroup = YES;
        self.isAutoTransferMessageAttachments = YES;
        self.isAutoDownloadThumbnail = YES;
        self.isSortMessageByServerTime = YES;
        self.isPriorityGetMsgFromServer = NO;
        
        self.isAutoLogin = YES;
        self.loggedInUsername = @"";
        self.loggedInPassword = @"";
        
        self.isChatTyping = NO;
        self.isAutoDeliveryAck = NO;
        
        self.isOfflineHangup = NO;
        
        self.isShowCallInfo = YES;
        self.isUseBackCamera = NO;
        
        self.isReceiveNewMsgNotice = YES;
        self.willRecord = NO;
        self.willMergeStrem = NO;
        self.enableConsoleLog = YES;
        
        self.enableCustomAudioData = NO;
        self.customAudioDataSamples = 48000;
        self.isSupportWechatMiniProgram = NO;
        self.isCustomServer = NO;
        self.isFirstLaunch = NO;
        self.locationAppkeyArray = [[NSMutableArray alloc]init];
        
        self.playVibration = YES;
        self.playNewMsgSound = YES;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        NSMutableArray *tempArray = [aDecoder decodeObjectForKey:kOptions_LocationAppkeyArray];
        if (tempArray == nil || [tempArray count] == 0) {
            self.locationAppkeyArray = [[NSMutableArray alloc]init];
            [self.locationAppkeyArray insertObject:Appkey atIndex:0];
        } else {
            self.locationAppkeyArray = tempArray;
        }
        self.appkey = [aDecoder decodeObjectForKey:kOptions_Appkey];
        if ([self.appkey length] == 0) {
            self.appkey = [self.locationAppkeyArray objectAtIndex:0];
        }
        self.apnsCertName = [aDecoder decodeObjectForKey:kOptions_ApnsCertname];
        self.usingHttpsOnly = [aDecoder decodeBoolForKey:kOptions_HttpsOnly];
        
        self.specifyServer = [aDecoder decodeBoolForKey:kOptions_SpecifyServer];
        self.chatPort = [aDecoder decodeIntForKey:kOptions_IMPort];
        self.chatServer = [aDecoder decodeObjectForKey:kOptions_IMServer];
        self.restServer = [aDecoder decodeObjectForKey:kOptions_RestServer];

        self.isAutoAcceptGroupInvitation = [aDecoder decodeBoolForKey:kOptions_AutoAcceptGroupInvitation];
        self.deleteMessagesOnLeaveGroup = [aDecoder decodeBoolForKey:kOptions_DeleteChatExitGroup];
        self.isAutoTransferMessageAttachments = [aDecoder decodeBoolForKey:kOptions_AutoTransMsgFile];
        self.isAutoDownloadThumbnail = [aDecoder decodeBoolForKey:kOptions_AutoDownloadThumb];
        self.isSortMessageByServerTime = [aDecoder decodeBoolForKey:kOptions_SortMessageByServerTime];
        self.isPriorityGetMsgFromServer = [aDecoder decodeBoolForKey:kOptions_PriorityGetMsgFromServer];
        
        self.isAutoLogin = [aDecoder decodeBoolForKey:kOptions_AutoLogin];
        self.loggedInUsername = [aDecoder decodeObjectForKey:kOptions_LoggedinUsername];
        self.loggedInPassword = [aDecoder decodeObjectForKey:kOptions_LoggedinPassword];
        
        self.isChatTyping = [aDecoder decodeBoolForKey:kOptions_ChatTyping];
        self.isAutoDeliveryAck = [aDecoder decodeBoolForKey:kOptions_AutoDeliveryAck];
        
        self.isOfflineHangup = [aDecoder decodeBoolForKey:kOptions_OfflineHangup];
        
        self.isShowCallInfo = [aDecoder decodeBoolForKey:kOptions_ShowCallInfo];
        self.isUseBackCamera = [aDecoder decodeBoolForKey:kOptions_UseBackCamera];

        self.isReceiveNewMsgNotice = [aDecoder decodeBoolForKey:kOptions_IsReceiveNewMsgNotice];
        self.willRecord = [aDecoder decodeBoolForKey:kOptions_WillRecord];
        self.willMergeStrem = [aDecoder decodeBoolForKey:kOptions_WillMergeStrem];
        self.enableConsoleLog = [aDecoder decodeBoolForKey:kOptions_EnableConsoleLog];
        
        self.enableCustomAudioData = [aDecoder decodeBoolForKey:kOptions_EnableCustomAudioData];
        self.customAudioDataSamples = [aDecoder decodeIntForKey:kOptions_CustomAudioDataSamples];
        self.isSupportWechatMiniProgram = [aDecoder decodeBoolForKey:kOptions_IsSupportWechatMiniProgram];
        self.isCustomServer = [aDecoder decodeBoolForKey:kOptions_IsCustomServer];
        self.isFirstLaunch = [aDecoder decodeBoolForKey:kOptions_IsFirstLaunch];
        self.language = [aDecoder decodeObjectForKey:kOptions_TranslateLanguage];
        
        self.playVibration = [aDecoder decodeBoolForKey:kOptions_playVibration];
        self.playNewMsgSound = [aDecoder decodeBoolForKey:kOptions_playNewMsgSound];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.appkey forKey:kOptions_Appkey];
    [aCoder encodeObject:self.apnsCertName forKey:kOptions_ApnsCertname];
    [aCoder encodeBool:self.usingHttpsOnly forKey:kOptions_HttpsOnly];
    
    [aCoder encodeBool:self.specifyServer forKey:kOptions_SpecifyServer];
    [aCoder encodeInt:self.chatPort forKey:kOptions_IMPort];
    [aCoder encodeObject:self.chatServer forKey:kOptions_IMServer];
    [aCoder encodeObject:self.restServer forKey:kOptions_RestServer];

    [aCoder encodeBool:self.isAutoAcceptGroupInvitation forKey:kOptions_AutoAcceptGroupInvitation];
    [aCoder encodeBool:self.deleteMessagesOnLeaveGroup forKey:kOptions_DeleteChatExitGroup];
    [aCoder encodeBool:self.isAutoTransferMessageAttachments forKey:kOptions_AutoTransMsgFile];
    [aCoder encodeBool:self.isAutoDownloadThumbnail forKey:kOptions_AutoDownloadThumb];
    [aCoder encodeBool:self.isSortMessageByServerTime forKey:kOptions_SortMessageByServerTime];
    [aCoder encodeBool:self.isPriorityGetMsgFromServer forKey:kOptions_PriorityGetMsgFromServer];
    
    [aCoder encodeBool:self.isAutoLogin forKey:kOptions_AutoLogin];
    [aCoder encodeObject:self.loggedInUsername forKey:kOptions_LoggedinUsername];
    [aCoder encodeObject:self.loggedInPassword forKey:kOptions_LoggedinPassword];
    
    [aCoder encodeBool:self.isChatTyping forKey:kOptions_ChatTyping];
    [aCoder encodeBool:self.isAutoDeliveryAck forKey:kOptions_AutoDeliveryAck];
    
    [aCoder encodeBool:self.isOfflineHangup forKey:kOptions_OfflineHangup];
    
    [aCoder encodeBool:self.isShowCallInfo forKey:kOptions_ShowCallInfo];
    [aCoder encodeBool:self.isUseBackCamera forKey:kOptions_UseBackCamera];
    
    [aCoder encodeBool:self.isReceiveNewMsgNotice forKey:kOptions_IsReceiveNewMsgNotice];
    [aCoder encodeBool:self.willRecord forKey:kOptions_WillRecord];
    [aCoder encodeBool:self.willMergeStrem forKey:kOptions_WillMergeStrem];
    [aCoder encodeBool:self.enableConsoleLog forKey:kOptions_EnableConsoleLog];
    
    [aCoder encodeBool:self.enableCustomAudioData forKey:kOptions_EnableCustomAudioData];
    [aCoder encodeInt:self.customAudioDataSamples forKey:kOptions_CustomAudioDataSamples];
    
    [aCoder encodeBool:self.isSupportWechatMiniProgram forKey:kOptions_IsSupportWechatMiniProgram];
    
    [aCoder encodeObject:self.locationAppkeyArray forKey:kOptions_LocationAppkeyArray];
    [aCoder encodeBool:self.isCustomServer forKey:kOptions_IsCustomServer];
    [aCoder encodeBool:self.isFirstLaunch forKey:kOptions_IsFirstLaunch];
    [aCoder encodeObject:self.language forKey:kOptions_TranslateLanguage];
    
    [aCoder encodeBool:self.playVibration forKey:kOptions_playVibration];
    [aCoder encodeBool:self.playNewMsgSound forKey:kOptions_playNewMsgSound];

}

- (id)copyWithZone:(nullable NSZone *)zone
{
    ACDDemoOptions *retModel = [[[self class] alloc] init];
    retModel.appkey = self.appkey;
    retModel.apnsCertName = self.apnsCertName;
    retModel.usingHttpsOnly = self.usingHttpsOnly;
    retModel.specifyServer = self.specifyServer;
    retModel.chatPort = self.chatPort;
    retModel.chatServer = self.chatServer;
    retModel.restServer = self.restServer;
    retModel.isAutoAcceptGroupInvitation = self.isAutoAcceptGroupInvitation;
    retModel.deleteMessagesOnLeaveGroup = self.deleteMessagesOnLeaveGroup;

    retModel.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments;
    retModel.isAutoDownloadThumbnail = self.isAutoDownloadThumbnail;
    retModel.isSortMessageByServerTime = self.isSortMessageByServerTime;
    retModel.isPriorityGetMsgFromServer = self.isPriorityGetMsgFromServer;
    retModel.isAutoLogin = self.isAutoLogin;
    retModel.loggedInUsername = self.loggedInUsername;
    retModel.loggedInPassword = self.loggedInPassword;
    retModel.isChatTyping = self.isChatTyping;
    retModel.isAutoDeliveryAck = self.isAutoDeliveryAck;
    retModel.isOfflineHangup = self.isOfflineHangup;
    retModel.isShowCallInfo = self.isShowCallInfo;
    retModel.isUseBackCamera = self.isUseBackCamera;
    retModel.isReceiveNewMsgNotice = self.isReceiveNewMsgNotice;
    retModel.willRecord = self.willRecord;
    retModel.willMergeStrem = self.willMergeStrem;
    retModel.enableConsoleLog = self.enableConsoleLog;
    retModel.enableCustomAudioData = self.enableCustomAudioData;
    retModel.customAudioDataSamples = self.customAudioDataSamples;
    retModel.isSupportWechatMiniProgram = self.isSupportWechatMiniProgram;
    retModel.isCustomServer = self.isCustomServer;
    retModel.locationAppkeyArray = self.locationAppkeyArray;
    retModel.isFirstLaunch = self.isFirstLaunch;
    retModel.language = self.language;
    retModel.playVibration = self.playVibration;
    retModel.playNewMsgSound = self.playNewMsgSound;
    
    return retModel;
}

- (void)setLoggedInUsername:(NSString *)loggedInUsername
{
    if (![_loggedInUsername isEqualToString:loggedInUsername]) {
        _loggedInUsername = loggedInUsername;
        _loggedInPassword = @"";
    }
}

#pragma mark - Private

- (void)_initServerOptions
{

    self.appkey = Appkey;
#if DEBUG
    self.apnsCertName = @"ChatDemoDevPush";
#else
    self.apnsCertName = @"ChatDemoProPush";
#endif
    self.usingHttpsOnly = YES;
    //self.specifyServer = YES;
    self.specifyServer = NO;

    self.isAutoLogin = YES;
    
}

#pragma mark - Public

- (void)archive
{
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:self toFile:file];
}

- (AgoraChatOptions *)toOptions
{
    AgoraChatOptions *retOpt = [AgoraChatOptions optionsWithAppkey:self.appkey];
    retOpt.apnsCertName = self.apnsCertName;
    retOpt.usingHttpsOnly = self.usingHttpsOnly;

    //self.specifyServer = YES;
    if (self.specifyServer) {
        retOpt.enableDnsConfig = NO;
        retOpt.chatPort = self.chatPort;
        retOpt.chatServer = self.chatServer;
        retOpt.restServer = self.restServer;
    }
    
    self.isAutoLogin = YES;
    retOpt.isAutoLogin = self.isAutoLogin;
    retOpt.isAutoAcceptGroupInvitation = self.isAutoAcceptGroupInvitation;
    retOpt.isDeleteMessagesWhenExitGroup = self.deleteMessagesOnLeaveGroup;
    retOpt.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments;
    retOpt.autoDownloadThumbnail = self.isAutoDownloadThumbnail;
    retOpt.sortMessageByServerTime = self.isSortMessageByServerTime;
    NSString *apnsCertName = nil;
    #if DEBUG
        apnsCertName = @"ChatDemoDevPush";
        [retOpt setPushKitCertName:@"com.easemob.enterprise.demo.ui.voip"];
    #else
        apnsCertName = @"ChatDemoProPush";
        [retOpt setPushKitCertName:@"com.easemob.enterprise.demo.ui.pro.voip"];
    #endif
    [retOpt setApnsCertName:apnsCertName];
    retOpt.enableDeliveryAck = self.isAutoDeliveryAck;
    retOpt.enableConsoleLog = YES;
    retOpt.enableFpa = YES;
    return retOpt;
}

#pragma mark - Class Methods

+ (instancetype)sharedOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOptions = ACDDemoOptions.customOptions;
        if (!sharedOptions) {
            sharedOptions = ACDDemoOptions.defaultOptions;
            [sharedOptions archive];
        }
    });
    
    return sharedOptions;
}

+ (instancetype)customOptions {
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:file];
}

+ (instancetype)defaultOptions {
    return [[ACDDemoOptions alloc] init];
}

+ (void)reInitAndSaveServerOptions
{
    ACDDemoOptions *demoOptions = [ACDDemoOptions sharedOptions];
    [demoOptions _initServerOptions];
    
    [demoOptions archive];
}

+ (void)updateAndSaveServerOptions:(NSDictionary *)aDic
{
    NSString *appkey = [aDic objectForKey:kOptions_Appkey];
    NSString *apns = [aDic objectForKey:kOptions_ApnsCertname];
    BOOL httpsOnly = [[aDic objectForKey:kOptions_HttpsOnly] boolValue];
    if ([appkey length] == 0) {
        appkey = Appkey;
    }
    if ([apns length] == 0) {
#if DEBUG
        apns = @"ChatDemoDevPush";
#else
        apns = @"ChatDemoProPush";
#endif

    }
    
    ACDDemoOptions *demoOptions = [ACDDemoOptions sharedOptions];
    demoOptions.appkey = appkey;
    demoOptions.apnsCertName = apns;
    demoOptions.usingHttpsOnly = httpsOnly;
    demoOptions.isAutoLogin = YES;
    
    int specifyServer = [[aDic objectForKey:kOptions_SpecifyServer] intValue];
    demoOptions.specifyServer = NO;
    if (specifyServer != 0) {
        demoOptions.specifyServer = YES;
        
        NSString *imServer = [aDic objectForKey:kOptions_IMServer];
        NSString *imPort = [aDic objectForKey:kOptions_IMPort];
        NSString *restServer = [aDic objectForKey:kOptions_RestServer];
        if ([imServer length] > 0 && [restServer length] > 0 && [imPort length] > 0) {
            demoOptions.chatPort = [imPort intValue];
            demoOptions.chatServer = imServer;
            demoOptions.restServer = restServer;
        }
    }
    
    [demoOptions archive];
}

@end
