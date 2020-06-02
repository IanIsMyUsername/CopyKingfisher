//
//  ExtensionHelpers.swift
//  CopyKingfisher
//
//  Created by 陈奕舟 on 2020/2/6.
//  Copyright © 2020 陈奕舟. All rights reserved.
//

import Foundation

extension CGFloat {
    var isEven: Bool {
        return truncatingRemainder(dividingBy: 2.0) == 0
    }
    
}

#if canImport(UIKit)
import UIKit
extension RectCorner {
    var uiRectCorner: UIRectCorner {
        
        var result: UIRectCorner = []
        
        if contains(.topLeft) { result.insert(.topLeft) }
        if contains(.topRight) { result.insert(.topRight) }
        if contains(.bottomLeft) { result.insert(.bottomLeft) }
        if contains(.bottomRight) { result.insert(.bottomRight) }
        
        return result
    }
}
#endif

extension Date {
    var isPast: Bool {
        return isPast(referenceDate: Date())
    }
    
    var isFuture: Bool {
        return !isPast
    }
    
    func isPast(referenceDate: Date) -> Bool {
        return timeIntervalSince(referenceDate) <= 0
    }
    
    func isFuture(referenceDate: Date) -> Bool {
        return !isPast(referenceDate: referenceDate)
    }
    
    // `Date` in memory is a wrap for `TimeInterval`. But in file attribute it can only accept `Int` number.
    // By default the system will `round` it. But it is not friendly for testing purpose.
    // So we always `ceil` the value when used for file attributes.
    var fileAtrributeDate: Date {
        return Date(timeIntervalSince1970: ceil(timeIntervalSince1970))
    }
}
