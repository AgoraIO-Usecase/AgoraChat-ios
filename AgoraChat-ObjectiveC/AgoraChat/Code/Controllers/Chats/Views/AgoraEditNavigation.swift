//
//  AgoraEditNavgation.swift
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/7/31.
//  Copyright © 2023 easemob. All rights reserved.
//

import UIKit

@objc final class AgoraEditNavigation: UIView {
    
    @objc var cancelClosure: (() -> Void)?
    
    private lazy var avatar: UIImageView = {
        UIImageView(frame: CGRect(x: 12, y: self.frame.height-40, width: 35, height: 35))
    }()
    
    private lazy var nickName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.frame.height-34, width: self.frame.width-150, height: 20)).font(.systemFont(ofSize: 18, weight: .semibold)).textColor(.darkText)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-66, y: self.frame.height-32, width: 54, height: 20)).textColor(UIColor(0x114EFF), .normal).font(.systemFont(ofSize: 16)).addTargetFor(self, action: #selector(cancelAction), for: .touchUpInside).title("Cancel", .normal)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc public convenience init(frame: CGRect, avatar: UIImage, nickName: String) {
        self.init(frame: frame)
        self.addSubViews([self.avatar,self.nickName,self.cancel])
        self.avatar.image = avatar
        self.nickName.text = nickName
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func cancelAction() {
        self.cancelClosure?()
    }
    
}
