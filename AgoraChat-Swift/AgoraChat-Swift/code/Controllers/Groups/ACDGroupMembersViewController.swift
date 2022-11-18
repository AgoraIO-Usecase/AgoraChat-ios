//
//  ACDGroupMembersViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/20.
//

import UIKit
import MISScrollPage
import SnapKit

class ACDGroupMembersViewController: UIViewController {

    private var pageController: MISScrollPageController!
    private var segView: MISScrollPageSegmentView!
    private var contentView: MISScrollPageContentView!
    private var allVC: ACDGroupMemberAllViewController!
    private var adminListVC: ACDGroupMemberAdminListViewController!
    private var mutedListVC: ACDGroupMemberMutedListViewController!
    private var blockListVC: ACDGroupMemberBlockListViewController!
    
    private var navView = ACDGroupMemberNavView()
    private var group: AgoraChatGroup!
    private var inviteArray: [String] = []
    private let navTitleArray: [String] = ["All".localized, "Admin".localized, "Muted".localized, "Blocked".localized]
    private var contentVCArray: [UIViewController]!
    
    init(group: AgoraChatGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        NotificationCenter.default.addObserver(self, selector: #selector(updateUIWithNotification(_:)), name: GroupInfoChangedNotification, object: nil)
        
        self.navView.leftLabel.text = "Members".localized
        self.navView.leftSubLabel.text = "(\(self.group.occupantsCount))"

        if self.group.permissionType == .none {
            self.navView.rightButton.isHidden = true
        } else if self.group.permissionType == .member {
            self.navView.rightButton.isHidden = self.group.settings.style != .privateMemberCanInvite
        } else {
            self.navView.rightButton.isHidden = false
        }
        self.navView.leftButtonHandle = { [unowned self] in
            self.backAction()
        }
        self.navView.rightButtonHandle = { [unowned self] in
            self.addGroupMember()
        }
        
        self.allVC = ACDGroupMemberAllViewController(group: self.group)
        self.adminListVC = ACDGroupMemberAdminListViewController(group: self.group)
        self.mutedListVC = ACDGroupMemberMutedListViewController(group: self.group)
        self.blockListVC = ACDGroupMemberBlockListViewController(group: self.group)
        
        let style = MISScrollPageStyle()
        style.isShowCover = true
        style.coverBackgroundColor = Color_D8D8D8
        style.isGradualChangeTitleColor = true
        style.normalTitleColor = Color_999999
        style.selectedTitleColor = .black
        style.scrollLineColor = .black.withAlphaComponent(0.5)
        style.isScaleTitle = true
        style.titleBigScale = 1.05
        style.titleFont = UIFont.systemFont(ofSize: 13)
        style.isAutoAdjustTitlesWidth = true
        style.isShowSegmentViewShadow = true
        self.pageController = MISScrollPageController(style: style, dataSource: self, delegate: nil)
        
        self.segView = self.pageController.segmentView(withFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        self.contentView = self.pageController.contentView(withFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 119))
    
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        self.view.addSubview(containerView)
        self.view.addSubview(self.navView)
        containerView.addSubview(self.segView)
        containerView.addSubview(self.contentView)
        
        self.navView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(containerView.snp.top).offset(-5)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.segView.snp.makeConstraints { make in
            make.left.top.right.equalTo(containerView)
            make.height.equalTo(50)
        }
        
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.left.right.bottom.equalTo(containerView)
        }
        
        self.contentVCArray = [self.allVC, self.adminListVC, self.mutedListVC, self.blockListVC]
        
        self.pageController.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @objc private func updateUIWithNotification(_ notification: Notification) {
        if let group = notification.object as? AgoraChatGroup {
            if group.groupId == self.group.groupId {
                self.group = group
                self.navView.leftSubLabel.text = "(\(self.group.occupantsCount))"
            }
        }
    }

    func update(group: AgoraChatGroup) {
        self.group = group
        self.navView.leftSubLabel.text = "(\(self.group.occupantsCount))"
        self.allVC.updateUI()
        self.adminListVC.updateUI()
        self.blockListVC.updateUI()
        self.mutedListVC.updateUI()
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func addGroupMember() {
        var list: [String] = []
        list.append(self.group.owner)
        list.append(contentsOf: self.group.memberList)
        let vc = AgoraMemberSelectViewController(invitees: list, maxInviteCount: self.group.settings.maxUsers)
        vc.style = .invite
        vc.title = "Add Members"
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ACDGroupMembersViewController: AgoraGroupUIProtocol {
    func addSelectOccupants(_ modelArray: [AgoraUserModel]) {
        for i in modelArray {
            self.inviteArray.append(i.hyphenateId)
        }
         
        let msg = String(format: "%@ invite you to join the group [%@]".localized, AgoraChatClient.shared().currentUsername!, self.group.groupName)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().groupManager?.addMembers(self.inviteArray, toGroup: self.group.groupId, message: msg, completion: { group, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.showHint(error.description)
            }
        })
    }
}

extension ACDGroupMembersViewController: MISScrollPageControllerDataSource {
    func numberOfChildViewControllers() -> UInt {
        return UInt(self.navTitleArray.count)
    }
    
    func titlesOfSegmentView() -> [Any]! {
        return self.navTitleArray
    }
    
    func childViewControllersOfContentView() -> [Any]! {
        return self.contentVCArray
    }
}
