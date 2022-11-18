//
//  ACDMemberCollectionCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/24.
//

import UIKit

class ACDMemberCollectionCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet private weak var deleteImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var model: AgoraUserModel? {
        didSet {
            if let model = model {
                self.nameLabel.text = model.showName
                self.avatarImageView.image = model.defaultAvatarImage
                self.avatarImageView.setImage(withUrl: model.avatarURLPath)
            } else {
                self.nameLabel.text = ""
                self.avatarImageView.image = UIImage(named: "default_avatar")
            }
        }
    }
    var username: String?
    var deleteEnable: Bool = true {
        didSet {
            self.deleteImageView.isHidden = !deleteEnable
        }
    }
}
