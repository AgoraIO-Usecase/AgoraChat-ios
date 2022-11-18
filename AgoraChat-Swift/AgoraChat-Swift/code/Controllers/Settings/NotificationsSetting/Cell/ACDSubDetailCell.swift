//
//  ACDSubDetailCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/20.
//

import UIKit

class ACDSubDetailCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var subDetailLabel: UILabel!
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
    
    var showSubDetailLabel: Bool = false {
        didSet {
            self.centerYConstraint.constant = self.showSubDetailLabel ? -16 : 0
            self.subDetailLabel.isHidden = !showSubDetailLabel
        }
    }
    
    var tapCellHandle: (() -> Void)?
    var height: CGFloat {
        return self.showSubDetailLabel ? 70 : 54
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.contentView.addGestureRecognizer(ges)
    }
    
    @objc private func tapAction() {
        self.tapCellHandle?()
    }
}
