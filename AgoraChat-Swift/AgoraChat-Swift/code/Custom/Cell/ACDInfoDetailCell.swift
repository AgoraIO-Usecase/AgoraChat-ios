//
//  ACDInfoDetailCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/26.
//

import UIKit

@objcMembers
class ACDInfoDetailCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var tapCellHandle: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.contentView.addGestureRecognizer(ges)
    }
    
    @objc private func tapAction() {
        self.tapCellHandle?()
    }
}
