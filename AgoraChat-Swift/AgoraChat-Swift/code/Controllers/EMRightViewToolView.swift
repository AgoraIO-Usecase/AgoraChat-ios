//
//  EMRightViewToolView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/10.
//

import UIKit

class EMRightViewToolView: UIView {

    enum ShowType {
        case username
        case password
    }
    
    let rightViewBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))

    init(type: ShowType) {
        super.init(frame: CGRect(x: 0, y: 0, width: 46, height: 28))
        if type == .password {
            self.rightViewBtn.setImage(UIImage(named: "hiddenPwd"), for: .normal)
            self.rightViewBtn.setImage(UIImage(named: "showPwd"), for: .selected)
        } else if type == .username {
            self.rightViewBtn.setImage(UIImage(named: "clearContent"), for: .normal)
        }
        self.addSubview(self.rightViewBtn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
