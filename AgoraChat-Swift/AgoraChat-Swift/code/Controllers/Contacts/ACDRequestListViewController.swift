//
//  ACDRequestListViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit

class ACDRequestListViewController: ACDContainerSearchTableViewController<AgoraApplyModel> {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.table.separatorStyle = .none
        self.table.keyboardDismissMode = .onDrag
        self.table.rowHeight = 102
        self.table.register(UINib(nibName: "ACDRequestCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    func updateUI() {
        self.dataArray.removeAll()
        let contactApplys = AgoraApplyManager.shared.reloadContactApplys()
        self.dataArray.append(contentsOf: contactApplys)

        let groupApplys = AgoraApplyManager.shared.reloadGroupApplys()
        self.dataArray.append(contentsOf: groupApplys)
        
        self.searchSource = self.dataArray
        self.table.reloadData()
    }
    
    private func declineApplyFinished(model: AgoraApplyModel, error: AgoraChatError?) {
        MBProgressHUD.hide(for: self.view, animated: true)
        if error == nil {
            model.status = .declined
            AgoraApplyManager.shared.addOrUpdate(apply: model)
        } else {
            self.showAlert(message: "Refused to apply for failed".localized)
        }
        self.table.reloadData()
    }
    
    private func acceptApplyFinished(model: AgoraApplyModel, error: AgoraChatError?) {
        MBProgressHUD.hide(for: self.view, animated: true)
        if error == nil {
            model.status = .agreed
            AgoraApplyManager.shared.remove(apply: model)
            let body = AgoraChatTextMessageBody(text: "You agreed the friend request".localized)
            let message = AgoraChatMessage(conversationID: model.userId, from: model.userId, to: AgoraChatClient.shared().currentUsername!, body: body, ext: [
                "agora_noti": "agora_addFriend"
            ])
            message.chatType = .groupChat
            message.isRead = true
            let conversation = AgoraChatClient.shared().chatManager?.getConversation(model.userId, type: .chat, createIfNotExist: true)
            conversation?.insert(message, error: nil)
            
            NotificationCenter.default.post(name: ConversationsUpdatedNotification, object: nil)
            NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
        } else {
            self.showAlert(message: "Agree to apply for failed".localized)
        }
        self.table.reloadData()
    }
    
    private func declineAction(model: AgoraApplyModel) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        switch model.type {
        case .contact(userId: let userId):
            AgoraChatClient.shared().contactManager?.declineFriendRequest(fromUser: userId, completion: { _, error in
                self.declineApplyFinished(model: model, error: error)
            })
        case .joinGroup(userId: let userId, groupId: let groupId):
            AgoraChatClient.shared().groupManager?.declineJoinGroupRequest(groupId, sender: userId, reason: nil, completion: { _, error in
                self.declineApplyFinished(model: model, error: error)
            })
        case .inviteGroup(userId: let userId, groupId: let groupId):
            AgoraChatClient.shared().groupManager?.declineGroupInvitation(groupId, inviter: userId, reason: nil, completion: { error in
                self.declineApplyFinished(model: model, error: error)
            })
        }
    }
    
    private func acceptAction(model: AgoraApplyModel) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        switch model.type {
        case .contact(userId: let userId):
            AgoraChatClient.shared().contactManager?.approveFriendRequest(fromUser: userId, completion: { _, error in
                self.acceptApplyFinished(model: model, error: error)
            })
        case .joinGroup(userId: let userId, groupId: let groupId):
            AgoraChatClient.shared().groupManager?.approveJoinGroupRequest(groupId, sender: userId, completion: { _, error in
                self.acceptApplyFinished(model: model, error: error)
            })
        case .inviteGroup(userId: let userId, groupId: let groupId):
            AgoraChatClient.shared().groupManager?.acceptInvitation(fromGroup: groupId, inviter: userId, completion: { _, error in
                self.acceptApplyFinished(model: model, error: error)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearchState ? self.searchResults.count : self.dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDRequestCell {
            var applyModel: AgoraApplyModel?
            if self.isSearchState {
                applyModel = self.searchResults[indexPath.row] as? AgoraApplyModel
            } else {
                applyModel = self.dataArray[indexPath.row]
            }
            cell.model = applyModel
            cell.acceptHandle = { [unowned self] model in
                self.acceptAction(model: model)
            }
            cell.rejectHandle = { [unowned self] model in
                self.declineAction(model: model)
            }
        }
        return cell
    }
}
