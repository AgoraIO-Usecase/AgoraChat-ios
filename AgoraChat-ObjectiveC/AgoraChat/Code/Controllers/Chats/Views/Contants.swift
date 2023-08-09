//
//  Contants.swift
//  ZSwiftBaseLib
//
//  Created by 朱继超 on 2020/12/16.
//

import Foundation
import UIKit

public let ScreenWidth = UIScreen.main.bounds.width

public let ScreenHeight = UIScreen.main.bounds.height

public let edgeZero: UIEdgeInsets = .zero

@available(iOS 11.0, *)
public let safeAreaExist = (UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets != edgeZero)

public let BottombarHeight = (UIApplication.shared.statusBarFrame.height > 20 ? 34:0)

public let TabbarHeight = (UIApplication.shared.statusBarFrame.height > 20 ? 49+34:49)

public let StatusBarHeight :CGFloat = UIApplication.shared.statusBarFrame.height

public let NavgationHeight :CGFloat = UIApplication.shared.statusBarFrame.height + 44

//project wrapper
public struct AgoraChat<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}






