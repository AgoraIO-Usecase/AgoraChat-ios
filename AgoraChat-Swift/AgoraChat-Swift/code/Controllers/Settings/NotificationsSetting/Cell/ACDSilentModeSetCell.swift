//
//  ACDSilentModeSetCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit

class ACDSilentModeSetCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectedImageView.image = UIImage(named: selected ? "mute_select" : "mute_unselect")
    }
}
