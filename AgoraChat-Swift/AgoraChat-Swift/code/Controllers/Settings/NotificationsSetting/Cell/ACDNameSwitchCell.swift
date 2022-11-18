//
//  ACDNameSwitchCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit
import SnapKit

class ACDNameSwitchCell: UITableViewCell {

    let `switch` = UISwitch()
    private let label = UILabel()
    
    var switchActionHandle: ((_ isOn: Bool) -> Void)?
    var title: String? {
        didSet {
            self.label.text = title
        }
    }
    
    var isOn: Bool = false {
        didSet {
            self.switch.isOn = isOn
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.label.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        self.label.textColor = Color_0D0D0D
        self.label.textAlignment = .left
        self.label.lineBreakMode = .byTruncatingTail
        self.contentView.addSubview(self.label)
        
        self.switch.onTintColor = Color_154DFE
        self.switch.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        self.addSubview(self.switch)
        
        self.label.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(16)
            make.right.equalTo(self.switch.snp.left)
        }
        
        self.switch.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchAction() {
        self.switchActionHandle?(self.switch.isOn)
    }
}
