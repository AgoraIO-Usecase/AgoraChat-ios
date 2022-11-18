//
//  ACDReportMessageSucceedViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/24.
//

import UIKit

class ACDReportMessageSucceedViewController: UIViewController {

    var doneButtonHandle: (() -> Void)?
    
    @IBAction private func doneAction() {
        self.doneButtonHandle?()
    }
}
