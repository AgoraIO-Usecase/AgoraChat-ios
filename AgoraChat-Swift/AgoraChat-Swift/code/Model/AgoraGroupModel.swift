//
//  AgoraGroupModel.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class AgoraGroupModel: NSObject {
    var hyphenateId: String?
    var subject: String?
    var avatarURLPath: String?
    var defaultAvatarImage: UIImage?
    let group: AgoraChatGroup
    
    init(group: AgoraChatGroup) {
        self.group = group
        self.hyphenateId = group.groupId
        self.subject = group.groupName
        self.defaultAvatarImage = UIImage(named: "group_default_avatar")
        super.init()
    }
}
