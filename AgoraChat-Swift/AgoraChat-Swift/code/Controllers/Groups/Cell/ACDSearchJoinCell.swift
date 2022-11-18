//
//  ACDSearchJoinCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/24.
//

import UIKit

class ACDSearchJoinCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    var isSearchGroup = true {
        didSet {
            if self.isSearchGroup {
                self.addButton.setTitle("Apply".localized, for: .normal)
                self.addButton.setTitle("Applied".localized, for: .selected)
            } else {
                self.addButton.setTitle("Add".localized, for: .normal)
                self.addButton.setTitle("Added".localized, for: .selected)
            }
        }
    }
    var searchName: String? {
        didSet {
            self.nameLabel.text = self.searchName
            self.addButton.isEnabled = true
        }
    }
    var addGroupHandle: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSearchGroup = true
    }
    
    @IBAction func addButtonAction() {
        self.addGroupHandle?()
        self.addButton.isEnabled = false
    }
}
