//
//  ACDContainerSearchTableViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/26.
//

import UIKit
import MISScrollPage

class ACDContainerSearchTableViewController<T>: ACDSearchTableViewController<T>, MISScrollPageControllerContentSubViewControllerDelegate {

    func hasAlreadyLoaded() -> Bool {
        return false
    }

    func viewWillAppear(for index: UInt) {
        self.cancelSearchState()
    }
    
    func viewWillDisappear(for index: UInt) {
        self.isEditing = false
        self.cancelSearchState()
    }
}
