//
//  ACDChatNavigationView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/17.
//

import UIKit

@objcMembers
class ACDChatNavigationView: UIView {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var rightButton2: UIButton!
    @IBOutlet weak var rightButton3: UIButton!
    @IBOutlet weak var presenceLabel: UILabel!
    @IBOutlet weak var chatImageView: AgoraChatAvatarView!
    
    var leftButtonClosure: (() -> Void)?
    var rightButtonClosure: (() -> Void)?
    var rightButton2Closure: (() -> Void)?
    var rightButton3Closure: (() -> Void)?
    var chatButtonClosure: (() -> Void)?
    
    class func createView() -> ACDChatNavigationView {
        return Bundle.main.loadNibNamed("ACDChatNavigationView", owner: nil)!.first as! ACDChatNavigationView
    }
    
    @IBAction private func leftButtonAction() {
        self.leftButtonClosure?()
    }
    
    @IBAction private func chatButtonAction() {
        self.chatButtonClosure?()
    }
    
    @IBAction private func rightButtonAction() {
        self.rightButtonClosure?()
    }
    
    @IBAction private func rightButton2Action() {
        self.rightButton2Closure?()
    }
    
    @IBAction private func rightButton3Action() {
        self.rightButton3Closure?()
    }
    
}
