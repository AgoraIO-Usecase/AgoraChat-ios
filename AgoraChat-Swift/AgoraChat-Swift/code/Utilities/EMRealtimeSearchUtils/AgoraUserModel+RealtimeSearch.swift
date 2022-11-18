//
//  AgoraUserModel+RealtimeSearch.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import Foundation

extension AgoraUserModel: IAgoraRealtimeSearch {
    var searchKey: String {
        return self.showName
    }
}
