//
//  AgoraMainViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/11.
//

import UIKit

class AgoraMainViewController: UITabBarController {

    private var lastPlaySoundDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadViewControllers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupUnreadMessageCount), name: UnreadMessageCountChangeNotification, object: nil)
        
        self.setupUnreadMessageCount()
        self.registerNotifications()
    }
    
    deinit {
        self.unregisterNotifications()
    }
    
    func didReceiveLocalNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            guard let viewControllers = self.navigationController?.viewControllers else {
                return
            }
            for vc in viewControllers  {
                if vc != self {
                    if let vc = vc as? ACDChatViewController {
                        if let conversationChatter = userInfo["ConversationChatter"] as? String, vc.conversationId != conversationChatter {
                            self.navigationController?.popViewController(animated: false)
                            if let messageType = userInfo["MessageType"] as? Int, let type = AgoraChatConversationType(rawValue: messageType) {
                                let chatViewController = ACDChatViewController(conversationId: conversationChatter, conversationType: type)
                                self.navigationController?.pushViewController(chatViewController, animated: false)
                            }
                        }
                        break
                    } else {
                        self.navigationController?.popViewController(animated: false)
                    }
                } else {
                    if let conversationChatter = userInfo["ConversationChatter"] as? String, let messageType = userInfo["MessageType"] as? Int, let type = AgoraChatConversationType(rawValue: messageType) {
                        
                        let chatViewController = ACDChatViewController(conversationId: conversationChatter, conversationType: type)
                        self.navigationController?.pushViewController(chatViewController, animated: false)
                    }
                }
            }
        } else if let chatVC = (self.viewControllers?.first as? UINavigationController)?.viewControllers.first as? ACDChatsViewController {
            self.navigationController?.popToViewController(self, animated: false)
            self.selectedViewController = chatVC
        }
    }
    
    private func loadViewControllers() {
        let contactsVC = ACDContactsViewController()
        contactsVC.tabBarItem = UITabBarItem(title: "Contacts".localized, image: UIImage(named: "tabbar_contacts"), selectedImage: UIImage(named: "tabbar_contactsHL"))
        contactsVC.tabBarItem.tag = 0
        
        let chatsVC = ACDChatsViewController()
        chatsVC.tabBarItem = UITabBarItem(title: "Chats".localized, image: UIImage(named: "tabbar_chats"), selectedImage: UIImage(named: "tabbar_chatsHL"))
        chatsVC.tabBarItem.tag = 1
        
        let settingNavVC = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController()!
        settingNavVC.tabBarItem = UITabBarItem(title: "Settings".localized, image: UIImage(named: "tabbar_setting"), selectedImage: UIImage(named: "tabbar_settingHL"))
        settingNavVC.tabBarItem.tag = 2

        let nav1 = UINavigationController(rootViewController: chatsVC)
        let nav2 = UINavigationController(rootViewController: contactsVC)
        self.viewControllers = [nav1, nav2, settingNavVC]

        AgoraChatDemoHelper.shared.contactsVC = contactsVC
    }
    
    private func registerNotifications() {
        self.unregisterNotifications()
        AgoraChatClient.shared().add(self, delegateQueue: nil)
        AgoraChatClient.shared().chatManager?.add(self, delegateQueue: nil)
    }
    
    private func unregisterNotifications() {
        AgoraChatClient.shared().removeDelegate(self)
        AgoraChatClient.shared().chatManager?.remove(self)
    }
    
    @objc func setupUnreadMessageCount() {
        var unreadCount: Int32 = 0
        if let conversations = AgoraChatClient.shared().chatManager?.getAllConversations() {
            for conversation in conversations where !conversation.isChatThread {
                unreadCount += conversation.unreadMessagesCount
            }
        }
        
        if let chatVC = (self.viewControllers?.first as? UINavigationController)?.viewControllers.first as? ACDChatsViewController {
            if unreadCount > 0 {
                if unreadCount > 99 {
                    chatVC.tabBarItem.badgeValue = "99+"
                } else {
                    chatVC.tabBarItem.badgeValue = "\(unreadCount)"
                }
            } else {
                chatVC.tabBarItem.badgeValue = nil
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = Int(unreadCount)
    }
    
    private func playSoundAndVibration() {
        let now = Date()
        if let lastPlaySoundDate = self.lastPlaySoundDate {
            let timeInterval = now.timeIntervalSince(lastPlaySoundDate)
            if timeInterval < 1.0 {
                return
            }
        }
        
        self.lastPlaySoundDate = now
        if ACDDemoOptions.shared.playNewMsgSound {
            AgoraCDDeviceManager.playNewMessageSound()
        }
        if ACDDemoOptions.shared.playVibration {
            AgoraCDDeviceManager.playVibration()
        }
    }
    
    private func getMessageBodyString(body: AgoraChatMessageBody) -> String {
        switch body.type {
        case .text:
            return (body as? AgoraChatTextMessageBody)?.text ?? ""
        case .image:
            return "[\("Image".localized)]"
        case .location:
            return "[\("Location".localized)]"
        case .voice:
            return "[\("Voice".localized)]"
        case .video:
            return "[\("Video".localized)]"
        case .file:
            return "[\("File".localized)]"
        default:
            return ""
        }
    }
    
    private func showLocalNotifaction(message: AgoraChatMessage, body: String) {
        var playSound = false
        let now = Date()
        if let lastPlaySoundDate = self.lastPlaySoundDate {
            let timeInterval = now.timeIntervalSince(lastPlaySoundDate)
            if timeInterval >= 1 {
                self.lastPlaySoundDate = now
                playSound = true
            }
        } else {
            self.lastPlaySoundDate = now
            playSound = true
        }
        
        let userInfo: [String: Any] = [
            "MessageType": message.chatType.rawValue,
            "ConversationChatter": message.conversationId
        ]
    
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
        let content = UNMutableNotificationContent()
        if playSound {
            content.sound = UNNotificationSound.default
        }
        content.body = body
        content.userInfo = userInfo
        let request = UNNotificationRequest(identifier: message.messageId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func showBackgroundNotification(message: AgoraChatMessage) {
        let options = AgoraChatClient.shared().pushManager?.pushOptions
        if options?.displayStyle == .messageSummary {
            let messageStr = self.getMessageBodyString(body: message.body)
            UserInfoStore.shared.fetchUserInfosFromServer(userIds: [message.from]) {
                var title = UserInfoStore.shared.getUserInfo(userId: message.from)?.nickname
                if message.chatType == .groupChat {
                    if let groups = AgoraChatClient.shared().groupManager?.getJoinedGroups() {
                        for group in groups where group.groupId == message.conversationId {
                            title = "\(message.from)(\(group.groupName ?? ""))"
                            break
                        }
                    }
                } else if message.chatType == .chatRoom {
                    let userDefaults = UserDefaults.standard
                    let key = "OnceJoinedChatrooms_\(AgoraChatClient.shared().currentUsername!)"
                    if let chatrooms = userDefaults.object(forKey: key) as? [String: Any], let chatroomName = chatrooms[message.conversationId] as? String {
                        title = "\(message.from)(\(chatroomName))"
                    }
                }
                let alertBody = "\(title ?? ""):\(messageStr)"
                self.showLocalNotifaction(message: message, body: alertBody)
            }
        } else {
            let alertBody = "you have a new message".localized
            self.showLocalNotifaction(message: message, body: alertBody)
        }
    }
}

extension AgoraMainViewController: AgoraChatManagerDelegate {
    func messagesDidReceive(_ messages: [AgoraChatMessage]) {
        self.setupUnreadMessageCount()
        for message in messages where !message.isChatThreadMessage {
            let state = UIApplication.shared.applicationState
            switch state {
            case .active, .inactive:
                self.playSoundAndVibration()
            case .background:
                self.showBackgroundNotification(message: message)
            default:
                break
            }
        }
    }
    
    func conversationListDidUpdate(_ aConversationList: [AgoraChatConversation]) {
        self.setupUnreadMessageCount()
    }
    
    func messagesInfoDidRecall(_ aRecallMessagesInfo: [AgoraChatRecallMessageInfo]) {
        self.setupUnreadMessageCount()
    }
    
    func onConversationRead(_ from: String, to: String) {
        self.setupUnreadMessageCount()
    }
}

extension AgoraMainViewController: AgoraChatClientDelegate {
    func connectionStateDidChange(_ aConnectionState: AgoraChatConnectionState) {
        if let chatVC = (self.viewControllers?.first as? UINavigationController)?.viewControllers.first as? ACDChatsViewController {
            chatVC.networkChanged(state: aConnectionState)
        }
    }
    
    func userAccountDidLoginFromOtherDevice() {
        NotificationCenter.default.post(name: LoginStateChangedNotification, object: false, userInfo: [
            "userName": "",
            "nickName": ""
        ])
    }
    
    func userAccountDidRemoveFromServer() {
        NotificationCenter.default.post(name: LoginStateChangedNotification, object: false, userInfo: [
            "userName": "",
            "nickName": ""
        ])
    }
    
    func userDidForbidByServer() {
        NotificationCenter.default.post(name: LoginStateChangedNotification, object: false, userInfo: [
            "userName": "",
            "nickName": ""
        ])
    }
    
    func userAccountDidForced(toLogout aError: AgoraChatError?) {
        NotificationCenter.default.post(name: LoginStateChangedNotification, object: false, userInfo: [
            "userName": "",
            "nickName": ""
        ])
    }
}
