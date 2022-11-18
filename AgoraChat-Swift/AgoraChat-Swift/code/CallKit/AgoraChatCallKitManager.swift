//
//  AgoraChatCallKitManager.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/19.
//

import UIKit

@objcMembers
class AgoraChatCallKitManager: NSObject {
    static let shared = AgoraChatCallKitManager()
    
    override init() {
        super.init()
        let config = AgoraChatCallConfig()
        config.agoraAppId = "15cb0d28b87b425ea613fc46f7c9f974"
        config.enableRTCTokenValidate = true
        config.enableIosCallKit = true
        AgoraChatCallManager.shared().initWith(config, delegate: self)
    }
    
    func update(agoraUid: UInt) {
        AgoraChatCallManager.shared().getAgoraChatCallConfig().agoraUid = agoraUid
    }
    
    func audioCall(toUser userId: String) {
        if AVAudioSession.sharedInstance().recordPermission == .denied {
            return
        }
        guard let conversation = AgoraChatClient.shared().chatManager?.getConversation(userId, type: .chat, createIfNotExist: true) else {
            return
        }
        let msgId: String? = conversation.latestMessage.messageId
        self.updateRTCUserInfo(userId: userId)
        AgoraChatCallManager.shared().startSingleCall(withUId: userId, type: .type1v1Audio, ext: nil) { callId, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                conversation.loadMessagesStart(fromId: msgId, count: 50, searchDirection: msgId == nil ? .up : .down) { messages, error in
                    if let messages = messages, messages.count > 0 {
                        self.insertLocationCallRecord(messages: messages)
                    }
                }
            }
        }
    }

    func videoCall(toUser userId: String) {
        if AVAudioSession.sharedInstance().recordPermission == .denied {
            return
        }
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .restricted || authStatus == .denied {
            return
        }
        guard let conversation = AgoraChatClient.shared().chatManager?.getConversation(userId, type: .chat, createIfNotExist: true) else {
            return
        }
        let msgId: String? = conversation.latestMessage.messageId
        self.updateRTCUserInfo(userId: userId)
        AgoraChatCallManager.shared().startSingleCall(withUId: userId, type: .type1v1Video, ext: nil) { callId, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                conversation.loadMessagesStart(fromId: msgId, count: 50, searchDirection: msgId == nil ? .up : .down) { messages, error in
                    if let messages = messages, messages.count > 0 {
                        self.insertLocationCallRecord(messages: messages)
                    }
                }
            }
        }
    }
    
    func audioCall(toGroup groupId: String, viewController: UIViewController) {
        let vc = ConfInviteUsersViewController(groupId: groupId, excludeUsers: [AgoraChatClient.shared().currentUsername!])
        vc.didSelectedUserListHandle = { inviteUsers in
            for userId in inviteUsers {
                self.updateRTCUserInfo(userId: userId)
            }
            AgoraChatCallManager.shared().startInviteUsers(inviteUsers, groupId: groupId, callType: .typeMultiAudio, ext: [
                "groupId": groupId
            ], completion: nil)
        }
        vc.modalPresentationStyle = .pageSheet
        viewController.present(vc, animated: true)
    }

    func videoCall(toGroup groupId: String, viewController: UIViewController) {
        let vc = ConfInviteUsersViewController(groupId: groupId, excludeUsers: [AgoraChatClient.shared().currentUsername!])
        vc.didSelectedUserListHandle = { inviteUsers in
            for userId in inviteUsers {
                self.updateRTCUserInfo(userId: userId)
            }
            AgoraChatCallManager.shared().startInviteUsers(inviteUsers, groupId: groupId, callType: .typeMultiVideo, ext: [
                "groupId": groupId
            ], completion: nil)
        }
        vc.modalPresentationStyle = .pageSheet
        viewController.present(vc, animated: true)
    }
    
    private func insertLocationCallRecord(messages: [AgoraChatMessage]) {
        NotificationCenter.default.post(name: CallKitRecordMessageNotification, object: [
            "msg": messages
        ])
    }
    
    private func updateRTCUserInfo(userId: String) {
        if let info = UserInfoStore.shared.getUserInfo(userId: userId) {
            let user = AgoraChatCallUser(nickName: info.nickname, image: info.avatarUrl == nil ? nil : URL(string: info.avatarUrl!))
            AgoraChatCallManager.shared().getAgoraChatCallConfig().setUser(userId, info: user)
        }
    }
    
    private func fetchUserMapsFromServer(channelName: String) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let strUrl = "http://a41.easemob.com/agora/channel/mapper?channelName=\(channelName)&userAccount=\(AgoraChatClient.shared().currentUsername!)"
        guard let utf8Url = strUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return
        }
        guard let url = URL(string: utf8Url) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(AgoraChatClient.shared().accessUserToken ?? "")", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            let resCode = body["code"] as? String
            if resCode == "RES_OK", let channelName = body["channelName"] as? String {
                let result = body["result"] as? [String: String]
                var users: [NSNumber: String] = [:]
                if let result = result {
                    for (strId, username) in result {
                        if let uid = Int(strId) {
                            users[NSNumber(value: uid)] = username
                        }
                        self.updateRTCUserInfo(userId: username)
                    }
                }
                DispatchQueue.main.async {
                    AgoraChatCallManager.shared().setUsers(users, channelName: channelName)
                }
            }
        }
        task.resume()
    }
}

