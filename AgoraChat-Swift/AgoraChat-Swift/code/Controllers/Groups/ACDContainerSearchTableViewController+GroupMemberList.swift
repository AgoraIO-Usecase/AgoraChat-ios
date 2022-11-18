//
//  ACDContainerSearchTableViewController+GroupMemberList.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/21.
//

import UIKit

private var ActionAdminKey = "ActionAdminKey"
private var ActionUnAdminKey = "ActionUnAdminKey"

private var ActionMuteKey = "ActionMuteKey"
private var ActionUnMuteKey = "ActionUnMuteKey"

private var ActionBlockKey = "ActionBlockKey"
private var ActionUnBlockKey = "ActionUnBlockKey"

private var ActionRemoveFromGroupKey = "ActionRemoveFromGroupKey"

private var SelectedUserIdKey = "selectedUserId"
private var GroupIdKey = "groupId"

extension ACDContainerSearchTableViewController where T == [AgoraUserModel] {
    enum GroupMemberShowType: Int {
        case all = 0
        case admin
        case mute
        case block
        case white
    }
    
    private var selectedUserId: String? {
        set {
            let key = withUnsafePointer(to: &SelectedUserIdKey) { UnsafeRawPointer($0) }
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            let key = withUnsafePointer(to: &SelectedUserIdKey) { UnsafeRawPointer($0) }
            return objc_getAssociatedObject(self, key) as? String
        }
    }
    
