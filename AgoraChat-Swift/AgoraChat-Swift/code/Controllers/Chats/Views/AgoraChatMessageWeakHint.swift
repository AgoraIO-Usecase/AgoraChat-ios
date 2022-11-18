//
//  AgoraChatMessageWeakHint.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/24.
//

import UIKit

class AgoraChatMessageWeakHint: UITableViewCell {

    @IBOutlet private weak var contentLabel: UILabel!
    
    var messageModel: EaseMessageModel? {
        didSet {
            guard let messageModel = messageModel else {
                self.contentLabel.text = nil
                return
            }
            guard let body = messageModel.message.body as? AgoraChatTextMessageBody else {
                self.contentLabel.text = nil
                return
            }
            let attribute = NSMutableAttributedString(string: body.text)
            attribute.addAttributes([
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: Color_999999
            ], range: NSRange(location: 0, length: body.text.count))
            if let ext = messageModel.message.ext, ext.count > 0, let str = ext["agora_notiUserID"] as? String, str.count > 0 {
                attribute.addAttributes([
                    .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                    .foregroundColor: Color_999999
                ], range: (body.text as NSString).range(of: str))
            }
        }
    }
}
