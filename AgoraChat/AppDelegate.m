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





@interface AppDelegate () <AgoraChatClientDelegate,UNUserNotificationCenterDelegate>
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *nickName;

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
//    AgoraLaunchViewController *launch = [[AgoraLaunchViewController alloc] init];
//    self.window.rootViewController = launch;
    [self loadViewController];
    
    [self.window makeKeyAndVisible];
    
    [self _registerAPNS];
    [self registerNotifications];
    
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
    NSString *apnsCertName = nil;
#if ChatDemo_DEBUG
    apnsCertName = @"ChatDemoDevPush";
#else
    apnsCertName = @"ChatDemoProPush";
#endif
    
    [options setApnsCertName:apnsCertName];
    [options setEnableDeliveryAck:YES];
    [options setEnableConsoleLog:YES];
    [options setIsDeleteMessagesWhenExitGroup:NO];
    [options setIsDeleteMessagesWhenExitChatRoom:NO];
    [options setUsingHttpsOnly:YES];
    [options setIsAutoLogin:YES];

#warning 国内部署设置
//    [self internalSpecOption:options];
    
    [EaseChatKitManager initWithAgoraChatOptions:options];

}

- (void)internalSpecOption:(AgoraChatOptions *)option {
    option.enableDnsConfig = NO;
    option.restServer = @"https://a1.chat.agora.io";
    option.chatServer = @"https://msync-im-tls.chat.agora.io";
    option.chatPort = 6717;
}

- (void)loadViewController {
    BOOL isAutoLogin = [AgoraChatClient sharedClient].isAutoLogin;
    if (isAutoLogin) {
        [self loadMainPage];
    } else {
        [self loadLoginPage];
    }
  
//    [self loadMainPage];

}


- (void)loginStateChange:(NSNotification *)notification
{
    self.userName = (NSString *)notification.userInfo[@"userName"];
    self.nickName = (NSString *)notification.userInfo[@"nickName"];
    
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {
        [self loadMainPage];
        
    } else {
        [self loadLoginPage];
    }
}

- (void)tokenWillExpire:(int)aErrorCode
{
    if (aErrorCode == AgoraChatErrorTokeWillExpire) {
        NSLog(@"%@", [NSString stringWithFormat:@"========= token expire rennew token ! code : %d",aErrorCode]);
        [[AgoraChatHttpRequest sharedManager] loginToApperServer:self.userName nickName:self.nickName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"renewToken.ok", @"Ok"), nil];
                [alert show];
            });
        }];
    }
}

- (void)tokenDidExpire:(int)aErrorCode
{
    if (aErrorCode == AgoraChatErrorTokenExpire || aErrorCode == 401) {
        void (^finishBlock) (NSString *aName, AgoraChatError *aError) = ^(NSString *aName, AgoraChatError *aError) {
            if (!aError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"login.succeed", @"Sign in succeed") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
                    [alertError show];
                });
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
        };
        
        if (self.userName.length == 0 || self.nickName.length == 0) return;
        //unify token login
        __weak typeof(self) weakself = self;
        [[AgoraChatHttpRequest sharedManager] loginToApperServer:self.userName nickName:self.nickName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *alertStr = nil;
                if (response && response.length > 0) {
                    NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                    NSString *token = [responsedict objectForKey:@"accessToken"];
                    NSString *loginName = [responsedict objectForKey:@"chatUserName"];
                    if (token && token.length > 0) {
                        [[AgoraChatClient sharedClient] loginWithUsername:[loginName lowercaseString] agoraToken:token completion:finishBlock];
                        return;
                    } else {
                        alertStr = NSLocalizedString(@"login analysis token failure", @"analysis token failure");
                    }
                } else {
                    alertStr = NSLocalizedString(@"login appserver failure", @"Sign in appserver failure");
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"loginAppServer.ok", @"Ok"), nil];
                [alert show];
            });
        }];
    }
}

- (void)loadMainPage {
    AgoraMainViewController *main = [[AgoraMainViewController alloc] init];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:main];
//    navigationController.interactivePopGestureRecognizer.delegate = (id)self;
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
    [[AgoraChatClient sharedClient] applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[AgoraChatClient sharedClient] applicationWillEnterForeground:application];
    
    if ([AgoraChatDemoHelper shareHelper].pushVC) {
        [[AgoraChatDemoHelper shareHelper].pushVC reloadNotificationStatus];
    }
    
    if ([AgoraChatDemoHelper shareHelper].settingsVC) {
        [[AgoraChatDemoHelper shareHelper].settingsVC reloadNotificationStatus];
    }
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", @"Fail to register apns")
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
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
    }
}

@end
