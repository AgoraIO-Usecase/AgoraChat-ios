//
//  AgoraChatGroupSharedFile+search.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/26.
//

import Foundation

extension AgoraChatGroupSharedFile: IAgoraRealtimeSearch {
    var searchKey: String {
        if self.fileName.count > 0 {
            return self.fileName
        }
        return self.fileId
    }
}
