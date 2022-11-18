//
//  ACDContactInfoViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/17.
//

import UIKit

@objcMembers
class ACDContactInfoViewController: ACDBaseTableViewController {
    
    private let contactInfoHeaderView = ACDInfoHeaderView.create(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 360), type: .contact)

    private let userId: String
    private var model: AgoraUserModel?
    private let isChatButtonHidden: Bool
    
    var addBlackListHandle: (() -> Void)?
    var deleteContactHandle: (() -> Void)?
    
    init(userId: String, isChatButtonHidden: Bool = false) {
        self.userId = userId
        self.isChatButtonHidden = isChatButtonHidden
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "black_goBack"), style: .plain, target: self, action: #selector(backAction))
        
        self.table.bounces = false
        self.table.tableHeaderView = self.contactInfoHeaderView
        self.table.rowHeight = 54
        self.table.backgroundColor = .white
        self.table.keyboardDismissMode = .onDrag
        self.table.register(UINib(nibName: "ACDInfoCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.contactInfoHeaderView.isHideChatButton = self.isChatButtonHidden
        self.contactInfoHeaderView.tapHeaderHandle = { [unowned self] in
            self.headerViewTapAction()
        }
        self.contactInfoHeaderView.goChatPageHandle = { [unowned self] in
            guard let model = self.model else {
                return
            }
            let vc = ACDChatViewController(conversationId: self.userId, conversationType: .chat)
            vc.navTitle = model.showName
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        UserInfoStore.shared.fetchUserInfosFromServer(userIds: [self.userId], refresh: true) {
            MBProgressHUD.hide(for: self.view, animated: true)
            let model = AgoraUserModel(hyphenateId: self.userId)
            if let info = UserInfoStore.shared.getUserInfo(userId: self.userId) {
                model.setUserInfo(info)
            }
            self.model = model
            self.contactInfoHeaderView.nameLabel.text = model.showName
            self.contactInfoHeaderView.userIdLabel.text = model.hyphenateId
            self.contactInfoHeaderView.avatarImageView.setImage(withUrl: model.avatarURLPath, placeholder: model.defaultAvatar)
        }
        
        self.updatePresenceStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.table.frame = self.view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc private func backAction() {
        NotificationCenter.default.post(name: ConversationsUpdatedNotification, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updatePresenceStatus() {
        AgoraChatClient.shared().presenceManager?.fetchPresenceStatus([self.userId], completion: { presences, error in
            let status = PresenceManager.fetchStatus(presence: presences?.first)
            if let imageName = PresenceManager.whiteStrokePresenceImagesMap[status] {
                DispatchQueue.main.async {
                    self.contactInfoHeaderView.avatarImageView.presenceImage = UIImage(named: imageName)
                }
            }
        })
    }

    private func headerViewTapAction() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Copy AgoraID".localized, iconImage: UIImage(named: "action_icon_copy"), textColor: .black, alignment: .left, completion: { _ in
            UIPasteboard.general.string = self.userId
        }))
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(vc, animated: true)
    }
 
    private func addBlackList() {
        AgoraChatClient.shared().contactManager?.addUser(toBlackList: self.userId, completion: { username, error in
            if error != nil {
                self.showAlert(message: "Operation failed".localized)
            } else {
                self.addBlackListHandle?()
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    private func deleteContact() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().contactManager?.deleteContact(self.userId, isDeleteConversation: true, completion: { username, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                self.showAlert(message: "Delete contacts failed".localized)
            } else {
                self.deleteContactHandle?()
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDInfoCell {
            if indexPath.row == 0 {
                cell.iconImageView.image = UIImage(named: "notifications_yellow")
                cell.nameLabel.text = "Notifications".localized
                cell.accessoryType = .disclosureIndicator
            } else if indexPath.row == 1 {
                cell.iconImageView.image = UIImage(named: "blocked")
                cell.nameLabel.text = "Block Contact".localized
                cell.accessoryType = .none
            } else if indexPath.row == 2 {
                cell.iconImageView.image = UIImage(named: "delete")
                cell.nameLabel.text = "Delete Contact".localized
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = ACDNotificationSettingViewController()
            vc.notificationType = .singleChat
            vc.conversationID = self.userId
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = UIAlertController(title: "Block this contact now?".localized, message: "When you block this contact, you will not receive any messages from them.".localized, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
            let blackAction = UIAlertAction(title: "Block".localized, style: .default, handler: { _ in
                self.addBlackList()
            })
            blackAction.setValue(Color_FF14CC, forKey: "titleTextColor")
            vc.addAction(blackAction)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        } else if indexPath.row == 2 {
            let vc = UIAlertController(title: "Delete this contact now?".localized, message: "Delete this contact and associated Chats.".localized, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
            let deleteAction = UIAlertAction(title: "Delete".localized, style: .default) { _ in
                self.deleteContact()
            }
            deleteAction.setValue(Color_FF14CC, forKey: "titleTextColor")
            vc.addAction(deleteAction)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
}
