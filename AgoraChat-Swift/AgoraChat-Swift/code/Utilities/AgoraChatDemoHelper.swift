//
//  AgoraChatDemoHelper.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/11.
//

import UIKit

fileprivate var helper: AgoraChatDemoHelper? = nil

@objcMembers class AgoraChatDemoHelper: NSObject {

    static let shared = AgoraChatDemoHelper()
    
    weak var contactsVC: ACDContactsViewController?
    weak var mainVC: AgoraMainViewController?
    var groupIdHasLocalPinnedMessages: Set<String> = []
    
    override init() {
        super.init()
        AgoraChatClient.shared().add(self, delegateQueue: nil)
        AgoraChatClient.shared().chatManager?.add(self, delegateQueue: nil)
        AgoraChatClient.shared().groupManager?.add(self, delegateQueue: nil)
        AgoraChatClient.shared().contactManager?.add(self, delegateQueue: nil)    }
    
    deinit {
        AgoraChatClient.shared().removeDelegate(self)
        AgoraChatClient.shared().chatManager?.remove(self)
        AgoraChatClient.shared().groupManager?.removeDelegate(self)
        AgoraChatClient.shared().contactManager?.removeDelegate(self)
    }
    
    func setupUntreatedApplyCount() {
        let unreadCount = AgoraApplyManager.shared.unhandleApplysCount
        if let contactsVC = contactsVC {
            if unreadCount > 0 {
                contactsVC.tabBarController?.tabBar.showBadge(index: 1)
                contactsVC.navBarUnreadRequestIsShow(true)
            } else {
                contactsVC.tabBarController?.tabBar.hideBadge(index: 1)
                contactsVC.navBarUnreadRequestIsShow(false)
            }
        }
    }
    
    func hiddenApplyRedPoint() {
        if let contactsVC = contactsVC {
            contactsVC.tabBarController?.tabBar.hideBadge(index: 1)
            contactsVC.navBarUnreadRequestIsShow(false)
        }
    }
    
    private func notificationMsg(itemId: String, username: String, type: AgoraChatConversationType, msg: String) {
        let conversation = AgoraChatClient.shared().chatManager?.getConversation(itemId, type: type, createIfNotExist: true)
        var message: AgoraChatMessage?
        if type == .chat {
            let body = AgoraChatTextMessageBody(text: msg)
            message = AgoraChatMessage(conversationID: itemId, from: AgoraChatClient.shared().currentUsername!, to: itemId, body: body, ext: [
                "agora_noti": "agora_addFriend",
                "agora_notiUserID": username
            ])
            message?.chatType = .chat
        } else if type == .groupChat {
            let body = AgoraChatTextMessageBody(text: msg)
            message = AgoraChatMessage(conversationID: itemId, from: username, to: itemId, body: body, ext: [
                "agora_noti": "agora_addGroup",
                "agora_notiUserID": username
            ])
            message?.chatType = .groupChat
        }
        if let message = message {
            message.isRead = true
            conversation?.insert(message, error: nil)
            NotificationCenter.default.post(name: ConversationsUpdatedNotification, object: nil)
        }
    }
}

extension AgoraChatDemoHelper: AgoraChatClientDelegate {
    func autoLoginDidCompleteWithError(_ aError: AgoraChatError?) {
        if let contactsVC = contactsVC {
            contactsVC.reloadGroupNotifications()
            contactsVC.reloadContactRequests()
            contactsVC.reloadContacts()
        }
    }
}

extension AgoraChatDemoHelper: AgoraChatManagerDelegate {
    func conversationListDidUpdate(_ aConversationList: [AgoraChatConversation]) {
        self.mainVC?.setupUnreadMessageCount()
    }
    
    func messagesDidRecall(_ aMessages: [Any]!) {
        self.mainVC?.setupUnreadMessageCount()
    }
    func onMessagePinChanged(_ messageId: String, conversationId: String, operation pinOperation: AgoraChatMessagePinOperation, pinInfo: AgoraChatMessagePinInfo) {
        if let message = AgoraChatClient.shared().chatManager?.getMessageWithMessageId(messageId) {
            self.addPinNotifiMsg(pinOperation == .pin, userId: pinInfo.operatorId, groupId: message.conversationId, messageId: messageId)
        }
    }
    
