//
//  AgoraChatUserInfo+ShowName.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/31.
//

import Foundation

extension AgoraChatUserInfo {
    var showName: String {
        if let nickname = self.nickname, nickname.count > 0 {
            return nickname
        }
        return self.userId!
    }
}
