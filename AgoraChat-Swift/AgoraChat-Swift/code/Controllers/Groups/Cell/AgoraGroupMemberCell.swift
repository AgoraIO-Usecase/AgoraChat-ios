//
//  AgoraGroupMemberCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/21.
//

import UIKit

class AgoraGroupMemberCell: UITableViewCell {

    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var isSelect: Bool = false {
        didSet {
            self.selectImageView.image = UIImage(named: isSelect ? "member_selected" : "member_normal")
        }
    }
    
    var model: AgoraUserModel? {
        didSet {
            self.nameLabel.text = model?.showName
            self.iconImageView.image = model?.defaultAvatarImage
            self.iconImageView.setImage(withUrl: model?.avatarURLPath)
        }
    }
}
