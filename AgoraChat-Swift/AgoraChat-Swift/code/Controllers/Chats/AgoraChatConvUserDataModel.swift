//
//  AgoraChatConvUserDataModel.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/17.
//

import UIKit

@objcMembers
class AgoraChatConvUserDataModel: NSObject, EaseUserProfile {
    
    var easeId: String {
        return _easeId ?? ""
    }
    
    var defaultAvatar: UIImage {
        return _defaultAvatar ?? UIImage()
    }
    
    var showName: String {
        return _showName ?? ""
    }
    
    var avatarURL: String {
        return _avatarURL ?? ""
    }
    
    let _easeId: String?
    var _defaultAvatar: UIImage?
    var _showName: String?
    let _avatarURL: String?
    
    init(userInfo: AgoraChatUserInfo, conversationType: AgoraChatConversationType) {
        self._easeId = userInfo.userId
        self._showName = userInfo.showName
        self._avatarURL = userInfo.avatarUrl
        self._defaultAvatar = nil
        if conversationType == .groupChat {
            let group = AgoraChatGroup(id: userInfo.userId)
            self._showName = group?.groupName
            self._defaultAvatar = UIImage(named: "group_default_avatar")
        } else if conversationType == .chat {
            let imageName = UserDefaults.standard.object(forKey: userInfo.userId ?? "") as? String
            var originImage: UIImage?
            if let imageName = imageName, imageName.count > 0 {
                originImage = UIImage(named: imageName)
            } else {
                let random = arc4random() % 7 + 1
                let imageName = "defatult_avatar_\(random)"
                originImage = UIImage(named: imageName)
                if let userId = userInfo.userId {
                    UserDefaults.standard.set(imageName, forKey: userId)
                    UserDefaults.standard.synchronize()
                }
            }
            self._defaultAvatar = originImage
        }
        super.init()
    }
}
