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
    private let pinMessageButton = UIButton()
    private var pinMessageVC: ACDPinMessagesViewController? = nil;
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(pinnedMessageChanged(_:)), name: NSNotification.Name("PinnedMessages"), object: nil)

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
    
    func setupPinMessageButton() {
        if let image = UIImage(named: "pin") {
            pinMessageButton.setImage(image, for: .normal)
        }

        let title = "Pin Message"
        pinMessageButton.setTitle(title, for: .normal)
        pinMessageButton.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        pinMessageButton.layer.cornerRadius = 8
        pinMessageButton.setTitleColor(UIColor(red: 23.0/255.0, green: 26.0/255.0, blue: 28.0/255.0, alpha: 1.0), for: .normal)
        pinMessageButton.titleLabel?.font = UIFont(name: "SFCompact-Medium", size: 14.0)

        // Set image and title edge insets
        let buttonWidth = self.view.bounds.width - 24
        pinMessageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -(buttonWidth/2 + 20), bottom: 0, right: 0)
        pinMessageButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(buttonWidth/2 + 20) + 20, bottom: 0, right: 0)

        // Set button shadow
        let shadowColor = UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        pinMessageButton.layer.shadowColor = shadowColor.cgColor
        pinMessageButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        pinMessageButton.layer.shadowOpacity = 0.8
        pinMessageButton.layer.shadowRadius = 2.0

        pinMessageButton.addTarget(self, action: #selector(pinMessagesAction), for: .touchUpInside)
        self.view.addSubview(pinMessageButton)
    }
    
    @objc func pinnedMessageChanged(_ notification: Notification) {
        if let userInfo = notification.object as? [String: Any] {
            if let tipMessageId = userInfo["tipMessageId"] as? String {
                if let message = AgoraChatClient.shared().chatManager?.getMessageWithMessageId(tipMessageId) {
                    if message.conversationId == self.conversation?.conversationId {
                        let model = EaseMessageModel(agoraChatMessage: message)
                        self.chatController.dataArray.add(model)
                        self.chatController.refreshTableView(true)
                    }
                }
            }
        }
    }
    
    func showPinnedMessagesView() {
        let pinMessageVC = ACDPinMessagesViewController()
        addChild(pinMessageVC)
        view.addSubview(pinMessageVC.view)
        pinMessageVC.didMove(toParent: self)

        pinMessageVC.view.snp.makeConstraints({ make in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(navigationView.snp.bottom)
        })

        pinMessageVC.selectMessageCompletion = { [weak self] selectedMessageId in
            // jump to pinned message cell
            if selectedMessageId.count > 0 {
                if let msg = AgoraChatClient.shared().chatManager?.getMessageWithMessageId(selectedMessageId) {
                    if let moreMsgId = self?.chatController.moreMsgId,let moreMessage = AgoraChatClient.shared().chatManager?.getMessageWithMessageId( moreMsgId), moreMessage.timestamp > msg.timestamp {
                        self?.conversation?.loadMessages(from: msg.timestamp - 1, to: moreMessage.timestamp, count: 400, completion: { aMessages, aError in
                            if aError == nil,
                               let aMessages = aMessages {
                                var array = [EaseMessageModel]()
                                
                                for msg in aMessages {
                                    let model = EaseMessageModel(agoraChatMessage: msg)
                                    array.append(model)
                                }
                                let indexSet = IndexSet(integersIn: 0..<array.count)
                                self?.chatController.moreMsgId = aMessages.first?.messageId ?? ""
                                self?.chatController.dataArray.insert(array, at: indexSet)
                                self?.chatController.refreshTableView(false)
                                
                                DispatchQueue.main.async {
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self?.chatController.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                    if let cell = self?.chatController.tableView.cellForRow(at: indexPath) {
                                        cell.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            cell.backgroundColor = UIColor.white
                                        }
                                    }
                                }
                            }
                        })
                    } else {
                        var row = 0
                        var indexPath: IndexPath? = nil
                        guard let dataArray = self?.chatController.dataArray else {
                            return
                        }
                        for model in dataArray {
                            if let model = model as? EaseMessageModel, model.message.messageId == msg.messageId {
                                indexPath = IndexPath(row: row, section: 0)
                                break
                            }
                            row += 1
                        }
                        if let indexPath = indexPath {
                            self?.chatController.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
                            if let cell = self?.chatController.tableView.cellForRow(at: indexPath) {
                                cell.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    cell.backgroundColor = UIColor.white
                                }
                            }
                        }
                    }
                } else {
                    self?.showHint("Pinned message not exist")
                }
            }
        }
        pinMessageVC.unpinMessageCompletion = { [weak self] messageId in
            if messageId.count > 0 {
                self?.addPinNotifiMsg(false, userId: AgoraChatClient.shared().currentUsername ?? "", groupId: self?.conversation?.conversationId ?? "")
            }
        }
        pinMessageVC.pinMessages = self.conversation?.pinnedMessages()
        self.pinMessageVC = pinMessageVC
    }
    
    @objc func pinMessagesAction() {
        if let textView = self.chatController.inputBar.value(forKey: "textView") as? UIView {
            textView.resignFirstResponder()
        }
        if let conversationId = self.conversation?.conversationId {
            if !AgoraChatDemoHelper.shared.groupIdHasLocalPinnedMessages.contains(conversationId) {
                AgoraChatClient.shared().chatManager?.getPinnedMessages(fromServer: conversationId, completion: { [weak self] pinnedMessages, err in
                    self?.showPinnedMessagesView()
                    AgoraChatDemoHelper.shared.groupIdHasLocalPinnedMessages.insert(conversationId)
                })
            } else {
                self.showPinnedMessagesView()
            }
        }
    }
    
    func addPinNotifiMsg(_ isPinned: Bool, userId: String, groupId: String) {
        var info = ""
        if isPinned {
            info = "\(userId) pinned a message"
        } else {
            info = "\(userId) removed a pin message"
        }
        let body = AgoraChatTextMessageBody(text: info)
        let message = AgoraChatMessage(conversationID: groupId, body: body, ext: [MSG_EXT_NEWNOTI: NOTI_EXT_ADDGROUP, "agora_notiUserID": userId])
        message.chatType = .groupChat
        message.isRead = true
        if let conversation = AgoraChatClient.shared().chatManager?.getConversation(groupId, type: .groupChat, createIfNotExist: true) {
            self.conversation?.insert(message, error: nil)
            let newModel = EaseMessageModel(agoraChatMessage: message)
            self.chatController.dataArray.add(newModel)
            self.chatController.refreshTableView(true)
        }
    }
    
    func addPinMessageButton() {
        self.view.addSubview(self.pinMessageButton)
        self.pinMessageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pinMessageButton.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 0),
            self.pinMessageButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12),
            self.pinMessageButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.pinMessageButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        self.view.bringSubviewToFront(self.pinMessageButton)
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
        if self.conversation?.type == .groupChat {
            setupPinMessageButton()
            addPinMessageButton()
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
        if self.conversation?.type == .groupChat,messageModel.message.status == .succeed {
            let pinItem = EaseExtendMenuModel(data: UIImage(named: "pin")!, funcDesc: "Pin") { [weak self] (itemDesc, isExecuted) in
            AgoraChatClient.shared().chatManager?.pinMessage(messageModel.message.messageId) { [weak self] (message, aError) in
                if aError == nil {
                    self?.showHint("Pin message success")
                    self?.addPinMessageButton()
                    self?.addPinNotifiMsg(true, userId: AgoraChatClient.shared().currentUsername ?? "", groupId: self?.conversation?.conversationId ?? "")
                } else {
                    self?.showHint("Pin failed, \(aError?.errorDescription ?? "")")
                    }
                }
            }
            defaultLongPressItems.add(pinItem)
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
    
    func joinGroupRequestDidDecline(_ aGroupId: String, reason aReason: String?, decliner aDecliner: String?, applicant aApplicant: String) {
        
    }
}

extension ACDChatViewController: AgoraChatManagerDelegate {
    func onMessagePinChanged(_ messageId: String, conversationId: String, operation pinOperation: AgoraChatMessagePinOperation, pinInfo: AgoraChatMessagePinInfo) {
        if let message = AgoraChatClient.shared().chatManager?.getMessageWithMessageId(messageId),message.conversationId == self.conversation?.conversationId {
            if let pinMessageVC = self.pinMessageVC {
                pinMessageVC.pinMessages = self.conversation?.pinnedMessages()
            }
        }
    }
}
