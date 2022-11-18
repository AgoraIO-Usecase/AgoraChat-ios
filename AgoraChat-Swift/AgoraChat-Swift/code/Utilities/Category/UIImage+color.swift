//
//  UIImage+color.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/19.
//

import Foundation

extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setFillColor(color.cgColor)
            ctx.fill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let image = image?.cgImage {
                self.init(cgImage: image)
            } else {
                return nil
            }
        }
        return nil
    }
}
