//
//  ACDSettingsViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/12.
//

import UIKit
import AgoraChat

class ACDSettingsViewController: UITableViewController {

    @IBOutlet weak var headImageView: AgoraChatAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var aboutDescLabel: UILabel!
    
    private var myNickName: String?
    private var userInfo: AgoraChatUserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(presencesUpdated(_:)), name: PresenceUpdateNotification, object: nil)
        
        self.aboutDescLabel.text = "\("AgoraChat".localized) \(AgoraChatClient.shared().version)"
        
        self.myNickName = AgoraChatClient.shared().currentUsername
        self.updateHeaderView()
        self.updatePresenceStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.fetchUserInfo()
    }

    private func fetchUserInfo() {
        if let userId = AgoraChatClient.shared().currentUsername {
            UserInfoStore.shared.fetchUserInfosFromServer(userIds: [userId]) {
                if let userInfo = UserInfoStore.shared.getUserInfo(userId: userId) {
                    self.userInfo = userInfo
                    self.myNickName = userInfo.showName
                    self.updateHeaderView()
                }
            }
        }
    }
    
    @objc @IBAction private func headerViewTapAction() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Change Avatar".localized, iconImage: UIImage(named: "action_icon_change_avatar"), textColor: .black, alignment: .left, completion: { _ in
            let vc = ACDModifyAvatarViewController()
            vc.selectedHandle = { imageName in
                UserDefaults.standard.set(imageName, forKey: "\(self.userInfo?.userId ?? "")_avatar")
                UserDefaults.standard.synchronize()
                self.headImageView.image = UIImage(named: imageName)
            }
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Change Nickname".localized, iconImage: UIImage(named: "action_icon_edit"), textColor: .black, alignment: .left, completion: { _ in
            self.changeNickName()
        }))
        alertController.addAction(UIAlertAction(title: "Copy AgoraID".localized, iconImage: UIImage(named: "action_icon_copy"), textColor: .black, alignment: .left, completion: { _ in
            if let userId = self.userInfo?.userId {
                UIPasteboard.general.string = userId
            }
        }))
        alertController.addAction(UIAlertAction(title: "Set Status".localized, iconImage: UIImage(named: "set_status"), textColor: .black, alignment: .left, completion: { _ in
            let presenceVC = ACDPresenceSettingViewController()
            presenceVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(presenceVC, animated: true)
        }))
        alertController.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(alertController, animated: true)
    }
    
    @objc private func presencesUpdated(_ notification: Notification) {
        if let username = AgoraChatClient.shared().currentUsername, username.count > 0, let objects = notification.object as? [String], objects.contains(username) {
            self.updatePresenceStatus()
        }
    }
    
    private func updatePresenceStatus() {
        guard let username = AgoraChatClient.shared().currentUsername, username.count > 0 else {
            return
        }
        if let presence = PresenceManager.shared.presences[username] {
            let status = PresenceManager.fetchStatus(presence: presence)
            if let imageName = PresenceManager.whiteStrokePresenceImagesMap[status] {
                DispatchQueue.main.async {
                    self.headImageView.presenceImage = UIImage(named: imageName)
                }
            }
        } else {
            let status: PresenceManager.State = AgoraChatClient.shared().isConnected ? .online : .offline
            if let imageName = PresenceManager.whiteStrokePresenceImagesMap[status] {
                DispatchQueue.main.async {
                    self.headImageView.presenceImage = UIImage(named: imageName)
                }
            }
        }
    }
    
    private func updateHeaderView() {
        guard let userId = AgoraChatClient.shared().currentUsername else {
            return
        }
        self.nameLabel.text = self.myNickName
        self.userIdLabel.text = "\("AgoraID".localized): \(userId)"
        
        if let url = self.userInfo?.avatarUrl, url.count > 0 {
            self.headImageView.setImage(withUrl: url, placeholder: "defatult_avatar_1")
        } else {
            let imageName = UserDefaults.standard.object(forKey: "\(self.userInfo?.userId ?? "")_avatar") as? String ?? "defatult_avatar_1"
            self.headImageView.image = UIImage(named: imageName)
        }
    }
    
    private func changeNickName() {
        let alertController = UIAlertController(title: "Change Nickname".localized, message: nil, preferredStyle: .alert)
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        alertController.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default, handler: { [unowned alertController] _ in
            if let text = alertController.textFields?.first?.text {
                self.updateMyNickname(text)
            }
        }))
        self.present(alertController, animated: true)
    }
    
    private func updateMyNickname(_ name: String) {
        guard name.count > 0, self.myNickName != name else {
            return
        }
        self.myNickName = name
        self.nameLabel.text = name
        
        AgoraChatClient.shared().userInfoManager?.updateOwnUserInfo(name, with: .nickName, completion: { userInfo, error in
            DispatchQueue.main.async {
                if let userInfo = userInfo {
                    UserInfoStore.shared.setUserInfo(userInfo, userId: AgoraChatClient.shared().currentUsername!)
                    NotificationCenter.default.post(name: UserInfoDidChangeNotification, object: nil, userInfo: [
                        "userinfo_list": [userInfo]
                    ])
                }
                self.tableView.reloadData()
            }
        })
    }
    
    private func logout() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().logout(true) { error in
            MBProgressHUD.hide(for: self.view, animated: true)
            NotificationCenter.default.post(name: LoginStateChangedNotification, object: false, userInfo: [
                "userName": "",
                "nickName": ""
            ])
            if let error = error {
                self.showHint(error.errorDescription)
            } else {
                let userDefaults = UserDefaults.standard
                userDefaults.set("", forKey: "user_name")
                userDefaults.set("", forKey: "nick_name")
                userDefaults.synchronize()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ACDSettingsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                let vc = ACDNotificationSettingViewController()
                vc.notificationType = .me
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 2 {
                let vc = ACDPrivacyViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            let alertController = UIAlertController(title: "Sure to Quit?".localized, message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: LocalizedString.Cancel, style: .cancel)
            cancelAction.setValue(Color_154DFE, forKey: "titleTextColor")
            
            let confirmAction = UIAlertAction(title: "Confirm".localized, style: .default) { [unowned self] _ in
                self.logout()
            }
            confirmAction.setValue(Color_154DFE, forKey: "titleTextColor")
            
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
