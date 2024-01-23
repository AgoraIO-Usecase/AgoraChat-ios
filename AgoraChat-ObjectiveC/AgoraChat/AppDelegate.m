/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and rAgoraains
 * the property of Hyphenate Inc.
 */

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>
#import "AgoraMainViewController.h"
#import "AgoraLoginViewController.h"

#import "AgoraLaunchViewController.h"
#import "AgoraChatDEMoHelper.h"
#import "AgoraChatHttpRequest.h"

#import <AgoraChat/AgoraChatOptions+PrivateDeploy.h>
#import "AgoraChatCallKitManager.h"
#import "PresenceManager.h"
@interface AppDelegate () <AgoraChatClientDelegate,UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *nickName;

@property (nonatomic, strong) AgoraChatCallKitManager *callKitManager;

@property (nonatomic, strong) UIImageView* lockView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // set default app tabbar
    [[ACDAppStyle shareAppStyle] defaultStyle];
    
    // Override point for customization after application launch.
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        [[UITabBar appearance] setBarTintColor:DefaultBarColor];
        [[UITabBar appearance] setTintColor:KermitGreenTwoColor];
        [[UINavigationBar appearance] setBarTintColor:DefaultBarColor];
        [[UINavigationBar appearance] setTintColor:AlmostBlackColor];
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
    [self initAccount];
    [self initUIKit];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    [self loadViewController];
    
    [self.window makeKeyAndVisible];
    
    [self _registerAPNS];
    [self registerNotifications];
    
    NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *agoraUid = [shareDefault objectForKey:USER_AGORA_UID];
    if (agoraUid) {
        [AgoraChatCallKitManager.shareManager updateAgoraUid:agoraUid.integerValue];
    }
    // No save cache.db in GET method
    NSURLCache* cache = [NSURLCache sharedURLCache];
    cache.memoryCapacity = 0;
    cache.diskCapacity = 0;
    return YES;
}

- (void)initAccount
{
    NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
    self.userName = [shareDefault objectForKey:USER_NAME] ? (NSString *)[shareDefault objectForKey:USER_NAME] : @"";
    self.nickName = [shareDefault objectForKey:USER_NICKNAME] ? (NSString *)[shareDefault objectForKey:USER_NICKNAME] : @"";
}

- (void)initUIKit
{
    AgoraChatOptions *options = [AgoraChatOptions optionsWithAppkey:Appkey];

    // Hyphenate cert keys
//    NSString *apnsCertName = nil;
//#if DEBUG
//    apnsCertName = @"ChatDemoDevPush";
//    [options setPushKitCertName:@"com.easemob.enterprise.demo.ui.voip"];
//#else
//    apnsCertName = @"ChatDemoProPush";
//    [options setPushKitCertName:@"com.easemob.enterprise.demo.ui.pro.voip"];
//#endif
//
//    [options setApnsCertName:apnsCertName];
//
//    [options setEnableDeliveryAck:YES];
//    [options setEnableConsoleLog:YES];
//    [options setIsDeleteMessagesWhenExitGroup:NO];
//    [options setIsDeleteMessagesWhenExitChatRoom:NO];
//    [options setUsingHttpsOnly:YES];
//    [options setIsAutoLogin:YES];

#warning 国内部署设置
    //[self internalSpecOption:options];
    
//    [EaseChatKitManager initWithAgoraChatOptions:options];

    ACDDemoOptions *demoOptions = [ACDDemoOptions sharedOptions];
    [EaseChatKitManager initWithAgoraChatOptions:[demoOptions toOptions]];
}

- (void)internalSpecOption:(AgoraChatOptions *)option {
    option.enableDnsConfig = NO;
    option.restServer = @"https://a1-test.easemob.com";
    option.chatServer = @"52.80.99.104";
    option.chatPort = 6717;
    
    [option setRestServer:@"http://a1-test.easemob.com"];
    [option setChatServer:@"52.80.99.104"];
    [option setChatPort:6717];
}

- (void)loadViewController {
    BOOL isAutoLogin = [AgoraChatClient sharedClient].isAutoLogin;
    if (isAutoLogin) {
        [self loadMainPage];
    } else {
        [self loadLoginPage];
    }
  
}


- (void)loginStateChange:(NSNotification *)notification
{
    self.userName = (NSString *)notification.userInfo[@"userName"];
    self.nickName = (NSString *)notification.userInfo[@"nickName"];
    
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {
        [self loadMainPage];
        
    } else {
        ACDDemoOptions.sharedOptions.tokenExpiredTimestamp = 0;
        [self loadLoginPage];
    }
}

