//
//  AgoraChatThreadListViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit
import SnapKit

class AgoraChatThreadListViewController: UIViewController {

    private let navBar = AgoraChatThreadListNavgation()
    private let chatController: EaseThreadListViewController
    
    init(group: AgoraChatGroup, viewModel: EaseChatViewModel) {
        self.chatController = EaseThreadListViewController(group: group, chatViewModel: viewModel)
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
            self.navigationController?.popViewController(animated: true)
        }
        self.navBar.title = "All Threads".localized
        self.view.addSubview(self.navBar)
        
        self.addChild(self.chatController)
        self.view.addSubview(self.chatController.view)
        
        self.chatController.view.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(44)
        }
        self.navBar.snp.makeConstraints { make in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(self.chatController.view.snp.top)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension AgoraChatThreadListViewController: EaseThreadListProtocol {
    func agoraChatThreadList(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath!) {
        guard let conversation = self.chatController.dataArray[indexPath.row] as? EaseThreadConversation else {
            return
        }
        let message = AgoraChatClient.shared().chatManager?.getMessageWithMessageId(conversation.threadInfo.messageId)
        let model = EaseMessageModel()
        var haveMessage = false
        if let message = message, message.messageId.count > 0 {
            haveMessage = true
            model.message = message
            model.direction = message.direction
            model.type = AgoraChatMessageType(rawValue: message.body.type.rawValue)!
            model.isHeader = true
        }
        
        AgoraChatClient.shared().threadManager?.joinChatThread(conversation.threadInfo.threadId, completion: { thread, error in
            if error == nil || error?.code == .userAlreadyExist {
                if let thread = thread {
                    model.thread = thread
                }
                let vc = AgoraChatThreadViewController(conversationId: conversation.threadInfo.threadId, type: .groupChat, viewModel: self.chatController.viewModel, parentMessageId: message?.messageId ?? "", model: haveMessage ? model : nil)
                vc.navTitle = thread?.threadName ?? conversation.threadInfo.threadName
                vc.detail = self.chatController.group.groupName
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}
