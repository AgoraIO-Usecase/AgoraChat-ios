//
//  ACDInfoHeaderView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/13.
//

import UIKit

@objc
enum ACDHeaderInfoType: Int {
    case contact = 0
    case me
}

@objcMembers
class ACDInfoHeaderView: UIView {
    
    @IBOutlet weak var avatarImageView: AgoraChatAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    @IBOutlet weak var chatView: ACDImageTextButtonView!
    
    @IBOutlet weak var avatarImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatViewTopConstraint: NSLayoutConstraint!
    
    private var type: ACDHeaderInfoType = .me {
        didSet {
            switch self.type {
            case .contact:
                self.avatarImageView.layer.cornerRadius = 70
                self.avatarImageView.layer.masksToBounds = true
                self.describeLabel.isHidden = true
                self.avatarImageViewTopConstraint.constant = 60
                self.chatViewTopConstraint.constant = -self.describeLabel.bounds.height
            case .me:
                self.avatarImageView.layer.cornerRadius = 70
                self.avatarImageView.layer.masksToBounds = true
                self.describeLabel.isHidden = true
                self.chatView.isHidden = true
                self.avatarImageViewTopConstraint.constant = 60
                self.chatViewTopConstraint.constant = 10
            }
        }
    }
    
    var goChatPageHandle: (() -> Void)?
    var tapHeaderHandle: (() -> Void)?
    
    var isHideChatButton: Bool = false {
        didSet {
            self.chatView.isHidden = self.isHideChatButton
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    class func create(type: ACDHeaderInfoType) -> ACDInfoHeaderView {
        let view = Bundle.main.loadNibNamed("ACDInfoHeaderView", owner: nil)!.first as! ACDInfoHeaderView
        view.type = type
        return view
    }
    
    class func create(frame: CGRect, type: ACDHeaderInfoType) -> ACDInfoHeaderView {
        let view = Bundle.main.loadNibNamed("ACDInfoHeaderView", owner: nil)!.first as! ACDInfoHeaderView
        view.type = type
        view.frame = frame
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.chatView.addTarget(self, action: #selector(goChatPageAction), for: .touchUpInside)
    }
    
    @objc private func goChatPageAction() {
        self.goChatPageHandle?()
    }
    
    @IBAction func tapHeaderViewAction() {
        self.tapHeaderHandle?()
    }
}
