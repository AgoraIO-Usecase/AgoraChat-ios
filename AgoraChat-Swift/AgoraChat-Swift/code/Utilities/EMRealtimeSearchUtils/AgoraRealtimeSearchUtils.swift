//
//  AgoraRealtimeSearchUtils.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import UIKit
import SwiftUI

class AgoraRealtimeSearchUtils: NSObject {
    
    private var resultHandle: ((_ result: [IAgoraRealtimeSearch]) -> Void)?
    private var source: [IAgoraRealtimeSearch]?
    private var keyword: String?
    private var thread: Thread?
    
    func realSearch(source: [IAgoraRealtimeSearch], keyword: String, resultHandle: @escaping (_ IAgoraRealtimeSearch: [IAgoraRealtimeSearch]) -> Void) {
        if source.count <= 0 || keyword.count <= 0 {
            resultHandle(source)
            return
        }
        self.resultHandle = resultHandle
        self.source = source
        self.keyword = keyword.lowercased()
        
        self.start()
    }
    
    private func start() {
        self.thread?.cancel()
        self.thread = Thread(block: {
            var resultList: [IAgoraRealtimeSearch] = []
            guard let source = self.source, let keyword = self.keyword else {
                DispatchQueue.main.async {
                    self.resultHandle?(resultList)
                }
                return
            }
            for item in source where item.searchKey.lowercased().contains(keyword) {
                resultList.append(item)
            }
            DispatchQueue.main.async {
                self.resultHandle?(resultList)
            }
        })
        self.thread?.start()
    }
    
    func cancel() {
        self.thread?.cancel()
        self.source = nil
        self.keyword = nil
        self.resultHandle = nil
    }
}