    private var groupId: String? {
        set {
            let key = withUnsafePointer(to: &GroupIdKey) { UnsafeRawPointer($0) }
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_COPY)
        }
        get {
            let key = withUnsafePointer(to: &GroupIdKey) { UnsafeRawPointer($0) }
            return objc_getAssociatedObject(self, key) as? String
        }
    }
    
    func showActionSheet(userId: String, showType: ACDContainerSearchTableViewController.GroupMemberShowType, group: AgoraChatGroup) {
        if userId == AgoraChatClient.shared().currentUsername {
            return
        }
        //admin can not opertion admin
        if group.permissionType == .admin {
            if group.adminList.contains(userId) {
                return
            }
        }
        if group.permissionType == .member {
            return
        }
        
        self.selectedUserId = userId
        self.groupId = group.groupId
        
        let alertController = UIAlertController(title: userId, message: nil, preferredStyle: .actionSheet)
        if group.permissionType == .owner {
            self.addOwnerActions(type: showType, selectedIsAdmin: group.adminList.contains(userId), isMited: group.muteList.contains(userId), alertController: alertController)
        } else if group.permissionType == .admin {
            self.addAdminActions(type: showType, isMuted: group.muteList.contains(userId), alertController: alertController)
        }
        
        alertController.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(alertController, animated: true)
    }
    
    private func addOwnerActions(type: GroupMemberShowType, selectedIsAdmin: Bool, isMited: Bool, alertController: UIAlertController) {
        let map = self.alertActionMap
        if type == .all {
            if selectedIsAdmin {
                alertController.addAction(map[ActionUnAdminKey]!)
            } else {
                alertController.addAction(map[ActionAdminKey]!)
            }
            alertController.addAction(map[ActionBlockKey]!)
            if isMited {
                alertController.addAction(map[ActionUnMuteKey]!)
            } else {
                alertController.addAction(map[ActionMuteKey]!)
            }
            alertController.addAction(map[ActionRemoveFromGroupKey]!)
        } else if type == .block {
            alertController.addAction(map[ActionUnBlockKey]!)
            alertController.addAction(map[ActionRemoveFromGroupKey]!)
        } else if type == .mute {
            alertController.addAction(map[ActionUnMuteKey]!)
            alertController.addAction(map[ActionRemoveFromGroupKey]!)
        }
    }
    
    private func addAdminActions(type: GroupMemberShowType, isMuted: Bool, alertController: UIAlertController) {
        let map = self.alertActionMap
        if type == .all {
            if isMuted {
                alertController.addAction(map[ActionUnMuteKey]!)
            } else {
                alertController.addAction(map[ActionMuteKey]!)
            }
            alertController.addAction(map[ActionBlockKey]!)
            alertController.addAction(map[ActionRemoveFromGroupKey]!)
        } else if type == .block {
            alertController.addAction(map[ActionUnBlockKey]!)
            alertController.addAction(map[ActionRemoveFromGroupKey]!)
        } else if type == .mute {
            alertController.addAction(map[ActionUnMuteKey]!)
            alertController.addAction(map[ActionRemoveFromGroupKey]!)
        }
    }
    
    private var alertActionMap: [String: UIAlertAction] {
        get {
            var map: [String: UIAlertAction] = [:]
            map[ActionAdminKey] = UIAlertAction(title: "Make Admin".localized, iconImage: UIImage(named: "admin"), textColor: .black, alignment: .left, completion: { _ in
                self.makeAdmin()
            })
            map[ActionMuteKey] = UIAlertAction(title: "Mute".localized, iconImage: UIImage(named: "mute"), textColor: .black, alignment: .left, completion: { _ in
                self.makeMute()
            })
            map[ActionBlockKey] = UIAlertAction(title: "Block".localized, iconImage: UIImage(named: "blocked"), textColor: .black, alignment: .left, completion: { _ in
                self.makeBlock()
            })
            map[ActionUnAdminKey] = UIAlertAction(title: "Remove as Admin".localized, iconImage: UIImage(named: "remove_admin"), textColor: .black, alignment: .left, completion: { _ in
                self.unAdmin()
            })
            map[ActionUnMuteKey] = UIAlertAction(title: "Unmute".localized, iconImage: UIImage(named: "Unmute"), textColor: .black, alignment: .left, completion: { _ in
                self.unMute()
            })
            map[ActionUnBlockKey] = UIAlertAction(title: "Unblock".localized, iconImage: UIImage(named: "Unblock"), textColor: .black, alignment: .left, completion: { _ in
                self.unBlock()
            })
            map[ActionRemoveFromGroupKey] = UIAlertAction(title: "Remove From Group".localized, iconImage: UIImage(named: "remove"), textColor: .black, alignment: .left, completion: { _ in
                self.makeRemoveGroup()
            })
            return map
        }
    }
    
    private func makeAdmin() {
        guard let selectedUserId = self.selectedUserId, let groupId = self.groupId else {
            return
        }
        AgoraChatClient.shared().groupManager?.addAdmin(selectedUserId, toGroup: groupId, completion: { _, error in
            self.handleAction(type: .admin, error: error)
        })
    }

    private func unAdmin() {
        guard let selectedUserId = self.selectedUserId, let groupId = self.groupId else {
            return
        }
        AgoraChatClient.shared().groupManager?.removeAdmin(selectedUserId, fromGroup: groupId, completion: { _, error in
            self.handleAction(type: .admin, error: error)
        })
    }
    
    private func makeMute() {
        guard let selectedUserId = self.selectedUserId, let groupId = self.groupId else {
            return
        }
        AgoraChatClient.shared().groupManager?.muteMembers([selectedUserId], muteMilliseconds: -1, fromGroup: groupId, completion: { _, error in
            self.handleAction(type: .mute, error: error)
        })
    }

    private func unMute() {
        guard let selectedUserId = self.selectedUserId, let groupId = self.groupId else {
            return
        }
        AgoraChatClient.shared().groupManager?.unmuteMembers([selectedUserId], fromGroup: groupId, completion: { _, error in
            self.handleAction(type: .mute, error: error)
        })
    }

    private func makeBlock() {
        guard let selectedUserId = self.selectedUserId, let groupId = self.groupId else {
            return
        }
        AgoraChatClient.shared().groupManager?.blockMembers([selectedUserId], fromGroup: groupId, completion: { _, error in
            self.handleAction(type: .block, error: error)
        })
    }

    private func unBlock() {
        guard let selectedUserId = self.selectedUserId, let groupId = self.groupId else {
            return
        }
        AgoraChatClient.shared().groupManager?.unblockMembers([selectedUserId], fromGroup: groupId, completion: { _, error in
            self.handleAction(type: .block, error: error)
        })
    }
    
    private func makeRemoveGroup() {
        guard let selectedUserId = self.selectedUserId, let groupId = self.groupId else {
            return
        }
        AgoraChatClient.shared().groupManager?.removeMembers([selectedUserId], fromGroup: groupId, completion: { _, error in
            self.handleAction(type: .all, error: error)
        })
    }

    private func handleAction(type: GroupMemberShowType, error: AgoraChatError?) {
        if self.isSearchState {
            self.cancelSearchState()
        }
        if let error = error {
            self.showHint(error.errorDescription)
        } else {
            NotificationCenter.default.post(name: GroupMemberChangedNotification, object: [
                "kACDGroupId": self.groupId ?? "",
                "kACDGroupMemberListType": type
            ])
        }
    }
}