extension AgoraChatCallKitManager: AgoraChatCallDelegate {
    func callDidEnd(_ aChannelName: String, reason aReason: AgoraChatCallEndReason, time aTm: Int32, type aType: AgoraChatCallType) {
        switch aReason {
        case .answerOtherDevice:
            self.showHint("Other devices connected".localized)
        case .refuseOtherDevice:
            self.showHint("Other devices declined".localized)
        case .busy:
            self.showHint("The line is busy".localized)
        case .remoteRefuse:
            self.showHint("Request declined".localized)
        case .noResponse:
            self.showHint("No response".localized)
        default:
            break
        }
    }
    
    func multiCallDidInviting(withCurVC vc: UIViewController, callType: AgoraChatCallType, excludeUsers users: [String]?, ext aExt: [AnyHashable : Any]?) {
        guard let groupId = aExt?["groupId"] as? String, groupId.count > 0 else {
            return
        }
        let confVC = ConfInviteUsersViewController(groupId: groupId, excludeUsers: users ?? [])
        confVC.didSelectedUserListHandle = { inviteUsers in
            for userId in inviteUsers {
                self.updateRTCUserInfo(userId: userId)
            }
            AgoraChatCallManager.shared().startInviteUsers(inviteUsers, groupId: groupId, callType: callType, ext: aExt, completion: nil)
        }
        confVC.modalPresentationStyle = .popover
        vc.present(confVC, animated: true)
    }
    
    func callDidReceive(_ aType: AgoraChatCallType, inviter user: String, ext aExt: [AnyHashable : Any]?) {
        self.updateRTCUserInfo(userId: user)
    }
    
    func callDidOccurError(_ aError: AgoraChatCallError) {
        
    }
    
    func callDidRequestRTCToken(forAppId aAppId: String, channelName aChannelName: String, account aUserAccount: String, uid aAgoraUid: Int) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let strUrl = "http://a41.easemob.com/token/rtc/channel/\(aChannelName)/agorauid/\(aAgoraUid)?userAccount=\(aUserAccount)"
        guard let utf8Url = strUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return
        }
        guard let url = URL(string: utf8Url) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(AgoraChatClient.shared().accessUserToken ?? "")", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            let resCode = body["code"] as? String
            if resCode == "RES_OK", let rtcToken = body["accessToken"] as? String {
                AgoraChatCallManager.shared().setRTCToken(rtcToken, channelName: aChannelName, uid: UInt(aAgoraUid))
            }
        }
        task.resume()
    }
    
    func remoteUserDidJoinChannel(_ aChannelName: String, uid aUid: Int, username aUserName: String?) {
        if let userName = aUserName, userName.count > 0  {
            self.updateRTCUserInfo(userId: userName)
        } else {
            self.fetchUserMapsFromServer(channelName: aChannelName)
        }
    }
    
    func callDidJoinChannel(_ aChannelName: String, uid aUid: UInt) {
        self.fetchUserMapsFromServer(channelName: aChannelName)
    }
}