    func addPinNotifiMsg(_ isPinned: Bool, userId: String, groupId: String, messageId: String) {
    var info = ""
    if isPinned {
        info = "\(userId == AgoraChatClient.shared().currentUsername ? "You" : userId) pinned a message"
    } else {
        info = "\(userId == AgoraChatClient.shared().currentUsername ? "You" : userId) removed a pin message"
    }
    let body = AgoraChatTextMessageBody(text: info)
    let message = AgoraChatMessage(conversationID: groupId, body: body, ext: [MSG_EXT_NEWNOTI: NOTI_EXT_ADDGROUP, "agora_notiUserID": userId])
    message.chatType = .groupChat
    message.isRead = true
        if let conversation = AgoraChatClient.shared().chatManager?.getConversation(groupId, type: .groupChat, createIfNotExist: true) {
            conversation.insert(message, error: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateConversations"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PinnedMessages"), object: ["tipMessageId": message.messageId])
        }
    }

}

extension AgoraChatDemoHelper: AgoraChatContactManagerDelegate {
    func friendRequestDidApprove(byUser aUsername: String) {
        let msg = String(format: "%@ agreed to add friends to apply".localized, aUsername)
        self.showAlert(message: msg)
        self.notificationMsg(itemId: aUsername, username: "", type: .chat, msg: "Your friend request has been approved".localized)
    }
 
    func friendRequestDidDecline(byUser aUsername: String) {
        let msg = String(format: "%@ refuse to add friends to apply".localized, aUsername)
        self.showAlert(message: msg)
    }
        
    func friendshipDidRemove(byUser aUsername: String) {
        let msg = "\("Delete".localized) \(aUsername)"
        self.showAlert(message: msg)
        self.contactsVC?.reloadContacts()
    }
    
    func friendshipDidAdd(byUser aUsername: String) {
        self.contactsVC?.reloadContacts()
    }
    
    func friendRequestDidReceive(fromUser aUsername: String, message aMessage: String?) {
        var message: String! = aMessage
        if message == nil {
            message = String(format: "%@ add you as a friend".localized, aUsername)
        }
        let model = AgoraApplyModel(type: .contact(userId: aUsername))
        model.applyNickname = aUsername
        model.reason = message
        
        AgoraApplyManager.shared.addOrUpdate(apply: model)

        if self.mainVC != nil, let helper = helper {
            helper.setupUntreatedApplyCount()
            let isAppActivity = UIApplication.shared.applicationState == .active
            if !isAppActivity {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                let content = UNMutableNotificationContent()
                content.sound = UNNotificationSound.default
                content.body = String(format: "%@ add you as a friend".localized, aUsername)
                
                let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSinceReferenceDate)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
        self.contactsVC?.reloadContactRequests()
    }
}

extension AgoraChatDemoHelper: AgoraChatGroupManagerDelegate {
    func didLeave(_ group: AgoraChatGroup, reason: AgoraChatGroupLeaveReason) {
        var msg: String?
        if reason == .beRemoved {
            msg = String(format: "Your are kicked out from group: %@".localized, "\(group.groupName!) [\(group.groupId!)]")
        } else if reason == .destroyed {
            msg = String(format: "Group: %@ is destroyed".localized, "\(group.groupName!) [\(group.groupId!)]")
        }
        if let msg = msg {
            self.showHint(msg)
        }
        
        NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
        NotificationCenter.default.post(name: GroupLeftNotification, object: nil)
        
        if var viewControllers = self.mainVC?.navigationController?.viewControllers {
            var index: Int?
            for i in 0..<viewControllers.count {
                if let viewController = viewControllers[i] as? ACDChatViewController, group.groupId == viewController.conversationId {
                    index = i
                    break
                }
            }
            if let index = index {
                viewControllers.remove(at: index)
                if viewControllers.count > 0 {
                    self.mainVC?.navigationController?.setViewControllers([viewControllers.first!], animated: true)
                } else {
                    self.mainVC?.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            }
        }
    }
    
    func joinGroupRequestDidReceive(_ group: AgoraChatGroup, user username: String, reason: String?) {
        var reasonResult: String!
        if let reason = reason, reason.count > 0 {
            reasonResult = String(format: "%@ apply to join group \'%@\'：%@".localized, username, group.groupName, reason)
        } else {
            reasonResult = String(format: "%@ apply to join group \'%@\'".localized, username, group.groupName)
        }
        
        let model = AgoraApplyModel(type: .joinGroup(userId: username, groupId: group.groupId))
        model.applyNickname = username
        model.groupSubject = group.groupName
        model.groupMemberCount = Int32(group.occupantsCount)
        model.reason = reasonResult
        
        AgoraApplyManager.shared.addOrUpdate(apply: model)
        
        if self.mainVC != nil {
            helper?.setupUntreatedApplyCount()
        }
        self.contactsVC?.reloadGroupNotifications()
    }
    
    func didJoin(_ group: AgoraChatGroup, inviter: String, message: String?) {
        let msg = String(format: "%@ invite you to join the group [%@]".localized, inviter, group.groupName, group.groupId)
        self.showAlert(message: msg)
        NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
        self.notificationMsg(itemId: group.groupId, username: inviter, type: .groupChat, msg: String(format: "You have automatically agreed to %@ group invitation.".localized, inviter))
    }
    
    func joinGroupRequestDidDecline(_ groupId: String, reason: String?) {
        if let reason = reason, reason.count > 0 {
            self.showAlert(message: reason)
        } else {
            self.showAlert(message: String(format: "be refused to join the group\'%@\'".localized, groupId))
        }
    }
    
    func joinGroupRequestDidApprove(_ group: AgoraChatGroup) {
        let msg = String(format: "You are agreed to join the group of \'%@\'".localized, group.groupName)
        self.showAlert(message: msg)
        
        NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
        self.notificationMsg(itemId: group.groupId, username: "", type: .groupChat, msg: "group.beAgreedJoinSenMsg".localized)
    }
    
    func groupInvitationDidReceive(_ groupId: String, groupName: String, inviter: String, message: String?) {
        var showMessage: String?
        if let message = message, message.count > 0 {
            showMessage = message
        } else {
            showMessage = String(format: "%@ invite you to join the group [%@]".localized, inviter, groupId)
        }
        AgoraChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: groupId, completion: { group, error in
            let model = AgoraApplyModel(type: .inviteGroup(userId: inviter, groupId: groupId))
            model.groupSubject = group?.groupName
            model.applyNickname = inviter
            model.reason = showMessage
            
            AgoraApplyManager.shared.addOrUpdate(apply: model)
            
            if self.mainVC != nil {
                helper?.setupUntreatedApplyCount()
            }
            self.contactsVC?.reloadGroupNotifications()
        })
    }
    
