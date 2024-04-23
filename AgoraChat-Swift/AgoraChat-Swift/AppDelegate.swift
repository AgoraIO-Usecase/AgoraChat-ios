//
//  AppDelegate.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/9.
//

import UIKit
import UserNotifications
import AgoraChat
import AgoraRtcKit
import Bugly

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var username: String?
    var nickname: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ACDAppStyle.useDefault()
        Bugly.start(withAppId: "707bd39ee6")

        self.initAccount()
        self.initUIKit()

        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChange(_:)), name: LoginStateChangedNotification, object: nil)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = .white

        self.loadViewController()
        
        self.window!.makeKeyAndVisible()
        self.registerAPNS()
        self.registerNotifications()
        
        if let agoraUid = UserDefaults.standard.object(forKey: "user_agora_uid") as? UInt {
            AgoraChatCallKitManager.shared.update(agoraUid: agoraUid)
        }

        return true
    }
    
    private func initAccount() {
        self.username = UserDefaults.standard.object(forKey: "user_name") as? String
        self.nickname = UserDefaults.standard.object(forKey: "nick_name") as? String
    }
    
    private func initUIKit() {
//        let options = AgoraChatOptions(appkey: "41117440#383391")
        let options = ACDDemoOptions.shared.toOptions()
//        options.setValue(false, forKey: "enableDnsConfig")
//        options.setValue(6717, forKey: "chatPort")
//        options.setValue("180.184.143.60", forKey: "chatServer")
//        options.setValue("https://a1-hsb.easemob.com", forKey: "restServer")
        EaseChatKitManager.initWith(options)
    }

    private func loadViewController() {
        if AgoraChatClient.shared().isAutoLogin {
            self.loadMainPage()
        } else {
            self.loadLoginPage()
        }
    }
    
    private func registerAPNS() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func registerNotifications() {
        AgoraChatClient.shared().add(self, delegateQueue: nil)
    }
    
    @objc private func loginStateChange(_ notification: Notification) {
        self.username = notification.userInfo?["userName"] as? String
        self.nickname = notification.userInfo?["nickName"] as? String
        
        if (notification.object as? Bool) ?? false {
            self.loadMainPage()
        } else {
            self.loadLoginPage()
        }
    }
    
    private func loadMainPage() {
        AgoraChatClient.shared().groupManager?.getJoinedGroupsFromServer(withPage: 0, pageSize: 200, needMemberCount: true, needRole: true, completion: { _, _ in
            AgoraChatClient.shared().groupManager?.getJoinedGroups()
            AgoraChatClient.shared().chatManager?.getAllConversations()
        })

        let main = AgoraMainViewController()
        var navigationController = self.window?.rootViewController as? UINavigationController
        if navigationController == nil || !(navigationController?.viewControllers[0] is AgoraMainViewController) {
            navigationController = UINavigationController(rootViewController: main)
        }
        navigationController?.isNavigationBarHidden = true
        self.window?.rootViewController = navigationController
        AgoraChatDemoHelper.shared.mainVC = main
    }
    
    private func loadLoginPage() {
        let login = AgoraLoginViewController()
        let navigationController = UINavigationController(rootViewController: login)
        navigationController.isNavigationBarHidden = true
        self.window?.rootViewController = navigationController
        AgoraChatDemoHelper.shared.mainVC = nil
    }
}

extension AppDelegate {
    func applicationDidEnterBackground(_ application: UIApplication) {
        AgoraChatClient.shared().applicationDidEnterBackground(application)
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        AgoraChatClient.shared().applicationWillEnterForeground(application)
    }
}

extension AppDelegate: AgoraChatClientDelegate {
    func autoLoginDidCompleteWithError(_ error: AgoraChatError?) {
        if error != nil {
            self.loadLoginPage()
        }
    }
    
    func tokenWillExpire(_ errorCode: AgoraChatErrorCode) {
        if errorCode == .tokeWillExpire, let username = self.username, let password = UserDefaults.standard.object(forKey: "user_pwd") as? String {
            AgoraChatHttpRequest.shared.loginToApperServer(username: username, password: password) { statusCode, response in
                var alertStr: String?
                if let response = response, response.count > 0, let responsedict = try? JSONSerialization.jsonObject(with: response) as? [String: Any] {
                    if let token = responsedict["accessToken"] as? String, token.count > 0 {
                        if AgoraChatClient.shared().renewToken(token) != nil {
                            alertStr = "Renew token failed".localized
                        }
                    } else {
                        alertStr = "login analysis token failure".localized
                    }
                } else {
                    alertStr = "Login failed".localized
                }
                if let alertStr = alertStr {
                    self.showHint(alertStr)
                }
            }
        }
    }
    
