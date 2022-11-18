//
//  AgoraGroupModel+RealtimeSearch.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import Foundation

extension AgoraGroupModel: IAgoraRealtimeSearch {
    var searchKey: String {
        if let subject = subject, subject.count > 0 {
            return subject
        }
        return self.hyphenateId ?? ""
    }
}
