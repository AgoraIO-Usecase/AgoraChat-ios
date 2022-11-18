//
//  AgoraApplyModel+RealtimeSearch.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import Foundation

extension AgoraApplyModel: IAgoraRealtimeSearch {
    var searchKey: String {
        if let nickname = self.applyNickname, nickname.count > 0 {
            return nickname
        }
        switch self.type {
        case .contact(userId: let userId), .inviteGroup(userId: let userId, groupId: _), .joinGroup(userId: let userId, groupId: _):
            return userId
        }
    }
}
