//
//  ACDContactCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/19.
//

import UIKit

@objcMembers
class ACDContactCell: UITableViewCell {

    @IBOutlet weak var iconImageView: AgoraChatAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var tapCellHandle: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.contentView.addGestureRecognizer(ges)
    }
    
    var model: AgoraUserModel? {
        didSet {
            self.nameLabel.text = self.model?.showName
            self.iconImageView.image = self.model?.defaultAvatarImage
            self.iconImageView.setImage(withUrl: self.model?.avatarURLPath)
        }
    }
    
    func tapAction() {
        self.tapCellHandle?()
    }
}
