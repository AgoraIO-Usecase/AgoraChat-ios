//
//  AppDelegate.swift
//  AgoraChat-Swift
//
//  Created by 朱继超 on 2024/6/26.
//

import UIKit
import chat_uikit
import AgoraChat
import UserNotifications
import SwiftFFDBHotFix

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
        
    @UserDefault("EaseChatDemoPreferencesTheme", defaultValue: 1) var theme: UInt
    
    @UserDefault("EaseChatMessageTranslation", defaultValue: true) var enableTranslation: Bool
    
    @UserDefault("EaseChatMessageReaction", defaultValue: true) var messageReaction: Bool
    
    @UserDefault("EaseChatCreateMessageThread", defaultValue: true) var messageThread: Bool
    
    @UserDefault("EaseChatDemoPreferencesBlock", defaultValue: true) var block: Bool
    
    @UserDefault("EaseChatDemoUserId", defaultValue: "") var userName
    
    @UserDefault("EaseChatDemoUserPassword", defaultValue: "") var password

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setupEaseChatUIKit()
        self.setupEaseChatUIKitConfig()
        self.registerRemoteNotification()
        return true
    }
    
    private func setupEaseChatUIKit() {
        let options = ChatOptions(appkey: AppKey)
        options.includeSendMessageInMessageListener = true
        options.isAutoLogin = true
        options.enableConsoleLog = true
        options.usingHttpsOnly = true
        options.deleteMessagesOnLeaveGroup = false
        options.enableDeliveryAck = true
        options.enableRequireReadAck = true
        //Simulator can't use APNS, so we need to judge whether it is a real machine.
        #if DEBUG
        options.apnsCertName = "ChatDemoDevPush"
        #else
        options.apnsCertName = "ChatDemoProPush"
        #endif
        
        
        //Set up EaseChatUIKit
        _ = EaseChatUIKitClient.shared.setup(option: options)
        EaseChatUIKitClient.shared.registerUserStateListener(self)
        _ = PresenceManager.shared
    }
    
    private func setupEaseChatUIKitConfig() {
        //Set the theme of the chat demo UI.
        if self.theme == 0 {
            Appearance.avatarRadius = .extraSmall
            Appearance.chat.inputBarCorner = .extraSmall
            Appearance.alertStyle = .small
            Appearance.chat.bubbleStyle = .withArrow
        } else {
            Appearance.avatarRadius = .large
            Appearance.chat.inputBarCorner = .large
            Appearance.alertStyle = .large
            Appearance.chat.bubbleStyle = .withMultiCorner
        }
        Appearance.hiddenPresence = false
        Appearance.chat.enableTyping = true
        Appearance.contact.enableBlock = self.block
        //Enable message translation
        Appearance.chat.enableTranslation = self.enableTranslation
        if Appearance.chat.enableTranslation {
            let preferredLanguage = NSLocale.preferredLanguages[0]
            if preferredLanguage.starts(with: "zh-Hans") || preferredLanguage.starts(with: "zh-Hant") {
                Appearance.chat.targetLanguage = .Chinese
            } else {
                Appearance.chat.targetLanguage = .English
            }
        }
        //Whether show message topic or not.
        if self.messageThread {
            Appearance.chat.contentStyle.append(.withMessageThread)
        }
        //Whether show message reaction or not.
        if self.messageReaction {
            Appearance.chat.contentStyle.append(.withMessageReaction)
        }
        //Notice: - Feature identify can't changed, it's used to identify feature action.
        
        //Register custom components
        ComponentsRegister.shared.ConversationsController = MineConversationsController.self
        ComponentsRegister.shared.ContactsController = MineContactsViewController.self
        ComponentsRegister.shared.MessageViewController = MineMessageListViewController.self
        ComponentsRegister.shared.ContactInfoController = MineContactDetailViewController.self
        ComponentsRegister.shared.GroupInfoController = MineGroupDetailViewController.self
        ComponentsRegister.shared.MessageRenderEntity = MineMessageEntity.self
    }
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

    private func registerRemoteNotification() {
        //Simulator can't use APNS, so we need to judge whether it is a real machine.
        #if !targetEnvironment(simulator)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Handle granted and error here
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        #endif
    }

}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ChatClient.shared().registerForRemoteNotifications(withDeviceToken: deviceToken) { error in
            if error != nil {
                consoleLogInfo("Register for remote notification error:\(error?.errorDescription ?? "")", type: .error)
            }
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        DialogManager.shared.showAlert(title: "Register notification failed", content: error.localizedDescription, showCancel: true, showConfirm: true) { _ in
            
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ChatClient.shared().application(application, didReceiveRemoteNotification: userInfo)
    }
    
    
}

//MARK: - UserStateChangedListener
extension AppDelegate: UserStateChangedListener {
    
    private func logoutUser() {
        EaseChatUIKitClient.shared.logout(unbindNotificationDeviceToken: true) { error in
            if error != nil {
                consoleLogInfo("Logout failed:\(error?.errorDescription ?? "")", type: .error)
            }
        }
    }
    
    func onUserTokenDidExpired() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: backLoginPage), object: nil)
    }
    
    func onUserLoginOtherDevice(device: String) {
        self.logoutUser()
        NotificationCenter.default.post(name: Notification.Name(rawValue: backLoginPage), object: nil)
    }
    
    func onUserTokenWillExpired() {
        //Notice: - If you want to refresh token, you need to implement the logic in this method.
//        EaseChatUIKitClient.shared.refreshToken(token: token)
        EaseChatBusinessRequest.shared.sendGETRequest(api: .login(()), params: ["userAccount":self.userName,"userPassword":self.password]) { (result, error) in
            if error != nil {
                DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.5) {
                    UIViewController.currentController?.showToast(toast: "\(error?.localizedDescription ?? "")")
                }
            } else {
                if let result = result,let token = result["accessToken"] as? String {
                    EaseChatUIKitClient.shared.refreshToken(token: token)
                }
            }
        }
    }
    
    func onSocketConnectionStateChanged(state: ConnectionState) {
        //Socket state monitor network
    }
    
    func userAccountDidRemoved() {
        self.logoutUser()
        NotificationCenter.default.post(name: Notification.Name(rawValue: backLoginPage), object: nil)
    }
    
    func userDidForbidden() {
        self.logoutUser()
        NotificationCenter.default.post(name: Notification.Name(rawValue: backLoginPage), object: nil)
    }
    
    func userAccountDidForcedToLogout(error: ChatError?) {
        self.logoutUser()
        NotificationCenter.default.post(name: Notification.Name(rawValue: backLoginPage), object: nil)
    }
    
    func onUserAutoLoginCompletion(error: ChatError?) {
        if error != nil {
            NotificationCenter.default.post(name: Notification.Name(rawValue: backLoginPage), object: nil)
        } else {
            if let groups = ChatClient.shared().groupManager?.getJoinedGroups() {
                var profiles = [EaseChatProfile]()
                for group in groups {
                    let profile = EaseChatProfile()
                    profile.id = group.groupId
                    profile.nickname = group.groupName
                    profile.avatarURL = group.settings.ext
                    profiles.append(profile)
                }
                EaseChatUIKitContext.shared?.updateCaches(type: .group, profiles: profiles)
            }
            if let users = EaseChatUIKitContext.shared?.userCache {
                for user in users.values {
                    EaseChatUIKitContext.shared?.userCache?[user.id]?.remark = ChatClient.shared().contactManager?.getContact(user.id)?.remark ?? ""
                }
            }
            NotificationCenter.default.post(name: Notification.Name(loginSuccessfulSwitchMainPage), object: nil)
        }
    }
    
}
