//
//  Array+remove.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/19.
//

import Foundation

extension Array where Element : Equatable {
    @inlinable public mutating func remove(element: Element) {
        for i in 0..<self.count {
            if self[i] == element {
                self.remove(at: i)
                break
            }
        }
    }
    
    @inlinable public mutating func remove(elements: [Element]) {
        for element in elements {
            for i in 0..<self.count {
                if self[i] == element {
                    self.remove(at: i)
                    break
                }
            }
        }
    }
}
