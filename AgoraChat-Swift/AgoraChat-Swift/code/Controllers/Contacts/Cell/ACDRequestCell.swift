//
//  ACDRequestCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/19.
//

import UIKit

class ACDRequestCell: UITableViewCell {

    @IBOutlet weak var iconImageView: AgoraChatAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var resultlabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var acceptHandle: ((_ model: AgoraApplyModel) -> Void)?
    var rejectHandle: ((_ model: AgoraApplyModel) -> Void)?
    
    var model: AgoraApplyModel? {
        didSet {
            self.nameLabel.text = self.model?.applyNickname
            self.timeLabel.text = "Now".localized
            self.contentLabel.text = self.model?.reason
            
            if self.model?.status != .unhandle {
                self.acceptButton.isHidden = true
                self.rejectButton.isHidden = true
                self.resultlabel.isHidden = false
                if self.model?.status == .agreed {
                    self.resultlabel.text = "Accepted".localized
                } else if self.model?.status == .declined {
                    self.resultlabel.text = "Ignored".localized
                }
            } else {
                self.acceptButton.isHidden = false
                self.rejectButton.isHidden = false
                self.resultlabel.isHidden = true
                self.resultlabel.text = "Accept".localized
            }
            
            switch self.model?.type {
            case .contact(userId: _):
                self.iconImageView.layer.cornerRadius = 29
                self.iconImageView.image = UIImage(color: Color_CFD6B8, size: CGSize(width: 58, height: 58))
            default:
                self.iconImageView.layer.cornerRadius = 0
                self.iconImageView.image = UIImage(named: "group_default_avatar")
            }
            
            if let userId = self.model?.userId {
                UserInfoStore.shared.fetchUserInfosFromServer(userIds: [userId]) {
                    if let userId = self.model?.userId {
                        let userInfo = UserInfoStore.shared.getUserInfo(userId: userId)
                        self.nameLabel.text = userInfo?.showName ?? userId
                        if let userInfo = userInfo {
                            let model = AgoraUserModel(hyphenateId: userId)
                            model.setUserInfo(userInfo)
                            self.iconImageView.setImage(withUrl: userInfo.avatarUrl, placeholder: model.defaultAvatar)
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func acceptButtonAction() {
        if let model = self.model {
            self.acceptHandle?(model)
        }
    }
    
    @IBAction func rejectButtonAction() {
        if let model = self.model {
            self.rejectHandle?(model)
        }
    }
}
