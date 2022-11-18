//
//  ACDNormalNavigationView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/31.
//

import UIKit
import SnapKit

class ACDNormalNavigationView: UIView {

    let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 8, height: 15))
    let leftLabel = UILabel()
    let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 8, height: 15))
    
    var leftButtonHandle: (() -> Void)?
    var rightButtonHandle: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.selfInit()
    }
    
    private func selfInit() {
        self.leftButton.contentMode = .scaleAspectFill;
        self.leftButton.setImage(UIImage(named: "black_goBack"), for: .normal)
        self.leftButton.addTarget(self, action: #selector(leftButtonAction), for: .touchUpInside)
        self.addSubview(self.leftButton)
        
        self.leftLabel.textColor = .black
        self.leftLabel.textAlignment = .left
        self.leftLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(self.leftLabel)
        
        self.rightButton.contentMode = .scaleAspectFill
        self.rightButton.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        self.addSubview(self.rightButton)
        
        self.leftButton.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(10)
            make.width.equalTo(40.0);
            make.bottom.equalTo(-5.0)
        }
        
        self.leftLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.leftButton)
            make.left.equalTo(self.leftButton.snp.right).offset(10)
        }
        
        self.rightButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.leftButton)
            make.right.equalTo(-16)
        }
    }
    
    @objc private func leftButtonAction() {
        self.leftButtonHandle?()
    }
    
    @objc private func rightButtonAction() {
        self.rightButtonHandle?()
    }
    
}
