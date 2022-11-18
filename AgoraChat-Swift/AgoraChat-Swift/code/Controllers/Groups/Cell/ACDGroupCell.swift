//
//  ACDGroupCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/20.
//

import UIKit

class ACDGroupCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var model: AgoraGroupModel? {
        didSet {
            self.nameLabel.text = model?.subject
            self.iconImageView.image = model?.defaultAvatarImage
            self.iconImageView.setImage(withUrl: model?.avatarURLPath)
        }
    }
}
