//
//  AgoraChatUserDataModel.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class AgoraChatUserDataModel: NSObject, EaseUserProfile {
    var easeId: String
    var showName: String
    var avatarURL: String
    var defaultAvatar: UIImage
    
    init(userInfo: AgoraChatUserInfo) {
        self.easeId = userInfo.userId ?? ""
        self.showName = userInfo.showName
        self.avatarURL = userInfo.avatarUrl ?? ""
        
        var defaultAvatar: UIImage!
        if self.easeId == AgoraChatClient.shared().currentUsername {
            if let imageName = UserDefaults.standard.value(forKey: "\(self.easeId)_avatar") as? String, let image = UIImage(named: imageName) {
                defaultAvatar = image
            }
        } else {
            if let imageName = UserDefaults.standard.value(forKey: self.easeId) as? String, let image = UIImage(named: imageName) {
                defaultAvatar = image
            } else {
                let imageName = "defatult_avatar_\(arc4random() % 7 + 1)"
                UserDefaults.standard.set(imageName, forKey: self.easeId)
                UserDefaults.standard.synchronize()
                if let image = UIImage(named: imageName) {
                    defaultAvatar = image
                }
            }
        }
        if defaultAvatar == nil {
            defaultAvatar = UIImage(named: "defatult_avatar_1")!
        }
        self.defaultAvatar = defaultAvatar
        super.init()
    }
    
    private func getAvatar(userId: String) -> UIImage {
        if userId == AgoraChatClient.shared().currentUsername {
            if let imageName = UserDefaults.standard.value(forKey: "\(userId)_avatar") as? String, let image = UIImage(named: imageName) {
                return image
            }
        } else {
            if let imageName = UserDefaults.standard.value(forKey: userId) as? String, let image = UIImage(named: imageName) {
                return image
            } else {
                let imageName = "defatult_avatar_\(arc4random() % 7 + 1)"
                UserDefaults.standard.set(imageName, forKey: userId)
                UserDefaults.standard.synchronize()
                if let image = UIImage(named: imageName) {
                    return image
                }
            }
        }
        return UIImage(named: "defaultAvatar")!
    }
}
