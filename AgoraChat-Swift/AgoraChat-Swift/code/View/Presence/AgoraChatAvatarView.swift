//
//  AgoraChatAvatarView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/10.
//

import UIKit
import SnapKit

@objcMembers
class AgoraChatAvatarView: UIImageView {

    private let presenceView = UIImageView()
    
    @objc var presenceImage: UIImage? {
        didSet {
            if self.presenceView.superview != nil {
                self.presenceView.removeFromSuperview()
            }
            if self.presenceView.superview == nil && self.superview != nil {
                self.superview?.addSubview(self.presenceView)
                self.presenceView.snp.makeConstraints { make in
                    make.width.height.equalTo(self).multipliedBy(0.4)
                    make.bottom.right.equalTo(self)
                }
            }
            self.presenceView.image = presenceImage
        }
    }
}