- (void)tokenWillExpire:(AgoraChatErrorCode)aErrorCode
{
    if (aErrorCode == AgoraChatErrorTokeWillExpire) {
        NSLog(@"%@", [NSString stringWithFormat:@"========= token expire rennew token ! code : %d",aErrorCode]);
        NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
        [[AgoraChatHttpRequest sharedManager] loginToApperServer:self.userName pwd:[shareDefault objectForKey:USER_PWD] completion:^(NSInteger statusCode, NSString * _Nonnull response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *alertStr = nil;
                if (response && response.length > 0) {
                    NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                    NSString *token = [responsedict objectForKey:@"accessToken"];
                    if (token && token.length > 0) {
                        alertStr = NSLocalizedString(@"login appserver succeed", @"login appserver succeed");
                        if (aErrorCode == AgoraChatErrorTokeWillExpire) {
                            AgoraChatError *error = [[AgoraChatClient sharedClient] renewToken:token];
                            if (error) {
                                alertStr = NSLocalizedString(@"renew token failure", @"renew token failure");
                            } else {
                                alertStr = NSLocalizedString(@"renew token success", @"renew token success");
                            }
                        }
                    } else {
                        alertStr = NSLocalizedString(@"login analysis token failure", @"analysis token failure");
                    }
                } else {
                    alertStr = NSLocalizedString(@"login appserver failure", @"Sign in appserver failure");
                }
                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"renewToken.ok", @"Ok"), nil];
//                [alert show];
                
                [self.window.rootViewController showHint:alertStr];
            });
        }];
    }
}

- (void)tokenDidExpire:(AgoraChatErrorCode)aErrorCode
{
    __block NSString* nickName = nil;
    if (aErrorCode == AgoraChatErrorTokenExpire || aErrorCode == 401) {
        void (^finishBlock) (NSString *aName, AgoraChatError *aError) = ^(NSString *aName, AgoraChatError *aError) {
            if (!aError || aError.code == AgoraChatErrorUserAlreadyLoginSame) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_UPDATE_CONVERSATIONS object:nil];
                return ;
            }
            
            NSString *errorDes = NSLocalizedString(@"login.failure", @"login failure");
            switch (aError.code) {
                case AgoraChatErrorServerNotReachable:
                    errorDes = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                    break;
                case AgoraChatErrorNetworkUnavailable:
                    errorDes = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                    break;
                case AgoraChatErrorServerTimeout:
                    errorDes = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                    break;
                case AgoraChatErrorUserAlreadyExist:
                    errorDes = NSLocalizedString(@"login.taken", @"Username taken");
                    break;
                default:
                    errorDes = NSLocalizedString(@"login.failure", @"login failure");
                    break;
            }
            UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:errorDes delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
            [alertError show];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO userInfo:@{@"userName":@"",@"nickName":@""}];
        };
        
        NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
        NSString *pwd = [shareDefault objectForKey:USER_PWD];
        if (self.userName.length == 0 || pwd.length == 0) return;
        //unify token login
        [[AgoraChatHttpRequest sharedManager] loginToApperServer:self.userName pwd:pwd completion:^(NSInteger statusCode, NSString * _Nonnull response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *alertStr = nil;
                if (response && response.length > 0) {
                    NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                    NSString *token = [responsedict objectForKey:@"accessToken"];
                    NSString *loginName = [responsedict objectForKey:@"chatUserName"];
                    nickName = [responsedict objectForKey:@"chatUserNickname"];
                    NSInteger agoraUid = [responsedict[@"agoraUid"] integerValue];
                    NSInteger expireTime = [[responsedict objectForKey:@"expireTimestamp"] integerValue];
                    ACDDemoOptions.sharedOptions.tokenExpiredTimestamp = expireTime;
                    if (token && token.length > 0) {
                        [[AgoraChatClient sharedClient] loginWithUsername:[loginName lowercaseString] agoraToken:token completion:finishBlock];
                        return;
                    } else {
                        alertStr = NSLocalizedString(@"login analysis token failure", @"analysis token failure");
                    }
                } else {
                    alertStr = NSLocalizedString(@"login appserver failure", @"Sign in appserver failure");
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO userInfo:@{@"userName":@"",@"nickName":@""}];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"loginAppServer.ok", @"Ok"), nil];
                [alert show];
            });
        }];
    }
}

