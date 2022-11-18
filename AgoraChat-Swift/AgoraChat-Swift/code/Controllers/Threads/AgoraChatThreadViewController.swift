//
//  AgoraChatThreadViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class AgoraChatThreadViewController: UIViewController {

    private let conversation: AgoraChatConversation?
    private let conversationModel: EaseConversationModel?
    private let conversationType: AgoraChatConversationType
    private let conversationId: String
    private let chatController: EaseThreadChatViewController
    private let navBar = AgoraChatThreadListNavgation()
    
    var detail: String? {
        didSet {
            if let detail = detail {
                self.navBar.detail = "# \(detail)"
            } else {
                self.navBar.detail = ""
            }
        }
    }
    var navTitle: String? {
        didSet {
            self.navBar.title = navTitle
        }
    }
    var createPush = false
    
    init(conversationId: String, type: AgoraChatConversationType, viewModel: EaseChatViewModel, parentMessageId: String, model: EaseMessageModel?) {
        self.conversation = AgoraChatClient.shared().chatManager?.getConversation(conversationId, type: type, createIfNotExist: true, isThread: true)
        if let conversation = conversation {
            self.conversationModel = EaseConversationModel(conversation: conversation)
        } else {
            self.conversationModel = nil
        }
        self.conversationType = type
        self.conversationId = conversationId
        let viewModel = EaseChatViewModel()
        viewModel.displaySentAvatar = false
        viewModel.displaySentName = false
        if type != .groupChat {
            viewModel.displayReceiverName = false
        }
        self.chatController = EaseThreadChatViewController(threadChatViewControllerWithCoversationid: conversationId, chatViewModel: viewModel, parentMessageId: parentMessageId, model: model)
        
        if let threadName = model?.message.chatThread?.threadName, threadName.count > 0 {
            self.navBar.title = threadName
        }
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Color_F2F2F2
        
        self.navBar.backgroundColor = .white
        self.navBar.backHandle = { [unowned self] in
            if self.createPush {
                self.popDestinationVC()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        self.navBar.isMoreHidden = false
        self.navBar.moreHandle = { [unowned self] in
            self.chatController.view.endEditing(true)
            self.showSheet()
        }
        
        self.addChild(self.chatController)
        self.view.addSubview(self.navBar)
        self.view.addSubview(self.chatController.view)
        
        self.navBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.chatController.view.snp.top)
        }
        self.chatController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(44)
        }
        
        if let edit = self.chatController.tableView.tableHeaderView?.viewWithTag(678)?.viewWithTag(919) as? UIButton {
            edit.addTarget(self, action: #selector(editThread), for: .touchUpInside)
        }

        if self.conversation?.unreadMessagesCount ?? 0 > 0 {
            AgoraChatClient.shared().chatManager?.ackConversationRead(self.conversationId, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func editThread() {
        let vc = AgoraChatThreadEditViewController(threadId: self.conversationId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func lookMembers() {
        let vc = AgoraChatThreadMembersViewController(threadId: self.conversationId, group: self.chatController.group)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showSheet() {
        var menuList: [EaseExtendMenuModel] = []
        let memberModel = EaseExtendMenuModel(data: UIImage(named: "thread_members")!, funcDesc: "Thread Members".localized) { _, _ in
            self.lookMembers()
        }
        memberModel.showMore = true
        menuList.append(memberModel)
        
        let nofitfyModel = EaseExtendMenuModel(data: UIImage(named: "thread_notifications")!, funcDesc: "Thread Notifications".localized) { _, _ in
            self.pushThreadNotifySetting()
        }
        nofitfyModel.showMore = true
        menuList.append(nofitfyModel)
        
        if self.chatController.isAdmin == "1" || self.chatController.owner.lowercased() == AgoraChatClient.shared().currentUsername?.lowercased() {
            let editModel = EaseExtendMenuModel(data: UIImage(named: "thread_edit_black")!, funcDesc: "Edit Thread".localized) { _, _ in
                self.editThread()
            }
            editModel.showMore = true
            menuList.append(editModel)
        }
        
        let leaveModel = EaseExtendMenuModel(data: UIImage(named: "thread_leave")!, funcDesc: "Leave Thread".localized) { _, _ in
            self.showAlert(type: 1)
        }
        menuList.append(leaveModel)
        
        if self.chatController.isAdmin == "1" {
            let destoryModel = EaseExtendMenuModel(data: UIImage(named: "groupInfo_deband")!, funcDesc: "Disband Thread".localized) { _, _ in
                self.showAlert(type: 2)
            }
            destoryModel.funcDescColor = Color_FF14CC
            menuList.append(destoryModel)
        }
        EMBottomMoreFunctionView.showMenuItems(menuList, delegate: self, animation: true)
    }
    
    private func pushThreadNotifySetting() {
        let vc = ACDNotificationSettingViewController()
        vc.notificationType = .thread
        vc.conversationID = self.conversationId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func popDestinationVC() {
        guard let navigationController = self.navigationController else {
            return
        }
        var target: UIViewController?
        for vc in navigationController.viewControllers where vc is ACDChatViewController {
            target = vc
            break
        }
        if let target = target {
            navigationController.popToViewController(target, animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
    
    private func showAlert(type: Int) {
        let title = type == 1 ? "Leave Thread".localized : "Disband Thread".localized
        let vc = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        vc.addAction(UIAlertAction(title: "Confirm".localized, style: .destructive, handler: { _ in
            if type == 1 {
                self.leaveThread()
            } else {
                self.destoryThread()
            }
        }))
        self.present(vc, animated: true)
    }
    
    private func leaveThread() {
        AgoraChatClient.shared().threadManager?.leaveChatThread(self.conversationId, completion: { error in
            if let error = error {
                self.showHint(error.errorDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    private func destoryThread() {
        AgoraChatClient.shared().threadManager?.destroyChatThread(self.conversationId, completion: { error in
            if let error = error {
                self.showHint(error.errorDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AgoraChatThreadViewController: EaseChatViewControllerDelegate {
    func userProfile(_ userID: String) -> EaseUserProfile? {
        if userID.count <= 0 {
            return nil
        }
        if let userInfo = UserInfoStore.shared.getUserInfo(userId: userID) {
            return AgoraChatUserDataModel(userInfo: userInfo)
        } else {
            UserInfoStore.shared.fetchUserInfosFromServer(userIds: [userID])
        }
        return nil
    }
    
    func didSend(_ message: AgoraChatMessage, error: AgoraChatError?) {
        if let error = error {
            self.showHint(error.errorDescription)
        }
    }
    
    func threadNameChange(_ threadName: String) {
        self.navBar.title = threadName
        if let groupName = self.chatController.group.groupName {
            self.navBar.detail = groupName
        }
    }
}

extension AgoraChatThreadViewController: EMBottomMoreFunctionViewDelegate {
    func bottomMoreFunctionView(_ view: EMBottomMoreFunctionView, didSelectedMenuItem model: EaseExtendMenuModel) {
        model.itemDidSelectedHandle(model.funcDesc, true)
        EMBottomMoreFunctionView.hide(withAnimation: true, needClear: false)
    }
}
