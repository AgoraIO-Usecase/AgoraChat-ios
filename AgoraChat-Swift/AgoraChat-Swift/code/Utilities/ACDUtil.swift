//
//  ACDUtil.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/28.
//

import UIKit

class ACDUtil: NSObject {
    class func customLeftButtonItem(title: String, action: Selector, target: Any) -> UIBarButtonItem {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 8, height: 15))
        btn.setImage(UIImage(named: "black_goBack"), for: .normal)
        btn.addTarget(target, action: action, for: .touchUpInside)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return UIBarButtonItem(customView: btn)
    }
}
