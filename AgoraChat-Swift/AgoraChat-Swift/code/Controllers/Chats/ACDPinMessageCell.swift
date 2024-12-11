//
//  ACDPinMessageCell.swift
//  AgoraChat-Swift
//
//  Created by li xiaoming on 2024/3/15.
//

import UIKit

protocol ACDPinMessageDelegate: AnyObject {
    func unpinMessage(_ message: AgoraChatMessage)
}

class ACDPinMessageCell: UITableViewCell {
    var dateLabel = UILabel()
    var titleLabel = UILabel()
    var messageInfoLabel = UILabel()
    var imgView = UIImageView()
    var unpinButton = UIButton(type: .custom)
    var message: AgoraChatMessage?
    weak var delegate: ACDPinMessageDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = CGRect(x: 10, y: 5, width: 250, height: 20)
        self.dateLabel.frame = CGRect(x: (self.contentView.frame.width - 150), y: 5, width: 125, height: 20)
        self.messageInfoLabel.frame = CGRect(x: 10, y: 30, width: 200, height: 20)
        self.imgView.frame = CGRect(x: 10, y: 30, width: 80, height: 100)
        self.unpinButton.frame = CGRect(x: (self.contentView.frame.width - 45), y: (self.contentView.frame.height - 30), width: 20, height: 20)
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    }
    func loadSubViews() {
        self.contentView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        self.contentView.layer.cornerRadius = 8
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 10)
        titleLabel.textColor = UIColor(red: 0.092, green: 0.102, blue: 0.108, alpha: 1.0)
        dateLabel.font = UIFont(name: "SFPro-Regular", size: 10)
        dateLabel.textColor = UIColor(red: 0.676, green: 0.706, blue: 0.724, alpha: 1.0)
        dateLabel.textAlignment = .right
        messageInfoLabel.numberOfLines = 1
        messageInfoLabel.font = UIFont(name: "SFPro-Regular", size: 12)
        messageInfoLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        unpinButton.setImage(UIImage(named: "unpin"), for: .normal)
        unpinButton.addTarget(self, action: #selector(unpinButtonAction), for: .touchUpInside)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(messageInfoLabel)
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(unpinButton)
    }
    @objc func unpinButtonAction() {
        if let message = self.message {
            self.delegate?.unpinMessage(self.message!)
        }
    }
    func updateLayout() {
        let text = "\(self.message?.pinnedInfo?.operatorId ?? "") pinned \(self.message?.from ?? "")'s message"
        self.titleLabel.text = text
        
        guard let ts = self.message?.timestamp else { return  }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(ts) / 1000)
        self.dateLabel.text = formatter.string(from: date)
        
        switch self.message?.body.type {
        case .combine,.text,.location,.voice,.file:
            self.messageInfoLabel.text = message?.pinnedText ?? ""
            self.messageInfoLabel.removeFromSuperview()
            self.imgView.removeFromSuperview()
            self.contentView.addSubview(self.messageInfoLabel)
        case .image:
            if let imageBody = self.message?.body as? AgoraChatImageMessageBody {
                var localPath = imageBody.thumbnailLocalPath
                if localPath?.count == 0 {
                    localPath = imageBody.localPath
                }
                if let localPath = localPath,
                   let image = UIImage.init(contentsOfFile: localPath) {
                    self.imgView.image = image
                } else {
                    self.imgView.setImage(withUrl: imageBody.thumbnailRemotePath, placeholder: "msg_img_broken")
                }
            }
            
            self.messageInfoLabel.removeFromSuperview()
            self.imgView.removeFromSuperview()
            self.contentView.addSubview(self.imgView)
            break
        case .video:
            if let videoBody = self.message?.body as? AgoraChatVideoMessageBody {
                var localPath = videoBody.thumbnailLocalPath
                if localPath?.count == 0 {
                    localPath = videoBody.localPath
                }
                if let localPath = localPath,
                   let image = UIImage.init(contentsOfFile: localPath) {
                    self.imgView.image = image
                } else {
                    self.imgView.setImage(withUrl: videoBody.thumbnailRemotePath, placeholder: "msg_img_broken")
                }
            }
            
            self.messageInfoLabel.removeFromSuperview()
            self.imgView.removeFromSuperview()
            self.contentView.addSubview(self.imgView)
            break
        default:
            break
        }
    }
    func setMessage(_ message: AgoraChatMessage) {
        self.message = message
        updateLayout()
    }
}

extension AgoraChatMessage {
    var pinnedText: String? {
        switch swiftBody {
        case let .text(content: content):
            return content
        case let .file(localPath: _, displayName: dispayName):
            return "[File]\(dispayName)"
        case let .combine(title: _, summary: summary, compatibleText: _, messageIdList: _):
            return "[Chat History]\(summary ?? "")"
        case .voice(localPath: _, displayName: _):
            return "[Voice]"
        case let .location(latitude: _, longitude: _, address: address, buildingName: _):
            return "[Location]\(address ?? "")"
        default:
            return ""
        }
    }
}
