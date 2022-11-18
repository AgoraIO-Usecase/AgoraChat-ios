//
//  NSObject+AlertController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/12.
//

import UIKit

@objc extension NSObject {
    @objc func showAlert(title: String? = nil, message: String) {
        guard let rootViewController = UIWindow.keyWindow?.rootViewController else {
            return
        }
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: LocalizedString.Ok, style: .cancel))
        controller.modalPresentationStyle = .fullScreen
        rootViewController.present(controller, animated: true)
    }
}
