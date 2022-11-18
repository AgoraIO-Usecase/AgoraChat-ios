//
//  AgoraChatCreateThreadViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class AgoraChatCreateThreadViewController: UIViewController {

    private let navBar = AgoraChatThreadListNavgation()
    private let createViewController: EaseThreadCreateViewController
    private let message: EaseMessageModel
    private var group: AgoraChatGroup?
    
    init(type: EMThreadHeaderType, viewModel: EaseChatViewModel, message: EaseMessageModel) {
        self.message = message
        self.createViewController = EaseThreadCreateViewController(type: type, viewModel: viewModel, message: message)
        super.init(nibName: nil, bundle: nil)
        self.createViewController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Color_F2F2F2
        
        self.navBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44 + self.view.safeAreaInsets.top)
        self.navBar.backgroundColor = .white
        self.navBar.backHandle = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        self.navBar.title = "New Thread".localized
        self.view.addSubview(self.navBar)
        
        self.addChild(self.createViewController)
        self.view.addSubview(self.createViewController.view)
        
        self.navBar.snp.makeConstraints { make in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.createViewController.view.snp.top)
        }
        
        self.createViewController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(44)
        }
        
        AgoraChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: self.message.message.to, completion: { group, error in
            self.group = group
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension AgoraChatCreateThreadViewController: EaseChatViewControllerDelegate {
    func didSend(_ message: AgoraChatMessage, thread: AgoraChatThread, error: AgoraChatError?) {
        if thread.threadId.count <= 0 {
            self.showHint(String(format: "%@ can't be null".localized, "'conversationId'"))
            return
        }
        if let error = error {
            self.showHint(error.errorDescription)
            return
        }
        self.message.thread = thread
        let vc = AgoraChatThreadViewController(conversationId: thread.threadId, type: .groupChat, viewModel: self.createViewController.viewModel, parentMessageId: thread.messageId, model: self.message)
        vc.createPush = true
        vc.navTitle = thread.threadName
        vc.detail = self.group?.groupName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
}
