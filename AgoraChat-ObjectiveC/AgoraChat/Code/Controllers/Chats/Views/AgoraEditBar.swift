//
//  AgoraEditBar.swift
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/7/31.
//  Copyright © 2023 easemob. All rights reserved.
//

import UIKit

@objc public enum AgoraEditBarOperation: Int {
    case delete = 1
    case forward
}

@objc final class AgoraEditBar: UIView {
    
    @objc var actionClosure: ((AgoraEditBarOperation) -> Void)?
    
    private lazy var delete: UIButton = {
        UIButton(type: .custom).image("edit_delete", .normal).frame(CGRect(x: 12, y: 8, width: 36, height: 36)).tag(1).addTargetFor(self, action: #selector(senderAction), for: .touchUpInside)
    }()
    
    private lazy var forward: UIButton = {
        UIButton(type: .custom).image("edit_forward", .normal).frame(CGRect(x: self.frame.width-48, y: 8, width: 36, height: 36)).tag(2).addTargetFor(self, action: #selector(senderAction), for: .touchUpInside)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.delete,self.forward])
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func senderAction(_ sender: UIButton) {
        self.actionClosure?(AgoraEditBarOperation(rawValue: sender.tag) ?? .delete)
    }

    
}
