//
//  UITabBar+RedPoint.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/12.
//

import UIKit

extension UITabBar {
    func showBadge(index: Int) {
        self.removeBadge(index: index)
        
        let badgeView = UIView()
        badgeView.tag = 888 + index
        badgeView.layer.cornerRadius = 5
        badgeView.backgroundColor = Color_FF14CC
        
        let tabFrame = self.frame
        let percentX = (CGFloat(index) + 0.6) / 3.0
        let x = ceil(percentX * tabFrame.width)
        let y = ceil(0.1 * tabFrame.height)
        badgeView.frame = CGRect(x: x, y: y, width: 10, height: 10)
        self.addSubview(badgeView)
    }
    
    func hideBadge(index: Int) {
        removeBadge(index: index)
    }
    
    private func removeBadge(index: Int) {
        for view in self.subviews where view.tag == 888 + index {
            view.removeFromSuperview()
            return
        }
    }
}
