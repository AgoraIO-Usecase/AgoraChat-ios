//
//  UIWindow+keyWindow.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/20.
//

import Foundation

extension UIWindow {
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                if let scene = scene as? UIWindowScene {
                    if #available(iOS 15.0, *) {
                        return scene.keyWindow
                    } else {
                        for window in scene.windows where window.isKeyWindow {
                            return window
                        }
                    }
                }
            }
        } else {
            return UIApplication.shared.keyWindow
        }
        return nil
    }
}
