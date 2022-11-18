//
//  ACDImageTextButtonView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit

class ACDImageTextButtonView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.titleLabel?.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView?.frame = CGRect(x: (self.bounds.width - 40) / 2, y: 5, width: 40, height: 40)
        self.titleLabel?.frame = CGRect(x: 0, y: 50, width: self.bounds.width, height: 12)
    }
}
