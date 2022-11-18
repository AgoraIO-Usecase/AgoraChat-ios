//
//  ACDAvatarCollectionCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/13.
//

import UIKit

class ACDAvatarCollectionCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!

    var isSelect: Bool = false {
        didSet {
            self.selectedImageView.isHidden = !isSelect
        }
    }
}
