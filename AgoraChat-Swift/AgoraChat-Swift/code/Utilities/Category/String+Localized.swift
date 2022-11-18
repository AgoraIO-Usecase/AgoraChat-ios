//
//  String+Localized.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/11/4.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
