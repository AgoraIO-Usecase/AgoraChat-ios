//
//  ACDChatsViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/14.
//

import UIKit
import SnapKit
import AgoraChat

class ACDChatsViewController: UIViewController {

    private let navView = ACDNaviCustomView()
    private var easeConvsVC: EaseConversationsViewController!
    private let viewModel = EaseConversationViewModel()
    private let avatarView = AgoraChatAvatarView()
    private let presenceButton = UIButton(type: .custom)
    private var resultController: AgoraChatSearchResultController?
    private let tableViewHeaderView = UIView()
    
    private let realtimeSearchUtil = AgoraRealtimeSearchUtils()
    
    var deleteConversationCompletion: ((_ isDelete: Bool) -> Void)?
    
    private lazy var networkStateView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        view.backgroundColor = Color_00BA6E
        let imageView = UIImageView(frame: CGRect(x: 10, y: (view.bounds.height - 20) / 2, width: 20, height: 20))
        view.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: imageView.frame.maxX + 5, y: 0, width: view.frame.width - imageView.frame.maxX - 15, height: view.frame.height))
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .gray
        label.backgroundColor = .clear
        label.text = "Network disconnected".localized
        view.addSubview(label)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetUserInfo(_:)), name: UserInfoDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createGroupNotification(_:)), name: GroupCreatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presencesUpdated(_:)), name: PresenceUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshConversationList), name: ConversationsUpdatedNotification, object: nil)
        
        self.setupSubviews()
        
        if !UserDefaults.standard.bool(forKey: "isFirstLaunch") {
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            UserDefaults.standard.synchronize()
            self.refreshTableViewWithData()
        }
    }

    private func setupSubviews() {
        self.navView.addActionHandle = { [unowned self] in
            self.chatInfoAction()
        }
        self.navView.titleImageView.image = UIImage(named: "nav_title_chats")
        self.navView.addButton.setImage(UIImage(named: "chat_nav_add"), for: .normal)

        self.avatarView.layer.cornerRadius = 17
        self.avatarView.layer.masksToBounds = true
        self.navView.addSubview(self.avatarView)

        self.avatarView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.bottom.equalTo(0)
            make.width.height.equalTo(34)
        }
        if let username = AgoraChatClient.shared().currentUsername, let url = UserInfoStore.shared.getUserInfo(userId: username)?.avatarUrl {
            self.avatarView.setImage(withUrl: url, placeholder: "defatult_avatar_1")
        } else {
            let imageName = (UserDefaults.standard.value(forKey: "\(AgoraChatClient.shared().currentUsername ?? "")_avatar") as? String) ?? "defatult_avatar_1"
            self.avatarView.image = UIImage(named: imageName)
        }
        
        let state: PresenceManager.State = AgoraChatClient.shared().isConnected ? .online : .offline
        self.presenceButton.setTitle(PresenceManager.showStatusMap[state], for: .normal)
        if let imageName = PresenceManager.whiteStrokePresenceImagesMap[state] {
            self.avatarView.presenceImage = UIImage(named: imageName)
        }
        
        self.presenceButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.presenceButton.titleLabel?.lineBreakMode = .byTruncatingTail
        self.presenceButton.setTitleColor(.black, for: .normal)
        self.presenceButton.contentHorizontalAlignment = .right
        self.presenceButton.setImage(UIImage(named: "go_small_black_mobile"), for: .normal)
        self.presenceButton.addTarget(self, action: #selector(setPresence), for: .touchUpInside)
        self.presenceButton.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.presenceButton.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.presenceButton.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.navView.addSubview(self.presenceButton)
        
        self.presenceButton.snp.makeConstraints { make in
            make.left.equalTo(self.avatarView.snp.right).offset(3)
            make.bottom.equalTo(self.avatarView)
            make.height.equalTo(15)
            make.width.equalTo(100)
        }
        self.updatePresenceStatus()
        
        self.viewModel.canRefresh = true
        self.viewModel.badgeLabelCenterVector = CGVector(dx: -16, dy: 0)
        self.easeConvsVC = EaseConversationsViewController(model: self.viewModel)
        self.easeConvsVC.delegate = self
        self.addChild(self.easeConvsVC)
        self.view.addSubview(self.easeConvsVC.view)
        self.view.addSubview(self.navView)
        
        self.navView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.easeConvsVC.view.snp.top).offset(-5)
        }
        self.easeConvsVC.view.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            make.left.right.bottom.equalTo(self.view)
        }
        self.updateConversationViewTableHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func updateConversationViewTableHeader() {
        self.easeConvsVC.tableView.tableHeaderView = self.tableViewHeaderView
        self.easeConvsVC.tableView.tableHeaderView?.backgroundColor = .white
        let control = UIControl()
        control.clipsToBounds = true
        control.layer.cornerRadius = 18
        control.backgroundColor = Color_F2F2F2
        let tap = UITapGestureRecognizer(target: self, action: #selector(searchButtonAction))
        control.addGestureRecognizer(tap)
        
        self.tableViewHeaderView.snp.updateConstraints({ make in
            make.left.width.top.equalTo(self.easeConvsVC.tableView)
            make.height.equalTo(54)
        })
        self.easeConvsVC.tableView.tableHeaderView?.addSubview(control)
        control.snp.updateConstraints { make in
            make.height.equalTo(36)
            make.bottom.equalTo(self.tableViewHeaderView).offset(-8)
            make.left.equalTo(self.tableViewHeaderView).offset(16)
            make.right.equalTo(self.tableViewHeaderView).offset(-16)
        }
        
        let imageView = UIImageView(image: UIImage(named: "search"))
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Search".localized
        label.textColor = Color_999999
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let subView = UIView()
        subView.addSubview(imageView)
        subView.addSubview(label)
        control.addSubview(subView)
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.left.top.bottom.equalTo(subView)
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right)
            make.right.top.bottom.equalTo(subView)
        }
        
        subView.snp.makeConstraints { make in
            make.centerY.left.equalTo(control)
        }
    }
     
    func networkChanged(state: AgoraChatConnectionState) {
//        if state == .disconnected {
//            self.easeConvsVC.tableView.tableHeaderView = self.networkStateView
//        } else {
            self.easeConvsVC.tableView.tableHeaderView = self.tableViewHeaderView
//        }
    }
    
    @objc private func searchButtonAction() {
        if self.resultController == nil {
            self.resultController = AgoraChatSearchResultController()
            self.resultController?.delegate = self
            self.setupSearchResultController()
        }
        self.resultController?.searchBar.becomeFirstResponder()
        self.resultController?.searchBar.showsCancelButton = true
        self.resultController?.modalPresentationStyle = .fullScreen
        self.present(self.resultController!, animated: true)
    }
    
    private func setupSearchResultController() {
        self.resultController?.tableView.rowHeight = UITableView.automaticDimension
        self.resultController?.cellForRowAtIndexPathCompletion = { [unowned self] tableView, indexPath in
            var cell: EaseConversationCell! = EaseConversationCell.tableView(tableView, identifier: "EaseConversationCell")
            if cell == nil {
                cell = EaseConversationCell(conversationsViewModel: self.viewModel, identifier: "EaseConversationCell")
            }
            let model = self.resultController?.dataArray[indexPath.row] as? EaseConversationModel
            cell.model = model
            return cell
        }
        self.resultController?.canEditRowAtIndexPath = { tableView, indexPath in
            return true
        }
        self.resultController?.trailingSwipeActionsConfigurationForRowAtIndexPath = { [unowned self] tableView, indexPath in
            let model = self.resultController?.dataArray[indexPath.row] as! EaseConversationModel
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized, handler: { [unowned self] action, sourceView, completionHandler in
                self.resultController?.tableView.isEditing = false
                let unreadCount = AgoraChatClient.shared().chatManager?.getConversationWithConvId(model.easeId)?.unreadMessagesCount ?? 0
                AgoraChatClient.shared().chatManager?.deleteConversation(model.easeId, isDeleteMessages: true, completion: { _, error in
                    if error == nil {
                        self.resultController?.dataArray.remove(at: indexPath.row)
                        self.resultController?.tableView.reloadData()
                        if unreadCount > 0 {
                            self.deleteConversationCompletion?(true)
                        }
                    }
                })
            })
            let topAction = UIContextualAction(style: .normal, title: model.isTop ? "Unsticky".localized : "Sticky".localized, handler: { action, sourceView, completionHandler in
                self.resultController?.tableView.isEditing = false
                model.isTop = !model.isTop
                self.easeConvsVC.refreshTable()
                
            })
            let actions = UISwipeActionsConfiguration(actions: [deleteAction, topAction])
            actions.performsFirstActionWithFullSwipe = false
            return actions
        }
        
        self.resultController?.didSelectRowAtIndexPathCompletion = { [unowned self] tableView, indexPath in
            let model = self.resultController?.dataArray[indexPath.row] as! EaseConversationModel
            self.resultController?.searchBar.text = ""
            self.resultController?.searchBar.resignFirstResponder()
            self.resultController?.searchBar.showsCancelButton = false
            self.searchBarCancelButtonAction(self.resultController!.searchBar)
            self.resultController?.dismiss(animated: true)
            
            NotificationCenter.default.post(name: UnreadMessageCountChangeNotification, object: nil)
            let vc = ACDChatViewController(conversationId: model.easeId, conversationType: model.type)
            vc.navTitle = model.showName
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func formateConversations(_ conversations: [AgoraChatConversation]) -> [EaseConversationModel] {
        var convs: [EaseConversationModel] = []
        for conv in conversations {
            if conv.latestMessage == nil {
                continue
            }
            if conv.type == .chatRoom && !self.viewModel.displayChatroom {
                continue
            }
            let item = EaseConversationModel(conversation: conv)
            item.userProfile = self.easeUserProfile(atConversationId: conv.conversationId, conversationType: conv.type)
            convs.append(item)
        }
        
        let normalConvList = convs.sorted { obj1, obj2 in
            return obj1.lastestUpdateTime > obj2.lastestUpdateTime
        }
        return normalConvList
    }
    
    private func refreshTableViewWithData() {
        AgoraChatClient.shared().chatManager?.getConversationsFromServer({ conversations, error in
            if let conversations = conversations, conversations.count > 0 {
                self.easeConvsVC.dataAry.removeAllObjects()
                self.easeConvsVC.dataAry.addObjects(from: self.formateConversations(conversations))
                self.easeConvsVC.refreshTable()
            }
        })
    }
    
    @objc private func resetUserInfo(_ notification: Notification) {
        guard let userInfoList = (notification.userInfo as? [String: Any])?["userinfo_list"] as? [AgoraChatUserInfo], userInfoList.count <= 0 else {
            return
        }
        var userInfoAry: [AgoraChatConvUserDataModel] = []
        for userInfo in userInfoList {
            let model = AgoraChatConvUserDataModel(userInfo: userInfo, conversationType: .chat)
            userInfoAry.append(model)
        }
        self.easeConvsVC.resetUserProfiles(userInfoAry)
    }
    
    @objc private func createGroupNotification(_ notification: Notification) {
        guard let info = notification.userInfo as? [String: Any] else {
            return
        }
        let group = info["group"] as? AgoraChatGroup
        guard let group = group else {
            return
        }
        let invitees = info["invitees"] as? [String]
        var mutableStr: String = ""
        if let invitees = invitees, invitees.count > 0 {
            for str in invitees {
                mutableStr += str
                mutableStr += ", "
            }
            mutableStr.removeLast()
        }
        
        let hintMsg: String
        if mutableStr.count > 0 {
            hintMsg = String(format: "You invited %@ to join the group".localized, mutableStr)
        } else {
            hintMsg = String(format: "You have created a group %@".localized, group.groupName ?? "")
        }
        let body = AgoraChatTextMessageBody(text: hintMsg)
        let message = AgoraChatMessage(conversationID: group.groupId, from: AgoraChatClient.shared().currentUsername!, to: AgoraChatClient.shared().currentUsername!, body: body, ext: [
            "agora_noti": "agora_addGroup",
            "agora_notiUserID": mutableStr
        ])
        message.chatType = .groupChat
        message.isRead = true
        let conversation = AgoraChatClient.shared().chatManager?.getConversation(group.groupId, type: .groupChat, createIfNotExist: true)
        conversation?.insert(message, error: nil)
        
        let chatViewController = ACDChatViewController(conversationId: group.groupId, conversationType: .groupChat)
        chatViewController.navTitle = group.groupName
        chatViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    @objc private func presencesUpdated(_ notification: Notification) {
        guard let username = AgoraChatClient.shared().currentUsername, let list = notification.object as? [String] else {
            return
        }
        if list.contains(username) {
            self.updatePresenceStatus()
        }
    }
    
    private func chatInfoAction() {
        let vc = ACDGroupEnterController()
        vc.accessType = .chat
        let nav = UINavigationController(rootViewController: vc)
        nav.view.backgroundColor = .white
        self.navigationController?.present(nav, animated: true)
    }
    
    private func updatePresenceStatus() {
        guard let username = AgoraChatClient.shared().currentUsername else {
            return
        }
        guard let presence = PresenceManager.shared.presences[username] else {
            return
        }
        let status = PresenceManager.fetchStatus(presence: presence)
        if let imageName = PresenceManager.whiteStrokePresenceImagesMap[status] {
            self.avatarView.presenceImage = UIImage(named: imageName)
        }
        var showStatus: String?
        if status == .offline {
            showStatus = PresenceManager.formatOfflineTimespace(presence: presence)
        } else {
            showStatus = PresenceManager.showStatusMap[status]
        }
        if status != .offline, let statusDescription = presence.statusDescription, statusDescription.count > 0 {
            self.presenceButton.setTitle(statusDescription, for: .normal)
        } else {
            self.presenceButton.setTitle(showStatus, for: .normal)
        }
    }
    
    private func createStatusAlertAction(title: String, image: UIImage?, handle: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .default, handler: handle)
        if let image = image {
            action.setValue(image.withRenderingMode(.alwaysOriginal), forKey: "image")
        }
        action.setValue(0, forKey: "titleTextAlignment")
        action.setValue(UIColor.black, forKey: "titleTextColor")
        return action
    }
    
    private func updateCustomStatus() {
        let alertController = UIAlertController(title: "Custom Status".localized, message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.delegate = self
            textField.placeholder = "Input custom status".localized
        }
        alertController.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        alertController.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default, handler: { [unowned alertController] _ in
            if let text = alertController.textFields?.first?.text {
                PresenceManager.shared.publishPresence(description: text, completion: nil)
            }
        }))
        self.present(alertController, animated: true)
    }
    
    @objc private func setPresence() {
        let statusList: [PresenceManager.State] = [.online, .busy, .doNotDisturb, .leave, .custom]
        let alertController = UIAlertController(title: "Status".localized, message: nil, preferredStyle: .actionSheet)
        let presence = PresenceManager.shared.presences[AgoraChatClient.shared().currentUsername!]
        for status in statusList {
            var image: UIImage? = nil
            if let imageName = PresenceManager.presenceImagesMap[status] {
                image = UIImage(named: imageName)
            }
            var text: String
            if status == .custom {
                if let statusDescription = presence?.statusDescription, statusDescription.count > 0 {
                    text = statusDescription
                } else {
                    text = "Custom Status".localized
                }
            } else {
                text = PresenceManager.showStatusMap[status]!
            }
            alertController.addAction(self.createStatusAlertAction(title: text, image: image, handle: { _ in
                if status != .custom {
                    if let presenceDescription = PresenceManager.showStatusMap[status] {
                        PresenceManager.shared.publishPresence(description: presenceDescription, completion: nil)
                    }
                } else {
                    self.updateCustomStatus()
                }
            }))
        }
        alertController.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(alertController, animated: true)
    }
    
    @objc private func refreshConversationList() {
        self.easeConvsVC.refreshTabView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ACDChatsViewController: EaseConversationsViewControllerDelegate {
    // UIKit 根据会话类型和会话ID返回显示的数据对象
    func easeUserProfile(atConversationId conversationId: String, conversationType type: AgoraChatConversationType) -> EaseUserProfile {
        if type == .chat {
            let userInfo: AgoraChatUserInfo? = UserInfoStore.shared.getUserInfo(userId: conversationId)
            if let userInfo = userInfo {
                return AgoraChatConvUserDataModel(userInfo: userInfo, conversationType: type)
            } else {
                UserInfoStore.shared.fetchUserInfosFromServer(userIds: [conversationId])
            }
        }
        
        let userInfo = AgoraChatUserInfo()
        userInfo.userId = conversationId
        return AgoraChatConvUserDataModel(userInfo: userInfo, conversationType: type)
    }
    
    // UIKit 点击了会话
    func easeTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? EaseConversationCell
        if let easeId = cell?.model.easeId, let mode = cell?.model.type {
            let vc = ACDChatViewController(conversationId: easeId, conversationType: mode)
            if let showName = cell?.model.showName {
                vc.navTitle = showName
            }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ACDChatsViewController: AgoraChatSearchControllerDelegate {
    func searchBarWillBeginEditing(_ searchBar: UISearchBar) {
        self.resultController?.searchKeyword = nil
    }
    
    func searchBarCancelButtonAction(_ searchBar: UISearchBar) {
        self.realtimeSearchUtil.cancel()
        if let dataArray = self.resultController?.dataArray, dataArray.count > 0 {
            self.resultController?.dataArray.removeAll()
        }
        self.resultController?.tableView.reloadData()
        self.easeConvsVC.refreshTabView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }

    func searchTextDidChange(_ text: String) {
        self.resultController?.searchKeyword = text
        self.realtimeSearchUtil.realSearch(source: self.easeConvsVC.dataAry as! [EaseConversationModel], keyword: text) { result in
            self.resultController?.dataArray.removeAll()
            self.resultController?.dataArray.append(contentsOf: result)
            self.resultController?.tableView.reloadData()
        }
    }
}

extension ACDChatsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text as? NSString)?.replacingCharacters(in: range, with: string)
        return (str?.count ?? 0) <= 64
    }
}