    func tokenDidExpire(_ errorCode: AgoraChatErrorCode) {
        if errorCode == .tokenExpire || errorCode.rawValue == 401 {
            let finishClosure: (_ username: String, _ error: AgoraChatError?) -> Void  = { username, error in
                let showText: String?
                switch error?.code {
                case .serverNotReachable:
                    showText = "Connect to the server failed!".localized
                case .networkUnavailable:
                    showText = "No network connection!".localized
                case .serverTimeout:
                    showText = "Connect to the server timed out!".localized
                default:
                    showText = nil
                }
                guard let showText = showText else {
                    return
                }
                let vc = UIAlertController(title: nil, message: showText, preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default))
                UIWindow.keyWindow?.rootViewController?.present(vc, animated: true)
            }
            
            guard let password = UserDefaults.standard.object(forKey: "user_pwd") as? String, password.count > 0, let username = self.username, username.count > 0 else {
                return
            }
                    
            AgoraChatHttpRequest.shared.loginToApperServer(username: username, password: password) { statusCode, responseData in
                DispatchQueue.main.async {
                    var alertStr: String?
                    if let responseData = responseData {
                        let responsedict = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any]
                        let token = responsedict?["accessToken"] as? String
                        let loginName = responsedict?["chatUserName"] as? String
                        if let token = token, token.count > 0, let loginName = loginName {
                            AgoraChatClient.shared().login(withUsername: loginName.lowercased(), agoraToken: token) { username, error in
                                finishClosure(username, error)
                            }
                            return
                        } else {
                            alertStr = "Login analysis token failure".localized
                        }
                    } else {
                        alertStr = "Login failed".localized
                    }
                    if let alertStr = alertStr {
                        let vc = UIAlertController(title: nil, message: alertStr, preferredStyle: .alert)
                        UIWindow.keyWindow?.rootViewController?.present(vc, animated: true)
                    }
                }
            }
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DispatchQueue.global().async {
            AgoraChatClient.shared().bindDeviceToken(deviceToken)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AgoraChatClient.shared().application(application, didReceiveRemoteNotification: userInfo)
        completionHandler(.newData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        AgoraChatClient.shared().application(UIApplication.shared, didReceiveRemoteNotification: notification.request.content.userInfo)
    }
    
    func test() {
        let markType: AgoraChatMarkType = .type0
        let marked0Conversations = AgoraChatClient.shared().chatManager?.getAllConversations()?.filter { $0.marks.contains(NSNumber(value: markType.rawValue))
        }
        
        if let message = AgoraChatClient.shared().chatManager?.getMessageWithMessageId("messageId") {
            let pinnedInfo = message.pinnedInfo
        }
        let textMessage = AgoraChatMessage(conversationId: "conversationId", body: .text(content: "hello"), ext: nil)
        // whether to deliver message only when the recipient online
        textMessage.deliverOnlineOnly = true
        AgoraChatClient.shared().chatManager?.send(textMessage, progress: nil, completion: { message, err in
            if err == nil {
                // send message success
            }
        })
        
        AgoraChatClient.shared().groupManager?.getJoinedGroupsCountFromServer(completion: { count, err in
            if err == nil {
                // get joined groups count success
            }
        })
        
        AgoraChatClient.shared().chatManager?.getPinnedMessages(fromServer: "conversationId", completion: { pinnedMessages, err in
            if err == nil {
                // get pinnedMessages from server success
            }
        })
        
        AgoraChatClient.shared().chatManager?.markAllConversationsAsRead()
        
        // message to be forwarded
        if let message = AgoraChatClient.shared().chatManager?.getMessageWithMessageId("messageId") {
            // create new message with origin body and ext
            let newMessage = AgoraChatMessage(conversationID: "conversationId", body: message.body, ext: message.ext)
            AgoraChatClient.shared().chatManager?.send(newMessage, progress: nil, completion: { messageResult, err in
                if err == nil {
                    // forward message success
                }
            })
        }
    }
    func handleQuotedMessage(_ message: AgoraChatMessage) {
        if let quotedInfo = message.ext?["msgQuote"] as? [String: AnyObject] {
            // 读取msgQuote中的源消息信息
            if let quotedMessageId = quotedInfo["msgID"] as? String,
               let msgPreview = quotedInfo["msgPreview"] as? String,
               let msgSender = quotedInfo["msgSender"] as? String,
               let msgType = quotedInfo["msgType"] as? String {
               // 消息引用了其他消息，需要更新UI
            }
        }
    }
    func messagesDidReceive(_ aMessages: [AgoraChatMessage]) {
        for msg in aMessages {
            handleQuotedMessage(msg)
        }
    }
}
