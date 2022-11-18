//
//  ACDChatViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/24.
//

import UIKit
import SnapKit
import AgoraChat

@objcMembers
class ACDChatViewController: UIViewController {
    
    let conversationId: String
    let conversationType: AgoraChatConversationType
    var navTitle: String?
    
    private let conversation: AgoraChatConversation?
    private var conversationModel: EaseConversationModel? = nil
    private let viewModel = EaseChatViewModel()
    private let chatController: EaseChatViewController
    
    private var navigationView: ACDChatNavigationView!

    init(conversationId: String, conversationType: AgoraChatConversationType) {
        self.conversationId = conversationId
        self.conversationType = conversationType
        self.conversation = AgoraChatClient.shared().chatManager?.getConversation(conversationId, type: conversationType, createIfNotExist: true)
        if let conversation = conversation {
            self.conversationModel = EaseConversationModel(conversation: conversation)
        }
        
        self.viewModel.displaySentAvatar = false
        self.viewModel.displaySentName = false
        if conversationType != .groupChat {
            self.viewModel.displayReceiverName = false
        }
        self.chatController = EaseChatViewController.initWithConversationId(conversationId, conversationType: conversationType, chatViewModel: self.viewModel)
        self.chatController.setEditingStatusVisible(ACDDemoOptions.shared.isChatTyping)
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color_F2F2F2
        
        self.setupSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUserInfo(_:)), name: UserInfoDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presencesUpdated(_:)), name: PresenceUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(insertLocalCallRecord(_:)), name: CallKitRecordMessageNotification, object: nil)

        AgoraChatClient.shared().groupManager?.add(self, delegateQueue: nil)
        if let conversation = self.conversation, conversation.unreadMessagesCount > 0 {
            AgoraChatClient.shared().chatManager?.ackConversationRead(conversation.conversationId, completion: nil)
        }
        
        self.updatePresenceStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func insertLocalCallRecord(_ notification: Notification) {
        if let messages = (notification.object as? [String: [AgoraChatMessage]])?["msg"], messages.count > 0 {
            var messageModels: [EaseMessageModel] = []
            for message in messages {
                let model = EaseMessageModel(agoraChatMessage: message)
                messageModels.append(model)
            }
            self.chatController.dataArray.addObjects(from: messageModels)
            let moreMessageId: String? = self.chatController.moreMsgId
            if moreMessageId == nil, let messageId = messages.first?.messageId {
                self.chatController.moreMsgId = messageId
            }
            self.chatController.tableView.reloadData()
        }
    }
    
    private func setupSubviews() {
        self.navigationView = Bundle.main.loadNibNamed("ACDChatNavigationView", owner: nil)?.first as? ACDChatNavigationView
        self.navigationView.leftLabel.text = self.navTitle
        if self.conversationType == .groupChat {
            self.navigationView.chatImageView.layer.cornerRadius = 0
            self.navigationView.chatImageView.image = UIImage(named: "group_default_avatar")
        } else if self.conversationType == .chat {
            if let imageName = UserDefaults.standard.object(forKey: self.conversationId) as? String, imageName.count > 0 {
                self.navigationView.chatImageView.image = UIImage(named: imageName)
            } else {
                let imageName = "defatult_avatar_\(arc4random() % 7 + 1)"
                UserDefaults.standard.set(imageName, forKey: self.conversationId)
                UserDefaults.standard.synchronize()
                self.navigationView.chatImageView.image = UIImage(named: imageName)
            }
        }
        self.navigationView.leftButtonClosure = { [unowned self] in
            self.backAction()
        }
        
        if self.conversationType == .chat {
            self.navigationView.rightButton.isHidden = false
            self.navigationView.rightButton.setImage(UIImage(named: "nav_bar_call"), for: .normal)
            self.navigationView.rightButtonClosure = { [unowned self] in
                self.callAction()
            }
        } else {
            self.navigationView.rightButton.isHidden = false
            self.navigationView.rightButton.setImage(UIImage(named: "groupThread"), for: .normal)
            self.navigationView.rightButtonClosure = { [unowned self] in
                self.pushThreadListAction()
            }
            
            self.navigationView.rightButton2.isHidden = false
            self.navigationView.rightButton2.setImage(UIImage(named: "nav_bar_call"), for: .normal)
            self.navigationView.rightButton2Closure = { [unowned self] in
                self.callAction()
            }
        }
        self.navigationView.chatButtonClosure = { [unowned self] in
            self.goInfoPage()
        }
        
        self.addChild(self.chatController)
        self.view.addSubview(self.navigationView)
        self.view.addSubview(self.chatController.view)
        
        self.navigationView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.chatController.view.snp.top)
        }
        self.chatController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(44)
        }
    }
    
    private func updatePresenceStatus() {
        if self.conversationType == .chat && self.conversationId.count > 0 {
            let presence = PresenceManager.shared.presences[self.conversationId]
            let status = PresenceManager.fetchStatus(presence: presence)
            let imageName = PresenceManager.whiteStrokePresenceImagesMap[status]
            if let imageName = imageName {
                self.navigationView.chatImageView.presenceImage = UIImage(named: imageName)
            }
            if status != .offline && presence?.statusDescription?.count ?? 0 > 0 {
                self.navigationView.presenceLabel.text = presence?.statusDescription
            } else {
                let showStatus = status == .offline ? PresenceManager.formatOfflineTimespace(presence: presence) : PresenceManager.showStatusMap[status]
                self.navigationView.presenceLabel.text = showStatus
            }
        }
    }
    
    @objc private func resetUserInfo(_ notification: Notification) {
        guard let users = notification.userInfo?["userinfo_list"] as? [AgoraChatUserInfo], users.count > 0 else {
            return
        }
        var result: [AgoraChatUserDataModel] = []
        for user in users {
            if user.userId == self.chatController.currentConversation.conversationId {
                self.navigationView.chatImageView.setImage(withUrl: user.avatarUrl)
            }
            let model = AgoraChatUserDataModel(userInfo: user)
            result.append(model)
        }
        self.chatController.setUserProfiles(result)
    }
    
    @objc private func presencesUpdated(_ notification: Notification) {
        if self.conversationType == .chat, let list = notification.object as? [String] {
            if list.contains(self.conversationId) {
                self.updatePresenceStatus()
            }
        }
    }
    
    private func personData(contact: String) {
        UserInfoStore.shared.fetchUserInfosFromServer(userIds: [contact]) { [weak self] in
            guard let self = self else {
                return
            }
            if AgoraChatClient.shared().contactManager?.getContacts()?.contains(contact) == true {
                let vc = ACDContactInfoViewController(userId: contact)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let model = AgoraUserModel(hyphenateId: contact)
                if let info = UserInfoStore.shared.getUserInfo(userId: contact) {
                    model.setUserInfo(info)
                }
                let vc = ACDAddContactViewController(model: model)
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true)
            }
        }
    }

    @objc private func backAction() {
        NotificationCenter.default.post(name: UnreadMessageCountChangeNotification, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func pushThreadListAction() {
        self.chatController.view.endEditing(true)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: self.conversationId, fetchMembers: true, completion: { group, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.showHint(error.errorDescription)
            } else if let group = group {
                let vc = AgoraChatThreadListViewController(group: group, viewModel: self.chatController.viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    private func callAction() {
        self.chatController.view.endEditing(true)
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Audio Call".localized, style: .default, handler: { _ in
            if self.conversationType == .chat {
                AgoraChatCallKitManager.shared.audioCall(toUser: self.conversationId)
            } else {
                AgoraChatCallKitManager.shared.audioCall(toGroup: self.conversationId, viewController: self)
            }
        }))
        vc.addAction(UIAlertAction(title: "Video Call".localized, style: .default, handler: { _ in
            if self.conversationType == .chat {
                AgoraChatCallKitManager.shared.videoCall(toUser: self.conversationId)
            } else {
                AgoraChatCallKitManager.shared.videoCall(toGroup: self.conversationId, viewController: self)
            }
        }))
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(vc, animated: true)
    }
    
    private func goInfoPage() {
        if self.conversationType == .chat {
            let vc = ACDContactInfoViewController(userId: self.conversationId, isChatButtonHidden: true)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else if conversationType == .groupChat {
            let vc = ACDGroupInfoViewController(groupId: self.conversationId, accessType: .chat)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        AgoraChatClient.shared().groupManager?.removeDelegate(self)
    }
}

extension ACDChatViewController: EaseChatViewControllerDelegate {
    // UIKit 根据消息自定义 cell
    func cell(forItem tableView: UITableView, messageModel: EaseMessageModel) -> UITableViewCell? {
        if messageModel.message.body.type == .text {
            if messageModel.message.ext?["msgType"] as? String == "rtcCallWithAgora" {
                let action = messageModel.message.ext?["action"] as? String
                if action == "invite" {
                    if messageModel.message.chatType == .chat {
                        return nil
                    }
                }
                let cell = AgoraChatCallCell(direction: messageModel.direction, chatType: messageModel.message.chatType, messageType: messageModel.type, viewModel: self.viewModel)
                cell.delegate = self
                cell.model = messageModel
                return cell
            }
        }
        
        if messageModel.message.body.type == .text {
            if messageModel.message.ext?["msgType"] as? String == "rtcCallWithAgora" {
                let action = messageModel.message.ext?["action"] as? String
                if action == "invite" {
                    if messageModel.message.chatType == .chat {
                        return nil
                    }
                }
                let cell = AgoraChatCallCell(direction: messageModel.direction, chatType: messageModel.message.chatType, messageType: messageModel.type, viewModel: self.viewModel)
                cell.delegate = self
                cell.model = messageModel
                return cell
            }
        }

        if messageModel.message.body.type == .text, let noti = messageModel.message.ext?["agora_noti"] as? String {
            if noti == "agora_addFriend" || noti == "agora_addGroup" {
                let cell = Bundle.main.loadNibNamed("AgoraChatMessageWeakHint", owner: nil)?.first as? AgoraChatMessageWeakHint
                cell?.messageModel = messageModel
                return cell
            }
        }
        return nil
    }
    
    // UIKit 对方进入正在输入的状态
    func peerTyping() {
        guard let navTitle = self.navTitle else {
            return
        }
        let titleString = NSAttributedString(string: navTitle, attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 18)
        ])
        let preTypingString = NSAttributedString(string: " (\("other party is typing".localized)", attributes: [
            .foregroundColor: Color_999999,
            .font: UIFont(name: "PingFang SC", size: 14) ?? UIFont.systemFont(ofSize: 14)
        ])
        
        let result = NSMutableAttributedString(attributedString: titleString)
        result.append(preTypingString)
        
        self.navigationView.leftLabel.attributedText = result
    }
    
    // UIKit 对方离开正在输入的状态
    func peerEndTyping() {
        self.navigationView.leftLabel.text = self.navTitle
    }
    
    // 根据 UIKit 给出的用户ID，返回用户详情
    func userProfile(_ userID: String) -> EaseUserProfile? {
        if userID == "" {
            return nil
        }
        if let userInfo = UserInfoStore.shared.getUserInfo(userId: userID) {
            return AgoraChatUserDataModel(userInfo: userInfo)
        } else {
            let userInfo = AgoraChatUserInfo()
            userInfo.userId = userID
            UserInfoStore.shared.fetchUserInfosFromServer(userIds: [userID])
            return AgoraChatUserDataModel(userInfo: userInfo)
        }
    }
    
    // UIKit 点击了头像
    @nonobjc func avatarDidSelected(_ userData: EaseUserProfile) {
        self.personData(contact: userData.easeId)
    }
    
    // UIKit 发送消息的回调
    func didSend(_ message: AgoraChatMessage, error: AgoraChatError?) {
        if let error = error {
            self.showHint(error.errorDescription)
        }
    }
    
    // UIKit 点击了消息的 Thread
    func didSelectThreadBubble(_ model: EaseMessageModel) {
        let threadId = model.message.chatThread?.threadId
        if threadId?.count ?? 0 <= 0 {
            self.showHint("ConversationId is empty!")
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().threadManager?.joinChatThread(threadId!, completion: { thread, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error == nil || error?.code == .userAlreadyExist {
                if let thread = thread {
                    model.thread = thread
                }
                let vc = AgoraChatThreadViewController(conversationId: threadId!, type: self.chatController.currentConversation.type, viewModel: self.chatController.viewModel, parentMessageId: model.message.messageId, model: model)
                vc.detail = self.navTitle
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    // UIKit 点击了创建 Thread
    func createThread(_ model: EaseMessageModel) {
        let vc = AgoraChatCreateThreadViewController(type: .create, viewModel: self.chatController.viewModel, message: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // UIKit 点击了创建 Thread 的通知
    func joinChatThread(fromNotifyMessage messageId: String) {
        guard let message = AgoraChatClient.shared().chatManager?.getMessageWithMessageId(messageId) else {
            return
        }
        let model = EaseMessageModel(agoraChatMessage: message)
        model.direction = message.direction
        model.isHeader = true
        model.isPlaying = false
        model.type = AgoraChatMessageType(rawValue: message.body.type.rawValue) ?? .text
        guard let threadId = message.chatThread?.threadId, threadId.count > 0 else {
            self.showHint("threadId is empty!")
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().threadManager?.joinChatThread(threadId, completion: { thread, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error == nil || error?.code == .userAlreadyExist {
                let vc = AgoraChatThreadViewController(conversationId: threadId, type: self.chatController.currentConversation.type, viewModel: self.chatController.viewModel, parentMessageId: messageId, model: model)
                vc.detail = "# \(self.navTitle ?? "")"
                if let threadName = thread?.threadName, threadName.count > 0 {
                    vc.navTitle = thread?.threadName
                } else {
                    vc.navTitle = message.chatThread?.threadName
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    // UIKit 长按消息的回调
    func messageLongPressExtMenuItemArray(_ defaultLongPressItems: NSMutableArray, messageModel: EaseMessageModel) -> NSMutableArray {
        if messageModel.direction == .receive {
            let type = messageModel.message.body.type
            if type == .text || type == .image || type == .file || type == .video || type == .video {
                let reportItem = EaseExtendMenuModel(data: UIImage(named: "report")!, funcDesc: "Report".localized) { _, _ in
                    let vc = ACDReportMessageViewController(reportMessage: messageModel)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                defaultLongPressItems.add(reportItem)
            }
        }
        return defaultLongPressItems
    }
}

extension ACDChatViewController: EaseMessageCellDelegate {
    func messageCellDidSelected(_ aCell: EaseMessageCell) {
        if !aCell.model.message.isReadAcked {
            AgoraChatClient.shared().chatManager?.sendMessageReadAck(aCell.model.message.messageId, toUser: aCell.model.message.conversationId, completion: nil)
        }
    }
}

extension ACDChatViewController: AgoraChatGroupManagerDelegate {
    func didLeave(_ aGroup: AgoraChatGroup, reason aReason: AgoraChatGroupLeaveReason) {
        if self.conversationType == .groupChat, self.conversationId == aGroup.groupId {
            self.backAction()
        }
    }
}
