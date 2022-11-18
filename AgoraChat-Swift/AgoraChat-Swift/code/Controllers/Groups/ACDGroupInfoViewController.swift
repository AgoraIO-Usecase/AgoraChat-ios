//
//  ACDGroupInfoViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/20.
//

import UIKit

@objc
enum ACDGroupInfoAccessType: Int {
    case contact = 0
    case chat
    case search
}

@objcMembers
class ACDGroupInfoViewController: UIViewController {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupIdLabel: UILabel!
    @IBOutlet weak var groupDescribeLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var membersView: UIView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var fileView: UIView!
    @IBOutlet weak var transferView: UIView!
    @IBOutlet weak var disbandView: UIView!
    @IBOutlet weak var leaveView: UIView!
    
    @IBOutlet weak var joinViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var membersViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var noticeViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var fileViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var transferViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var disbandViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var leaveViewHeightContraint: NSLayoutConstraint!
    
    private let accessType: ACDGroupInfoAccessType
    private let groupId: String
    
    private var group: AgoraChatGroup?

    init(groupId: String, accessType: ACDGroupInfoAccessType) {
        self.groupId = groupId
        self.accessType = accessType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: GroupInfoChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupMember(_:)), name: GroupMemberChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvGroupLeftNotification(_:)), name: GroupLeftNotification, object: nil)
        
        self.setupNavBar()
        self.fetchGroupInfo()
        self.groupIdLabel.text = "\("GroupID".localized): \(self.groupId)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupNavBar() {
        if self.accessType == .search {
            self.title = "Public Groups".localized
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gray_goBack"), style: .plain, target: self, action: #selector(backAction))
            
            let cancelBtn = UIButton(type: .custom)
            cancelBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
            cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            cancelBtn.setTitleColor(Color_154DFE, for: .normal)
            cancelBtn.setTitle(LocalizedString.Cancel, for: .normal)
            cancelBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            let rightSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            rightSpace.width = -2
            self.navigationItem.rightBarButtonItems = [rightSpace, UIBarButtonItem(customView: cancelBtn)]
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "black_goBack"), style: .plain, target: self, action: #selector(backAction))
        }
    }
    
    @objc private func backAction() {
        NotificationCenter.default.post(name: ConversationsUpdatedNotification, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchGroupInfo() {
        AgoraChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: self.groupId, completion: { group, error in
            if let error = error {
                self.showHint(error.errorDescription)
            } else if let group = group {
                self.group = group
                self.updateUI()
                if self.accessType == .search {
                    self.fetchGroupAnnouncement()
                }
            }
        })
    }
    
    private func fetchGroupAnnouncement() {
        AgoraChatClient.shared().groupManager?.getGroupAnnouncement(withId: self.groupId, completion: { _, error in
            if let error = error {
                self.showHint(error.errorDescription)
            } else {
                self.updateUI()
            }
        })
    }
    
    @objc private func updateUI(_ notification: Notification) {
        if let group = notification.object as? AgoraChatGroup, group.groupId == self.groupId {
            self.group = group
            self.fetchGroupInfo()
        }
    }
    
    @objc private func updateGroupMember(_ notification: Notification) {
        if let dict = notification.object as? [String: Any], let groupId = dict["kACDGroupId"] as? String, let type = dict["kACDGroupMemberListType"] as? ACDContainerSearchTableViewController<[AgoraUserModel]>.GroupMemberShowType {
            if self.groupId == groupId && type == .block {
                self.updateUI()
            }
        }
    }
    
    @objc private func didRecvGroupLeftNotification(_ notification: Notification) {
        if let group = notification.object as? AgoraChatGroup, group.groupId == self.groupId {
            self.backAction()
        }
    }
    
    private func updateShowItem() {
        if self.accessType == .search {
            self.joinViewHeightContraint.constant = 54
            self.membersViewHeightContraint.constant = 0
            self.noticeViewHeightContraint.constant = 0
            self.noticeViewHeightContraint.priority = .required
            self.fileViewHeightContraint.constant = 0
            self.transferViewHeightContraint.constant = 0
            self.disbandViewHeightContraint.constant = 0
            self.leaveViewHeightContraint.constant = 0
        } else {
            self.joinViewHeightContraint.constant = 0
            self.membersViewHeightContraint.constant = 54
            self.noticeViewHeightContraint.constant = 54
            self.noticeViewHeightContraint.priority = .defaultLow
            self.fileViewHeightContraint.constant = 54
            if self.group?.permissionType == .owner {
                self.transferViewHeightContraint.constant = 54
                self.disbandViewHeightContraint.constant = 54
                self.leaveViewHeightContraint.constant = 0
            } else {
                self.transferViewHeightContraint.constant = 0
                self.disbandViewHeightContraint.constant = 0
                self.leaveViewHeightContraint.constant = 54
            }
        }
        self.joinView.isHidden = self.joinViewHeightContraint.constant == 0
        self.membersView.isHidden = self.membersViewHeightContraint.constant == 0
        self.noticeView.isHidden = self.noticeViewHeightContraint.constant == 0
        self.fileView.isHidden = self.fileViewHeightContraint.constant == 0
        self.transferView.isHidden = self.transferViewHeightContraint.constant == 0
        self.disbandView.isHidden = self.disbandViewHeightContraint.constant == 0
        self.leaveView.isHidden = self.leaveViewHeightContraint.constant == 0
    }
    
    private func updateUI() {
        self.updateShowItem()
        self.groupNameLabel.text = self.group?.groupName
        self.groupDescribeLabel.text = self.group?.description
        self.memberCountLabel.text = "\(self.group?.occupantsCount ?? 0)"
        self.noticeLabel.text = self.group?.announcement
    }
    @IBAction func clickHeaderViewAction() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if self.group?.permissionType == .owner || self.group?.permissionType == .admin {
            vc.addAction(UIAlertAction(title: "Change Group Name".localized, iconImage: UIImage(named: "action_icon_edit"), textColor: .black, alignment: .left, completion: { _ in
                self.changeGroupName()
            }))
            vc.addAction(UIAlertAction(title: "Change Group Description".localized, iconImage: UIImage(named: "action_icon_edit"), textColor: .black, alignment: .left, completion: { _ in
                self.updateGroupDescription()
            }))
        }
        vc.addAction(UIAlertAction(title: "Copy GroupID".localized, iconImage: UIImage(named: "action_icon_copy"), textColor: .black, alignment: .left, completion: { _ in
            UIPasteboard.general.string = self.groupId
        }))
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(vc, animated: true)
    }
    
    @IBAction func joinAction() {
        guard let style = self.group?.settings.style else {
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if style == .publicOpenJoin {
            AgoraChatClient.shared().groupManager?.joinPublicGroup(self.groupId, completion: { _, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if let error = error {
                    self.showHint(error.errorDescription)
                }
            })
        } else {
            AgoraChatClient.shared().groupManager?.request(toJoinPublicGroup: self.groupId, message: String(format: "%@ request join the group".localized, AgoraChatClient.shared().currentUsername!), completion: { _, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if let error = error {
                    self.showHint(error.errorDescription)
                } else {
                    NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
                }
            })
        }
    }
    
    @IBAction func clickMemberViewAction() {
        guard let group = self.group else {
            return
        }
        let vc = ACDGroupMembersViewController(group: group)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickNoticeViewAction() {
        let vc = ACDNotificationSettingViewController()
        vc.notificationType = .group
        vc.conversationID = self.groupId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chatAction() {
        let vc = ACDChatViewController(conversationId: self.groupId, conversationType: .groupChat)
        vc.navTitle = self.group?.groupName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickFileViewAction() {
        guard let group = self.group else {
            return
        }
        let vc = ACDGroupSharedFilesViewController(group: group)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickLeaveViewAction() {
        let vc = UIAlertController(title: "Leave this group now?".localized, message: "No prompt for other members and no group messages after you quit this group.".localized, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        vc.addAction(UIAlertAction(title: "Leave".localized, style: .default, handler: { _ in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            AgoraChatClient.shared().groupManager?.leaveGroup(self.groupId, completion: { error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if error != nil {
                    self.showHint("Operation failed".localized)
                } else {
                    NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }))
        self.present(vc, animated: true)
    }
    
    @IBAction func clickTransferViewAction() {
        guard let group = self.group else {
            return
        }
        let vc = ACDGroupTransferOwnerViewController(group: group)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickDisbandViewAction() {
        let vc = UIAlertController(title: "Disband this group now?".localized, message: "Delete this group and associated Chats.".localized, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        vc.addAction(UIAlertAction(title: "Disband".localized, style: .default, handler: { _ in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            AgoraChatClient.shared().groupManager?.destroyGroup(self.groupId, finishCompletion: { error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if error != nil {
                    self.showHint("Operation failed".localized)
                } else {
                    NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }))
        vc.addAction(UIAlertAction(title: "Transfer Ownership and Leave".localized, style: .default, handler: { _ in
            guard let group = self.group else {
                return
            }
            let vc = ACDGroupTransferOwnerViewController(group: group, isLeaveGroup: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        self.present(vc, animated: true)
    }
    
    private func changeGroupName() {
        let vc = UIAlertController(title: "Change Group Name".localized, message: "Latin letters and numbers only.".localized, preferredStyle: .alert)
        vc.addTextField()
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        vc.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default, handler: { [unowned vc] _ in
            guard let text = vc.textFields?.first?.text, text.count > 0 else {
                return
            }
            MBProgressHUD.showAdded(to: self.view, animated: true)
            AgoraChatClient.shared().groupManager?.updateGroupSubject(text, forGroup: self.groupId, completion: { _, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if let error = error {
                    self.showAlert(message: error.description)
                } else {
                    self.fetchGroupInfo()
                }
            })
        }))
        self.present(vc, animated: true)
    }
    
    private func updateGroupDescription() {
        let vc = ACDTextViewController(text: self.group?.description ?? "", placeholder: "", isEditable: self.group?.permissionType == .admin || self.group?.permissionType == .owner)
        vc.title = "Group Description".localized
        vc.doneCompletion = { text in
            let group = AgoraChatClient.shared().groupManager?.changeDescription(text, forGroup: self.groupId, error: nil)
            if let group = group {
                self.group = group
                self.updateUI()
                return true
            }
            return false
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
