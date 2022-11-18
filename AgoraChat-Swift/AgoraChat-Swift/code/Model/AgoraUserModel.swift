//
//  AgoraUserModel.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/28.
//

import UIKit

class AgoraUserModel: NSObject {

    let hyphenateId: String
    var nickname: String?
    var avatarURLPath: String?
    let defaultAvatarImage: UIImage?
    let defaultAvatar: String
    
    var showName: String {
        if let nickname = self.nickname, nickname.count > 0 {
            return nickname
        }
        return hyphenateId
    }
    
    private var userInfo: AgoraChatUserInfo?
    
    init(hyphenateId: String) {
        self.hyphenateId = hyphenateId
        let value = (hyphenateId.last?.asciiValue ?? 0) % 7 + 1
        self.defaultAvatar = "defatult_avatar_\(value)"
        self.defaultAvatarImage = UIImage(named: self.defaultAvatar)
        super.init()
    }
    
    func setUserInfo(_ info: AgoraChatUserInfo) {
        self.nickname = info.nickname
        self.avatarURLPath = info.avatarUrl
    }
}
