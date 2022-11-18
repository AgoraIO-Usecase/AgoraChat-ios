//
//  AgoraChatCallCell.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class AgoraChatCallCell: EaseMessageCell {

    private var statusImageView: UIImageView!
    private var statusLabel: UILabel!
    private var timeLabel: UILabel!
    
    override class func cellIdentifier(with aDirection: AgoraChatMessageDirection, type aType: AgoraChatMessageType) -> String {
        return "AgoraChatCallCell"
    }
    
    override func getBubbleView(with aType: AgoraChatMessageType) -> EaseChatMessageBubbleView {
        let bubbleView = EaseChatMessageBubbleView()
        bubbleView.layer.cornerRadius = 16
        
        self.statusImageView = UIImageView()
        bubbleView.addSubview(self.statusImageView)
        
        self.statusLabel = UILabel()
        self.statusLabel.font = UIFont.systemFont(ofSize: 16)
        self.statusLabel.textColor = .black
        bubbleView.addSubview(self.statusLabel)
        
        self.timeLabel = UILabel()
        self.timeLabel.font = UIFont.systemFont(ofSize: 14)
        self.timeLabel.textColor = UIColor(white: 0.4, alpha: 1)
        bubbleView.addSubview(self.timeLabel)
        
        self.timeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.statusLabel.snp.bottom).offset(6)
            make.left.equalTo(self.statusLabel)
        }
        
        bubbleView.backgroundColor = Color_F2F2F2
        return bubbleView
    }
    
    override func maxBubbleViewWidth() -> CGFloat {
        return 230
    }

    override var model: EaseMessageModel {
        didSet {
            super.model = model
            self.setStatusHidden(true)
            let action = model.message.ext?["action"] as? String
            let typeValue = model.message.ext?["type"] as? Int
            let callType = typeValue == nil ? nil : AgoraChatCallType(rawValue: typeValue!)
            if model.direction == .send {
                self.statusImageView.snp.remakeConstraints { make in
                    make.width.height.equalTo(50)
                    make.top.equalTo(10)
                    make.bottom.equalTo(-10)
                    make.left.equalTo(10)
                    make.right.equalTo(-170)
                }
                self.statusLabel.snp.remakeConstraints { make in
                    make.left.equalTo(68)
                    make.top.equalTo(self.statusImageView)
                }
            } else {
                self.statusImageView.snp.remakeConstraints { make in
                    make.width.height.equalTo(50)
                    make.top.equalTo(10)
                    make.bottom.equalTo(-10)
                    make.right.equalTo(-10)
                    make.left.equalTo(170)
                }
                self.statusLabel.snp.remakeConstraints { make in
                    make.left.equalTo(12)
                    make.top.equalTo(self.statusImageView)
                }
            }
            if action == "invite" {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm MMM dd"
                let date = Date(timeIntervalSince1970: Double(model.message.timestamp) / 1000)
                if callType == .type1v1Audio || callType == .typeMultiAudio {
                    self.statusImageView.image = UIImage(named: "cell_audio_call_invite")
                    self.statusLabel.text = "Audio Call Invite".localized
                } else {
                    self.statusImageView.image = UIImage(named: "cell_video_call_invite")
                    self.statusLabel.text = "Video Call Invite".localized
                }
                self.timeLabel.text = formatter.string(from: date)
            } else if action == "cancelCall" {
                let timeLength = self.model.message.ext?["callDuration"] as? Int ?? 0
                let m = timeLength / 60
                let s = timeLength % 60
                let duration = String(format: "%02d:%02d", m, s)
                if callType == .type1v1Audio || callType == .typeMultiAudio {
                    self.statusImageView.image = UIImage(named: "cell_audio_call")
                    self.statusLabel.text = "Audio Call Ended".localized
                } else {
                    self.statusImageView.image = UIImage(named: "cell_video_call")
                    self.statusLabel.text = "Video Call Ended".localized
                }
                self.timeLabel.text = duration
            }
            
            self.bubbleView.snp.updateConstraints { make in
                make.width.lessThanOrEqualTo(300)
            }
        }
    }
}