- (void)loadMainPage {
    // update local db group list
    [[AgoraChatClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:0 pageSize:200 completion:^(NSArray *aList, AgoraChatError *aError) {
        NSArray *ary = [[AgoraChatClient sharedClient].groupManager getJoinedGroups];
        [AgoraChatClient.sharedClient.chatManager getAllConversations];
    }];
    
    AgoraMainViewController *main = [[AgoraMainViewController alloc] init];
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    if (!navigationController || (navigationController && ![navigationController.viewControllers[0] isKindOfClass:[AgoraMainViewController class]])) {
        navigationController = [[UINavigationController alloc] initWithRootViewController:main];
    }
    navigationController.navigationBarHidden = YES;
    self.window.rootViewController = navigationController;
    [AgoraChatDemoHelper shareHelper].mainVC = main;
}

- (void)loadLoginPage {
    AgoraLoginViewController *login = [[AgoraLoginViewController alloc] init];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:login];
    navigationController.navigationBarHidden = YES;
    self.window.rootViewController = navigationController;
    [AgoraChatDemoHelper shareHelper].mainVC = nil;

}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.window addSubview:self.lockView];
    self.lockView.frame = self.window.frame;
    [[AgoraChatClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.lockView removeFromSuperview];
    do {
        NSInteger tokenExpiredTs = ACDDemoOptions.sharedOptions.tokenExpiredTimestamp;
        if(ACDDemoOptions.sharedOptions.tokenExpiredTimestamp > 1600000000000) {
            NSInteger currentTs = [[NSDate date] timeIntervalSince1970] * 1000;
            if ( currentTs > tokenExpiredTs) {
                [AgoraChatClient.sharedClient log:[NSString stringWithFormat:@"applicationWillEnterForeground begin logout!!currentTs:%ld,tokenExpiredTs:%ld",currentTs,tokenExpiredTs]];
                [AgoraChatClient.sharedClient logout:NO];
                [self tokenDidExpire:AgoraChatErrorTokenExpire];
                break;
            }
        }
        [[AgoraChatClient sharedClient] applicationWillEnterForeground:application];
        
        if ([AgoraChatDemoHelper shareHelper].pushVC) {
            [[AgoraChatDemoHelper shareHelper].pushVC reloadNotificationStatus];
        }
        
        if ([AgoraChatDemoHelper shareHelper].settingsVC) {
            [[AgoraChatDemoHelper shareHelper].settingsVC reloadNotificationStatus];
        }
    } while(0);
}

- (UIImageView *)lockView
{
    if (!_lockView) {
        _lockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchImage"]];
    }
    return _lockView;
}

#pragma mark - Remote Notification Registration

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AgoraChatClient sharedClient] bindDeviceToken:deviceToken];
        NSLog(@"%s deviceToken:%@",__func__,deviceToken);
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self showAlertWithTitle:NSLocalizedString(@"apns.failToRegisterApns", @"Fail to register apns") message:error.description];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%s ",__func__);

    [[AgoraChatClient sharedClient] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%s ",__func__);
    
    if ([AgoraChatDemoHelper shareHelper].mainVC) {
        [[AgoraChatDemoHelper shareHelper].mainVC didReceiveLocalNotification:notification];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    [[AgoraChatClient sharedClient] application:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
//    if (gMainController) {
//        [gMainController didReceiveUserNotification:response.notification];
//    }
    completionHandler();
}

#pragma mark - AgoraChatPushManagerDelegateDevice

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%s push content:%@",__func__,str);
}


- (void)_registerAPNS
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
#endif
            }
        }];
        return;
    }
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
#endif
}


#pragma mark - delegate registration

- (void)registerNotifications
{
    [self unregisterNotifications];
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications
{
    [[AgoraChatClient sharedClient] removeDelegate:self];
}

#pragma mark - AgoraChatClientDelegate
- (void)autoLoginDidCompleteWithError:(AgoraChatError *)aError
{
    if (aError) {
        [self loadLoginPage];
        
    }else {
        [self test];
    }
}

- (void)test
{
    AgoraChatConversation* conversation = [AgoraChatClient.sharedClient.chatManager getConversationWithConvId:@"conversatinsId"];
    NSInteger ts = NSDate.date.timeIntervalSince1970 * 1000;
    [conversation removeMessagesStart:(ts - 60*60*1000) to:ts];
}

@end
