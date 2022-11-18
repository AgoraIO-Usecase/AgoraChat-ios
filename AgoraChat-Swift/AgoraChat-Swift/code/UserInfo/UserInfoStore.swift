//
//  UserInfoStore.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/28.
//

import UIKit

class UserInfoStore: NSObject {
    static let shared = UserInfoStore()
    
    private let queue = DispatchQueue(label: "UserInfoStore", attributes: .concurrent)
    
    private var userInfoMap: [String: AgoraChatUserInfo] = [:]
    
    func getUserInfo(userId: String) -> AgoraChatUserInfo? {
        var info: AgoraChatUserInfo?
        self.queue.sync {
            info = self.userInfoMap[userId]
        }
        return info
    }
    
    func setUserInfo(_ userInfo: AgoraChatUserInfo, userId: String) {
        self.queue.async(flags: .barrier) {
            self.userInfoMap[userId] = userInfo
        }
    }
    
    func fetchUserInfosFromServer(userIds: [String], refresh: Bool = false, completion: (() -> Void)? = nil) {
        AgoraChatClient.shared().userInfoManager?.fetchUserInfo(byId: userIds, completion: { dict, error in
            if let dict = dict as? [String: AgoraChatUserInfo] {
                self.queue.sync(flags: .barrier) {
                    for item in dict {
                        self.userInfoMap[item.key] = item.value
                    }
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: UserInfoDidChangeNotification, object: [
                        "userinfo_list": Array(dict.values)
                    ])
                    completion?()
                }
            } else {
                DispatchQueue.main.async {
                    completion?()
                }
            }
        })
    }
}
