//
//  ACDContactsViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/14.
//

import UIKit
import SnapKit
import MISScrollPage

@objcMembers
class ACDContactsViewController: UIViewController {

    private let navView = ACDNaviCustomView()
    private var pageController: MISScrollPageController!
    private var segView: MISScrollPageSegmentView!
    private var contentView: MISScrollPageContentView!
    private let contactListVC = ACDContactListController()
    private let requestListVC = ACDRequestListViewController()
    private let groupListVC = ACDGroupListViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navView.addActionHandle = { [unowned self] in
            self.goAddPage()
        }
        
        self.contactListVC.selectedBlock = { [unowned self] contactId in
            self.goContactInfoPage(contactId: contactId)
        };
        
        self.groupListVC.selectedHandle = { [unowned self] groupId in
            self.goGroupInfoPage(groupId: groupId, accessType: .contact)
        }
        
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
        self.contentView = self.pageController.contentView(withFrame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 500))
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        
        self.view.addSubview(self.navView)
        self.view.addSubview(containerView)
        containerView.addSubview(self.segView)
        containerView.addSubview(self.contentView)
        
        self.navView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(containerView.snp.top).offset(-5)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.segView.snp.makeConstraints { make in
            make.top.left.right.equalTo(containerView)
            make.height.equalTo(50)
        }
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.segView.snp.bottom)
            make.left.right.bottom.equalTo(containerView)
        }
        
        self.pageController.reloadData()
        self.reloadContactRequests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func reloadContacts() {
        self.contactListVC.reloadContacts()
    }
    
    func reloadContactRequests() {
        DispatchQueue.main.async {
            AgoraApplyManager.shared.reloadContactApplys()
            AgoraChatDemoHelper.shared.setupUntreatedApplyCount()
        }
    }
    
    func reloadGroupNotifications() {
        DispatchQueue.main.async {
            AgoraApplyManager.shared.reloadGroupApplys()
            AgoraChatDemoHelper.shared.setupUntreatedApplyCount()
        }
    }
    
    func navBarUnreadRequestIsShow(_ isShow: Bool) {
        guard let segView = self.segView, segView.titles.count > 0 else {
            return
        }
        self.requestListVC.updateUI()
        self.segView.reloadTitleRedPoint(withISShow: isShow, withTitleIndex: 2)
    }
    
    private func goAddPage() {
        let vc = ACDGroupEnterController()
        let nav = UINavigationController(rootViewController: vc)
        nav.view.backgroundColor = .white
        self.navigationController?.present(nav, animated: true)
    }

    private func goGroupInfoPage(groupId: String, accessType: ACDGroupInfoAccessType) {
        let vc = ACDGroupInfoViewController(groupId: groupId, accessType: accessType)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goContactInfoPage(contactId: String) {
        let vc = ACDContactInfoViewController(userId: contactId)
        vc.addBlackListHandle = {
            self.contactListVC.reloadContacts()
        }
        vc.deleteContactHandle = {
            self.contactListVC.reloadContacts()
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ACDContactsViewController: MISScrollPageControllerDataSource {
    func numberOfChildViewControllers() -> UInt {
        return 3
    }
    
    func titlesOfSegmentView() -> [Any]! {
        return [
            "Friends".localized,
            "Groups".localized,
            "Requests".localized
        ]
    }
    
    func childViewControllersOfContentView() -> [Any]! {
        return [self.contactListVC, self.groupListVC, self.requestListVC];
    }
}
