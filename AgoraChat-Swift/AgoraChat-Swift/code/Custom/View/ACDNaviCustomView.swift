//
//  ACDNaviCustomView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit
import SnapKit

class ACDNaviCustomView: UIView {

    let addButton = UIButton(type: .custom)
    let titleImageView = UIImageView()
    
    var addActionHandle: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addButton.contentMode = .scaleAspectFill
        self.addButton.setImage(UIImage(named: "contact_add_contacts"), for: .normal)
        self.addButton.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        self.addSubview(self.addButton)
        
        self.titleImageView.contentMode = .scaleAspectFill
        self.titleImageView.image = UIImage(named: "nav_title_contacts")
        self.addSubview(self.titleImageView)
        
        self.titleImageView.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
        }
        self.addButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleImageView)
            make.right.equalTo(self).offset(-10)
            make.size.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func addAction() {
        self.addActionHandle?()
    }
}
