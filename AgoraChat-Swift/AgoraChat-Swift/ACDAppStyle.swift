//
//  ACDAppStyle.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/9.
//

import UIKit

class ACDAppStyle: NSObject {
    
    class func useDefault() {
        //hidden navigation bottom line
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: Color_114EFF
        ], for: .selected)
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBarItem.appearance().badgeColor = Color_FF14CC
        
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0.9803921569, green: 0.9843137255, blue: 0.9882352941, alpha: 1)
        UITabBar.appearance().tintColor = Color_00BA6E
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.9803921569, green: 0.9843137255, blue: 0.9882352941, alpha: 1)
        UINavigationBar.appearance().tintColor = Color_0C1218
        UINavigationBar.appearance().isTranslucent = true
    }
}
