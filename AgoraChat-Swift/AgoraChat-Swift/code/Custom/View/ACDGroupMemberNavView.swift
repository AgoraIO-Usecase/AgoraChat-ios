//
//  ACDGroupMemberNavView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/28.
//

import UIKit

class ACDGroupMemberNavView: UIView {

    private var view: UIView?
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var leftSubLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    
    var leftButtonHandle: (() -> Void)?
    var rightButtonHandle: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.view = Bundle.main.loadNibNamed("ACDGroupMemberNavView", owner: self)?.first as? UIView
        if let view = self.view {
            self.addSubview(view)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view?.frame = self.bounds
    }
    
    @IBAction func leftButtonAction() {
        self.leftButtonHandle?()
    }
    
    @IBAction func rightButtonAction() {
        self.rightButtonHandle?()
    }
}
