//
//  UIAlertAction+Custom.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/12.
//

import Foundation

@objc extension UIAlertAction {
    @objc convenience init(title: String, iconImage: UIImage?, textColor: UIColor, alignment: NSTextAlignment, completion: @escaping (UIAlertAction) -> Void) {
        self.init(title: title, style: .default, handler: completion)
        self.setValue(textColor, forKey: "titleTextColor")
        self.setValue(alignment.rawValue, forKey: "titleTextAlignment")
        self.setValue(iconImage, forKey: "image")
    }
}