    func groupInvitationDidDecline(_ group: AgoraChatGroup, invitee: String, reason aReason: String?) {
        let msg = String(format: "%@ decline to join the group [%@]".localized, invitee, group.groupName)
        self.showAlert(title: "Group Notification".localized, message: msg)
    }
    
    func groupInvitationDidAccept(_ group: AgoraChatGroup, invitee: String) {
        let msg = String(format: "%@ agreed to join the group [%@]".localized, invitee, group.groupName)
        self.showAlert(title: "Group Notification".localized, message: msg)
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
        self.notificationMsg(itemId: group.groupId, username: invitee, type: .groupChat, msg: String(format: "%@ agreed to your invitation to join the group.".localized, invitee))
    }
    
    func groupMuteListDidUpdate(_ group: AgoraChatGroup, addedMutedMembers: [String], muteExpire: Int) {
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
    }
    
    func groupMuteListDidUpdate(_ group: AgoraChatGroup, removedMutedMembers: [String]) {
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
    }
    
    func groupAdminListDidUpdate(_ group: AgoraChatGroup, addedAdmin: String) {
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
    }
    
    func groupAdminListDidUpdate(_ group: AgoraChatGroup, removedAdmin: String) {
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
    }
    
    func groupOwnerDidUpdate(_ group: AgoraChatGroup, newOwner: String, oldOwner: String) {
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
        self.notificationMsg(itemId: group.groupId, username: newOwner, type: .groupChat, msg: String(format: "%@ becomes the new Group Owner.".localized, newOwner))
    }
    
    func userDidJoin(_ group: AgoraChatGroup, user: String) {
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
        self.notificationMsg(itemId: group.groupId, username: user, type: .groupChat, msg: String(format: "%@ joined the Group.".localized, user))
    }
    
    func userDidLeave(_ group: AgoraChatGroup, user: String) {
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
        self.notificationMsg(itemId: group.groupId, username: user, type: .groupChat, msg: String(format: "%@ left the Group.".localized, user))
    }
    
    func groupAnnouncementDidUpdate(_ group: AgoraChatGroup, announcement: String?) {
        NotificationCenter.default.post(name: GroupInfoChangedNotification, object: group)
    }
}
