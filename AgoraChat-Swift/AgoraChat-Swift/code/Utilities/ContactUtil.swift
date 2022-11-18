//
//  ContactUtil.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/19.
//

import UIKit

class ContactUtil: NSObject {
    class func sortContacts(_ contacts: [String], handle: @escaping (_ result: [[AgoraUserModel]], _ sectionTitles: [String], _ searchSource: [AgoraUserModel]) -> Void) {
        if contacts.count == 0 {
            handle([], [], [])
            return
        }
        var sectionTitles: [String] = []
        var searchSource: [AgoraUserModel] = []
        var result: [[AgoraUserModel]] = []
        let indexCollation = UILocalizedIndexedCollation.current()
        sectionTitles.append(contentsOf: indexCollation.sectionTitles)
        for _ in sectionTitles {
            result.append([])
        }
        var sortArray: [String] = []
        var userInfos: [AgoraChatUserInfo] = []
        UserInfoStore.shared.fetchUserInfosFromServer(userIds: contacts) {
            for i in contacts {
                if let userInfo = UserInfoStore.shared.getUserInfo(userId: i) {
                    userInfos.append(userInfo)
                }
            }
            
            userInfos.sort { obj1, obj2 in
                return obj1.showName.caseInsensitiveCompare(obj2.showName) == .orderedAscending
            }
            for i in userInfos {
                if let userId = i.userId {
                    sortArray.append(userId)
                }
            }
            
            for i in sortArray {
                let model = AgoraUserModel(hyphenateId: i)
                if let firstLetter = model.showName.first?.uppercased() {
                    if let sectionIndex = sectionTitles.firstIndex(of: firstLetter) {
                        result[sectionIndex].append(model)
                        searchSource.append(model)
                    }
                }
            }
            
            for i in (0..<result.count).reversed() {
                if result[i].count == 0 {
                    result.remove(at: i)
                    sectionTitles.remove(at: i)
                }
            }
            
            handle(result, sectionTitles, searchSource)
        }
    }
}
