//
//  ACDReportTextMessageCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class ACDReportTextMessageCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var model: EaseMessageModel? {
        didSet {
            self.avatarImageView.image = model?.userDataProfile.defaultAvatar
            self.avatarImageView.setImage(withUrl: model?.userDataProfile.avatarURL)
            self.nameLabel.text = model?.userDataProfile.showName ?? nil
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            if let timestamp = model?.message.timestamp {
                let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
                self.timeLabel.text = formatter.string(from: date)
            } else {
                self.timeLabel.text = ""
            }
            if let body = model?.message.body as? AgoraChatTextMessageBody {
                self.messageLabel.text = body.text
            }
        }
    }
}
