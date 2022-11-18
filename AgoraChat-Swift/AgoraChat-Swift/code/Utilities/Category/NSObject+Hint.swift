//
//  NSObject+Hint.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/12.
//

import Foundation

extension NSObject {
    func showHint(_ hint: String) {
        guard let view = UIWindow.keyWindow else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        hud.mode = .text
        hud.margin = 10
        hud.offset = CGPoint(x: hud.offset.x, y: 180)
        hud.removeFromSuperViewOnHide = true
        hud.detailsLabel.text = hint
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 14)
        hud.hide(animated: true, afterDelay: 2)
    }
}
